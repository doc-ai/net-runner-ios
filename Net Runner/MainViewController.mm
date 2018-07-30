//
//  MainViewController.mm
//  Net Runner
//
//  Created by Philip Dow on 7/26/18.
//  Copyright © 2018 doc.ai. All rights reserved.
//

#import "MainViewController.h"

#import <AssertMacros.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <CoreImage/CoreImage.h>
#import <ImageIO/ImageIO.h>
#import <VideoToolbox/VideoToolbox.h>

#include <iostream>

#import "ModelBundleManager.h"
#import "ImageNetClassificationModel.h"
#import "ResultInfoView.h"
#import "VisionModel.h"
#import "Model.h"
#import "LatencyCounter.h"
#import "SettingsTableViewController.h"
#import "UIImage+CVPixelBuffer.h"
#import "CVPixelBufferHelpers.h"
#import "NSArray+Extensions.h"
#import "Utilities.h"
#import "VisionPipeline.h"
#import "LatencyCounter.h"
#import "ImageInputPreviewView.h"
#import "UserDefaults.h"
#import "ModelBundle.h"
#import "CVPixelBufferEvaluator.h"
#import "EvaluatorConstants.h"
#import "ModelOptions.h"
#import "ModelOutput.h"

// MARK: -

typedef enum : NSUInteger {
    CaptureModeLiveVideo,
    CaptureModePhoto,
} CaptureMode;

@interface MainViewController ()

@property ResultInfoView *infoView;
@property NSDate *lastScreenUpdate;
@property (nonatomic) CaptureMode captureMode;
@property LatencyCounter *latencyCounter;

@property ModelBundle *modelBundle;
@property id<VisionModel> model;
@property id<ModelOutput> previousOutput;

@end

@implementation MainViewController {
    AVCaptureSession *session;
    AVCaptureDevicePosition devicePosition;
    AVCaptureVideoPreviewLayer *previewLayer;
    AVCaptureVideoDataOutput *videoDataOutput;
    dispatch_queue_t videoDataOutputQueue;
}

- (void)dealloc {
  [self teardownAVCapture];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.lastScreenUpdate = [NSDate date];

    // UI
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(freezeVideo:)];
    [self.previewView addGestureRecognizer:tapRecognizer];
    
    UISwipeGestureRecognizer *swipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeDeviceOrientation:)];
    swipeRecognizer.direction = ( UISwipeGestureRecognizerDirectionRight | UISwipeGestureRecognizerDirectionLeft );
    [self.previewView addGestureRecognizer:swipeRecognizer];
    
    self.infoView = [[ResultInfoView alloc] init];
    [self.view addSubview:self.infoView];
    
    self.infoView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [NSLayoutConstraint activateConstraints:@[
        [self.infoView.rightAnchor constraintEqualToAnchor:self.view.rightAnchor constant:-16],
        [self.infoView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor constant:-26],
        [self.infoView.leftAnchor constraintEqualToAnchor:self.view.leftAnchor constant:16],
        [self.infoView.heightAnchor constraintGreaterThanOrEqualToConstant:40]
    ]];

    // Load default model
    
    NSString *modelId = [NSUserDefaults.standardUserDefaults stringForKey:kPrefsSelectedModelID];
    ModelBundle *bundle = [ModelBundleManager.sharedManager bundleWithId:modelId];
    
    if ( bundle == nil ) {
        NSLog(@"Unable to locate model bundle from last selected bundle with id: %@", modelId);
    } else {
        [self loadModelFromBundle:bundle];
    }
    
    // Preferences
    
    self.imageInputPreviewView.hidden = ![NSUserDefaults.standardUserDefaults boolForKey:kPrefsShowInputBuffers];
    self.imageInputPreviewView.showsAlphaChannel = [NSUserDefaults.standardUserDefaults boolForKey:kPrefsShowInputBufferAlpha];
    
    // Prepare capture
    
    if ( self.model != nil ) {
        [self setupAVCapture:self.model.options.devicePosition];
        [self setCaptureMode:CaptureModeLiveVideo];
    }
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    CALayer* rootLayer = self.previewView.layer;
    [previewLayer setFrame:[rootLayer bounds]];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if (self.captureMode == CaptureModeLiveVideo && [session isRunning]) {
        [session stopRunning];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.captureMode == CaptureModeLiveVideo && ![session isRunning] && self.model != nil) {
        [session startRunning];
    }
}

- (void)willMoveToParentViewController:(UIViewController *)parent {
    [super willMoveToParentViewController:parent];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ( [segue.identifier isEqualToString:@"SettingsSegue"] ) {
        SettingsTableViewController *destination = (SettingsTableViewController*)segue.destinationViewController;
        destination.selectedBundle = self.modelBundle;
        destination.delegate = self;
    }
}

/**
 * Loads a new instance of a model from a model bundle.
 * This method has no effect if the model bundle is already the loaded model bundle.
 *
 * @param bundle the `ModelBundle` to load
 *
 * @return BOOL `YES` if a new model was loaded, `NO` if not
 */

- (BOOL)loadModelFromBundle:(nonnull ModelBundle*)bundle {
    if ( self.modelBundle == bundle ) {
        return NO;
    }
    
    NSError *modelError;
    
    self.modelBundle = bundle;
    self.model = (id<VisionModel>)[self.modelBundle newModel];
    
    if ( self.model == nil ) {
        NSLog(@"Unable to find and instantiate model with id %@", bundle.identifier);
        [self showLoadModelAlert:@"Could not instantiate the model. Ensure the class corresponding to this model is available."];
        self.modelBundle = nil;
        self.model = nil;
        return NO;
    }
    
    if ( ![self.model conformsToProtocol:@protocol(VisionModel)] ) {
        NSLog(@"Model does not conform to protocol VisionModel, id: %@", bundle.identifier);
        [self showLoadModelAlert:@"Model class does not correspond to the VisionModel protocol."];
        self.modelBundle = nil;
        self.model = nil;
        return NO;
    }
    
    if ( ![self.model load:&modelError] ) {
        NSLog(@"Model does could not be loaded, id: %@, error: %@", bundle.identifier, modelError);
        [self showLoadModelAlert:@"Could to read the underlying model file (e.g. tflite file). Ensure it exists and is valid."];
        self.modelBundle = nil;
        self.model = nil;
        return NO;
    }
    
    self.title = self.model.name;
    self.imageInputPreviewView.pixelFormat = self.model.pixelFormat;

    self.previousOutput = nil;
    self.latencyCounter = [[LatencyCounter alloc] init];
    
    return YES;
}

- (void)showLoadModelAlert:(NSString*)description {
    UIAlertController *alert = [UIAlertController
        alertControllerWithTitle:NSLocalizedString(@"Unable to load model", @"Failed to load model alert title")
        message:NSLocalizedString(description, @"Failed to load model alert message")
        preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addAction:[UIAlertAction
        actionWithTitle:NSLocalizedString(@"Dismiss", @"Alert dismiss action")
        style:UIAlertActionStyleDefault
        handler:nil]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

// MARK: - Settings Delegate

- (void)settingsTableViewControllerWillDisappear:(SettingsTableViewController*)viewController {
    // Model
    
    BOOL loadedNewModel = [self loadModelFromBundle:viewController.selectedBundle];
    
    // Restart capture with the newly selected model
    
    if ( self.model != nil && loadedNewModel ) {
        [self setupAVCapture:self.model.options.devicePosition];
        [self setCaptureMode:CaptureModeLiveVideo];
    }
    
    // Other Settings
    
    self.imageInputPreviewView.hidden = ![NSUserDefaults.standardUserDefaults boolForKey:kPrefsShowInputBuffers];
    self.imageInputPreviewView.showsAlphaChannel = [NSUserDefaults.standardUserDefaults boolForKey:kPrefsShowInputBufferAlpha];
}

// MARK: - Capture Mode

- (IBAction)selectInputSource:(id)sender {
    [self setInfoHidden:YES];
    
    if ([session isRunning]) {
        [session stopRunning];
    }
    
    // Show options for the source picker only if the camera is available.
    if ( ![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] ) {
        [self presentPhotoPicker:UIImagePickerControllerSourceTypePhotoLibrary];
        return;
    }
    
    UIAlertController *photoSourcePicker = [[UIAlertController alloc] init];
    
    UIAlertAction *takePicture = [UIAlertAction actionWithTitle:@"Take Picture" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self presentPhotoPicker:UIImagePickerControllerSourceTypeCamera];
    }];
    UIAlertAction *choosePhoto = [UIAlertAction actionWithTitle:@"Choose Photo" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self presentPhotoPicker:UIImagePickerControllerSourceTypePhotoLibrary];
    }];
    UIAlertAction *liveVideo = [UIAlertAction actionWithTitle:@"Live Video" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [self didSelectLiveVideoInputSource];
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [self didCancelInputSourcePicker];
    }];
    
    [photoSourcePicker addAction:takePicture];
    [photoSourcePicker addAction:choosePhoto];
    [photoSourcePicker addAction:liveVideo];
    [photoSourcePicker addAction:cancel];
    
    [self presentViewController:photoSourcePicker animated:YES completion:nil];
}

- (void)didSelectLiveVideoInputSource {
    [self setCaptureMode:CaptureModeLiveVideo];
    [self setInfoHidden:NO];
    
    if (![session isRunning]) {
        [session startRunning];
    }
}

- (void)didCancelInputSourcePicker {
    [self setInfoHidden:NO];
    if (self.captureMode == CaptureModeLiveVideo && ![session isRunning]) {
        [session startRunning];
    }
}

- (void)setCaptureMode:(CaptureMode)mode {
    _captureMode = mode;
    
    switch (mode) {
    case CaptureModeLiveVideo:
        self.photoImageView.hidden = YES;
        self.previewView.hidden = NO;
        break;
    case CaptureModePhoto:
        self.photoImageView.hidden = NO;
        self.previewView.hidden = YES;
        break;
    }
}

// MARK: - AV Capture

- (void)setupAVCapture:(AVCaptureDevicePosition)position {
    NSError* error = nil;
    
    // Session
    
    session = [AVCaptureSession new];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        [session setSessionPreset:AVCaptureSessionPreset640x480];
    } else {
        [session setSessionPreset:AVCaptureSessionPresetPhoto];
    }
    
    // Device and input
    // TODO: better error handling if the devices' camera is damaged or otherwise unavailable, for example

    AVCaptureDevice *device = [self captureDeviceWithPosition:position];
    AVCaptureDeviceInput *deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];

    if (error != nil) {
        NSLog(@"Failed to initialize AVCaptureDeviceInput. Note: This app doesn't work with simulator");
        [self presentError:error];
        [self teardownAVCapture];
        assert(NO);
    }

    if ([session canAddInput:deviceInput]) {
        [session addInput:deviceInput];
    }
    
    // Output

    videoDataOutputQueue = dispatch_queue_create("VideoDataOutputQueue", DISPATCH_QUEUE_SERIAL);
    videoDataOutput = [AVCaptureVideoDataOutput new];

    NSDictionary *rgbOutputSettings = @{
        (NSString*)kCVPixelBufferPixelFormatTypeKey: @(kCMPixelFormat_32BGRA)
    };
    
    [[videoDataOutput connectionWithMediaType:AVMediaTypeVideo] setVideoOrientation:AVCaptureVideoOrientationPortrait];
    [videoDataOutput setAlwaysDiscardsLateVideoFrames:YES];
    [videoDataOutput setVideoSettings:rgbOutputSettings];
    
    [videoDataOutput setSampleBufferDelegate:self queue:videoDataOutputQueue];

    if ([session canAddOutput:videoDataOutput]) {
        [session addOutput:videoDataOutput];
    }
    
    [[videoDataOutput connectionWithMediaType:AVMediaTypeVideo] setEnabled:YES];

    // Preview

    previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:session];
    [previewLayer setBackgroundColor:[[UIColor blackColor] CGColor]];
    [previewLayer setVideoGravity:AVLayerVideoGravityResizeAspect];
    // AVLayerVideoGravityResizeAspectFill
    
    CALayer* rootLayer = self.previewView.layer;
    [rootLayer setMasksToBounds:YES];
    [previewLayer setFrame:[rootLayer bounds]];
    [rootLayer addSublayer:previewLayer];
    
    // Kickoff
    
    [session startRunning];
    
    // Save options
    
    devicePosition = position;
}

- (void)teardownAVCapture {
    [session stopRunning];
    [previewLayer removeFromSuperlayer];
    [videoDataOutput setSampleBufferDelegate:nil queue:NULL];
    
    session = nil;
    videoDataOutput = nil;
    previewLayer = nil;
    
    videoDataOutputQueue = NULL;
}


- (BOOL)hasDeviceInPosition:(AVCaptureDevicePosition)position {
    return [self captureDeviceWithPosition:position] != nil;
}

/**
 * Returns the `AVCaptureDevice` with position and media type `AVMediaTypeVideo`,
 * or if a device at position cannot be found, returns the device with
 * `AVCaptureDevicePositionBack`.
 */

- (nullable AVCaptureDevice*)captureDeviceWithPosition:(AVCaptureDevicePosition)position {
    AVCaptureDevicePosition targetPosition = position == AVCaptureDevicePositionUnspecified
        ? AVCaptureDevicePositionBack
        : position;
    
    NSArray<AVCaptureDevice*> *devices =
        [[AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo]
        filter:^BOOL(AVCaptureDevice * _Nonnull device, NSUInteger idx, BOOL * _Nonnull stop) {
            return device.position == targetPosition;
        }];
    
    return devices.count > 0 ? devices[0] : nil;
}

- (void)presentError:(NSError*)error {
    NSString* title = [NSString stringWithFormat:@"Failed with error %d", (int)[error code]];
    
    UIAlertController* alertController = [UIAlertController
        alertControllerWithTitle:title
        message:[error localizedDescription]
        preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* dismiss = [UIAlertAction actionWithTitle:@"Dismiss" style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:dismiss];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (AVCaptureVideoOrientation)avOrientationForDeviceOrientation:(UIDeviceOrientation)deviceOrientation {
    AVCaptureVideoOrientation result = (AVCaptureVideoOrientation)(deviceOrientation);
    if (deviceOrientation == UIDeviceOrientationLandscapeLeft) {
        result = AVCaptureVideoOrientationLandscapeRight;
    } else if (deviceOrientation == UIDeviceOrientationLandscapeRight) {
        result = AVCaptureVideoOrientationLandscapeLeft;
    }
    return result;
}

- (IBAction)freezeVideo:(id)sender {
    if ([session isRunning]) {
        [session stopRunning];
        [self showPause];
    } else {
        [session startRunning];
    }
}

- (IBAction)swipeDeviceOrientation:(id)sender {
    if ( devicePosition == AVCaptureDevicePositionFront && [self hasDeviceInPosition:AVCaptureDevicePositionBack] ) {
        [self teardownAVCapture];
        [self setupAVCapture:AVCaptureDevicePositionBack];
    } else if ( devicePosition == AVCaptureDevicePositionBack && [self hasDeviceInPosition:AVCaptureDevicePositionFront] ) {
        [self teardownAVCapture];
        [self setupAVCapture:AVCaptureDevicePositionFront];
    } else {
        #ifdef DEBUG
        NSLog(@"Cannot change device position from current position, device unavailable");
        #endif
    }
}

- (void)showPause {
    UILabel *label = [self pauseLabel];
    label.center = self.view.center;
    
    [self.view addSubview:label];
    
    [UIView animateWithDuration:0.4 animations:^{
        label.transform = CGAffineTransformMakeScale(3.0, 3.0);
        label.alpha = 0;
    } completion:^(BOOL finished) {
        [label removeFromSuperview];
    }];
}

- (UILabel*)pauseLabel {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    
    label.font = [UIFont boldSystemFontOfSize:32];
    label.textColor = [UIColor whiteColor];
    label.text = @"Pause";
    
    label.layer.masksToBounds = NO;
    label.layer.shadowColor = [UIColor blackColor].CGColor;
    label.layer.shadowOffset = CGSizeMake(0, 0);
    label.layer.shadowRadius = 2.0;
    label.layer.shadowOpacity = 0.5;
    
    [label sizeToFit];
    
    return label;
}

- (void)captureOutput:(AVCaptureOutput*)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection*)connection {
    [self runModelOnFrame:CMSampleBufferGetImageBuffer(sampleBuffer)];
}

// MARK: - Photo Library & Camera

- (void)presentPhotoPicker:(UIImagePickerControllerSourceType)sourceType {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.sourceType = sourceType;
    picker.delegate = self;
    
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey,id> *)info {
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    [self setCaptureMode:CaptureModePhoto];
    [self setInfoHidden:NO];
    
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    [self runModelOnImage:image];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    [self setInfoHidden:NO];
    if (self.captureMode == CaptureModeLiveVideo && ![session isRunning]) {
        [session startRunning];
    }
}

- (void)setInfoHidden:(BOOL)hidden {
    [UIView animateWithDuration:0.1 animations:^{
        self.infoView.alpha = hidden ? 0 : 1;
    }];
}

// MARK: - Run Model

/**
 * Incoming pixelBuffer is guaranteed to be in the BGRA format: `kCMPixelFormat_32BGRA` ( `kCVPixelFormatType_32BGRA` ),
 * as specified when setting up the AVCaptureDevice.
 */

- (void)runModelOnFrame:(CVPixelBufferRef)pixelBuffer {
    
    auto const evaluator = [[CVPixelBufferEvaluator alloc] initWithPixelBuffer:pixelBuffer orientation:kCGImagePropertyOrientationRight model:self.model];
    
    [evaluator evaluateWithCompletionHandler:^(NSDictionary * _Nonnull result) {
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            
            id<ModelOutput> inference = result[kEvaluatorResultsKeyInferenceResults];
            const double inferenceLatency = [result[kEvaluatorResultsKeyInferenceLatency] doubleValue];
            const double preprocessingLatency = [result[kEvaluatorResultsKeyPreprocessingLatency] doubleValue];
            
            // Show results and latency
            
            [self.latencyCounter increaseImageProcessingLatency:preprocessingLatency];
            [self.latencyCounter increaseInferenceLatency:inferenceLatency];
            [self.latencyCounter incrementCount];
            
            [self showModelOutput:inference withDecay:YES];
            self.infoView.stats = [self modelStats:NO];
            
            // Visualize last pixel buffer used by model
    
            if ( [NSUserDefaults.standardUserDefaults boolForKey:kPrefsShowInputBuffers] ) {
                self.imageInputPreviewView.pixelBuffer = self.model.inputPixelBuffer;
            }

            #ifdef DEBUG
            NSLog(@"%@",[self modelStats:YES]);
            #endif
        });
    }];
}

/**
 * Our utility image.pixelBuffer method returns the pixel format in ARGB: `kCVPixelFormatType_32ARGB`
 */

- (void)runModelOnImage:(UIImage*)image {
    
    CVPixelBufferRef pixelBuffer = image.pixelBuffer; // Returns ARGB
    auto const evaluator = [[CVPixelBufferEvaluator alloc] initWithPixelBuffer:pixelBuffer orientation:kCGImagePropertyOrientationUp model:self.model];
    
    [evaluator evaluateWithCompletionHandler:^(NSDictionary * _Nonnull result) {
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            
            id <ModelOutput> inference = result[kEvaluatorResultsKeyInferenceResults];
            const double inferenceLatency = [result[kEvaluatorResultsKeyInferenceLatency] doubleValue];
            const double preprocessingLatency = [result[kEvaluatorResultsKeyPreprocessingLatency] doubleValue];
            
            // Show results and latency
            
            [self.latencyCounter increaseImageProcessingLatency:preprocessingLatency];
            [self.latencyCounter increaseInferenceLatency:inferenceLatency];
            [self.latencyCounter incrementCount];
            
            self.previousOutput = nil;
            [self showModelOutput:inference withDecay:NO];
            self.infoView.stats = [self modelStats:NO];
            
            // Preview
    
            self.photoImageView.image = image;
            
            // Visualize last pixel buffer used by model
    
            if ( [NSUserDefaults.standardUserDefaults boolForKey:kPrefsShowInputBuffers] ) {
                self.imageInputPreviewView.pixelBuffer = self.model.inputPixelBuffer;
            }

            #ifdef DEBUG
            NSLog(@"%@",[self modelStats:YES]);
            #endif
        });
    }];
}

- (BOOL)throttle:(NSTimeInterval)delta {
    NSDate *now = [NSDate date];
    NSTimeInterval diff = [now timeIntervalSinceDate:self.lastScreenUpdate];
    BOOL throttle = diff < delta;
    if (!throttle) { self.lastScreenUpdate = now; }
    return throttle;
}

- (NSString*)modelStats:(BOOL)verbose {
    if (verbose) {
        return [NSString stringWithFormat:
            @"Image preprocessing latency: %.1lfms, Inference latency: %.1lfms, Avg image preprocessing latency: %.1lfms, Avg inference latency: %.1lfms, count: %d",
                _latencyCounter.lastImageProcessingLatency,
                _latencyCounter.lastInferenceLatency,
                _latencyCounter.averageImageProcessingLatency,
                _latencyCounter.averageInferenceLatency,
                _latencyCounter.count
        ];
    } else {
        return [NSString stringWithFormat:
            @"Inference:\n %.1lfms\n\n Average (of %d):\n %.1lfms",
                _latencyCounter.lastInferenceLatency,
                _latencyCounter.count,
                _latencyCounter.averageInferenceLatency
        ];
    }
}

- (void)showModelOutput:(id<ModelOutput>)modelOutput withDecay:(BOOL)withDecay {
    if ( withDecay ) {
        self.infoView.classifications = [modelOutput decayedOutput:self.previousOutput].localizedDescription;
    } else {
        self.infoView.classifications = modelOutput.localizedDescription;
    }
    
    self.previousOutput = modelOutput;
}

@end
