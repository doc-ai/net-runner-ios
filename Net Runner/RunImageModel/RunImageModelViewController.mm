//
//  RunImageModelViewController.mm
//  Net Runner
//
//  Created by Philip Dow on 7/26/18.
//  Copyright © 2018 doc.ai (http://doc.ai)
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import "RunImageModelViewController.h"

@import AssetsLibrary;
@import CoreImage;
@import ImageIO;
@import VideoToolbox;

#import <AssertMacros.h>

#import "ResultInfoView.h"
#import "LatencyCounter.h"
#import "ImageSettingsTableViewController.h"
#import "Utilities.h"
#import "ImageInputPreviewView.h"
#import "UserDefaults.h"
#import "CVPixelBufferEvaluator.h"
#import "EvaluatorConstants.h"
#import "ModelOutput.h"

@import TensorIO;

// MARK: -

typedef enum : NSUInteger {
    CaptureModeLiveVideo,
    CaptureModePhoto,
} CaptureMode;

@interface RunImageModelViewController ()

@property (nonatomic) CaptureMode captureMode;
@property LatencyCounter *latencyCounter;

@property id<TIOModel> model;
@property id<ModelOutput> previousOutput;

@property AVCaptureSession *session;
@property AVCaptureDevicePosition devicePosition;
@property AVCaptureVideoPreviewLayer *previewLayer;
@property AVCaptureVideoDataOutput *videoDataOutput;
@property dispatch_queue_t videoDataOutputQueue;

@end

// MARK: -

@implementation RunImageModelViewController

- (void)dealloc {
  [self teardownAVCapture];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // UI
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(freezeVideo:)];
    [self.previewView addGestureRecognizer:tapRecognizer];
    
    UISwipeGestureRecognizer *swipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeDeviceOrientation:)];
    swipeRecognizer.direction = ( UISwipeGestureRecognizerDirectionRight | UISwipeGestureRecognizerDirectionLeft );
    [self.previewView addGestureRecognizer:swipeRecognizer];
    
    self.view.backgroundColor = UIColor.blackColor;
    self.previewView.backgroundColor = UIColor.blackColor;
    self.photoImageView.backgroundColor = UIColor.blackColor;

    // Load the target model

    [self loadModelFromBundle:self.modelBundle];
    
    // Preferences
    
    self.imageInputPreviewView.hidden = ![NSUserDefaults.standardUserDefaults boolForKey:kPrefsShowInputBuffers];
    self.imageInputPreviewView.showsAlphaChannel = [NSUserDefaults.standardUserDefaults boolForKey:kPrefsShowInputBufferAlpha];
    
    // Prepare capture
    
    if ( self.model != nil ) {
        if ( [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo] != AVAuthorizationStatusAuthorized ) {
            [self requestCameraAccess];
        } else {
            [self setupAVCapture:self.model.options.devicePosition];
            [self setCaptureMode:CaptureModeLiveVideo];
        }
    }
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    CALayer* rootLayer = self.previewView.layer;
    [self.previewLayer setFrame:[rootLayer bounds]];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
#if TARGET_OS_SIMULATOR
    return;
#endif

    if (self.captureMode == CaptureModeLiveVideo && [self.session isRunning]) {
        [self.session stopRunning];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.imageInputPreviewView.hidden = ![NSUserDefaults.standardUserDefaults boolForKey:kPrefsShowInputBuffers];
    self.imageInputPreviewView.showsAlphaChannel = [NSUserDefaults.standardUserDefaults boolForKey:kPrefsShowInputBufferAlpha];
    
#if TARGET_OS_SIMULATOR
    return;
#endif
    
    if (self.captureMode == CaptureModeLiveVideo && ![self.session isRunning] && self.model != nil) {
        [self.session startRunning];
    }
}

// MARK: - Load Model

/**
 * Loads a new instance of a model from a model bundle.
 * This method has no effect if the model bundle is already the loaded model bundle.
 *
 * @param bundle the `TIOModelBundle` to load
 *
 * @return BOOL `YES` if a new model was loaded, `NO` if not
 */

- (BOOL)loadModelFromBundle:(nonnull TIOModelBundle*)bundle {
    NSError *modelError;
    
    self.model = [self.modelBundle newModel];
    
    if ( self.model == nil ) {
        NSLog(@"Unable to find and instantiate model with id %@", bundle.identifier);
        [self showLoadModelAlert:@"Could not instantiate the model. Ensure the class corresponding to this model is available."];
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
    
    __block TIOPixelBufferLayerDescription *description = nil;
    
    [self.model.io.inputs[0] matchCasePixelBuffer:^(TIOPixelBufferLayerDescription * _Nonnull pixelBufferDescription) {
        description = pixelBufferDescription;
    } caseVector:^(TIOVectorLayerDescription * _Nonnull vectorDescription) {
        ;
    } caseString:^(TIOStringLayerDescription * _Nonnull stringDescription) {
        ;
    }];
    
    if (description == nil) {
        NSLog(@"Model does not contain an image input at index 0, model id: %@", bundle.identifier);
        [self showLoadModelAlert:@"Model does not contain an image input in the first layer"];
        self.modelBundle = nil;
        self.model = nil;
        return NO;
    }
    
    self.title = self.model.name;
    self.imageInputPreviewView.pixelFormat = description.pixelFormat;

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

// MARK: - Capture Mode

- (IBAction)selectInputSource:(id)sender {
    if ( UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad ) {
        [self setInfoHidden:YES];
    }
    
#if !(TARGET_OS_SIMULATOR)
    if ([self.session isRunning]) {
        [self.session stopRunning];
    }
#endif
    
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
    
    photoSourcePicker.popoverPresentationController.barButtonItem = (UIBarButtonItem*)sender;
    photoSourcePicker.popoverPresentationController.sourceView = self.view;
    
#if !(TARGET_OS_SIMULATOR)
    [photoSourcePicker addAction:takePicture];
#endif
    [photoSourcePicker addAction:choosePhoto];
    [photoSourcePicker addAction:liveVideo];
    [photoSourcePicker addAction:cancel];
    
    [self presentViewController:photoSourcePicker animated:YES completion:nil];
}

- (void)didSelectLiveVideoInputSource {
    [self setCaptureMode:CaptureModeLiveVideo];
    [self setInfoHidden:NO];
    
    self.previousOutput = nil;
    
#if TARGET_OS_SIMULATOR
    [self setupSimulatedAVCapture];
    return;
#endif
    
    if (![self.session isRunning]) {
        [self.session startRunning];
    }
}

- (void)didCancelInputSourcePicker {
    [self setInfoHidden:NO];
    
    self.previousOutput = nil;
    
#if TARGET_OS_SIMULATOR
    if (self.captureMode == CaptureModeLiveVideo) {
        [self setupSimulatedAVCapture];
    }
    return;
#endif
    
    if (self.captureMode == CaptureModeLiveVideo && ![self.session isRunning]) {
        [self.session startRunning];
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

// MARK: - Camera Access

- (void)requestCameraAccess {
    __weak typeof(self) weakself = self;
    
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            if ( !granted ){
                [weakself showCameraUnauthorizedAlert];
            } else {
                [weakself setupAVCapture:self.model.options.devicePosition];
                [weakself setCaptureMode:CaptureModeLiveVideo];
            }
        });
    }];
}

- (void)showCameraUnauthorizedAlert {
    UIAlertController *alert = [UIAlertController
        alertControllerWithTitle:NSLocalizedString(@"Unable to access camera", @"Camera access unauthorized alert tite")
        message:NSLocalizedString(@"Please grant access to your device's camera", @"Camera access unauthorized alert message")
        preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addAction:[UIAlertAction
        actionWithTitle:NSLocalizedString(@"Dismiss", @"Camera access unauthorized dismiss action")
        style:UIAlertActionStyleCancel
        handler:nil]];
    
    [alert addAction:[UIAlertAction
        actionWithTitle:NSLocalizedString(@"Grant Access", @"Camera access unauthorized grant access action")
        style:UIAlertActionStyleDefault
        handler:^(UIAlertAction * _Nonnull action) {
            [UIApplication.sharedApplication openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:@{} completionHandler:nil];
        }]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

// MARK: - AV Capture

- (void)setupAVCapture:(AVCaptureDevicePosition)position {
    
    if ( [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo] != AVAuthorizationStatusAuthorized ) {
        return;
    }
    
#if TARGET_OS_SIMULATOR
    [self setupSimulatedAVCapture];
    return;
#endif
    
    // Session
    
    self.session = [AVCaptureSession new];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        [self.session setSessionPreset:AVCaptureSessionPreset640x480];
    } else {
        [self.session setSessionPreset:AVCaptureSessionPresetPhoto];
    }
    
    // Device and input
    
    NSError* error = nil;
    AVCaptureDevice *device = [self captureDeviceWithPosition:position];
    AVCaptureDeviceInput *deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];

    if (error != nil) {
        NSLog(@"Failed to initialize AVCaptureDeviceInput, error %@", error);
        [self showAVCaptureDeviceErrorAlert];
        [self teardownAVCapture];
        return;
    }

    if ([self.session canAddInput:deviceInput]) {
        [self.session addInput:deviceInput];
    }
    
    // Output

    self.videoDataOutputQueue = dispatch_queue_create("VideoDataOutputQueue", DISPATCH_QUEUE_SERIAL);
    self.videoDataOutput = [AVCaptureVideoDataOutput new];

    NSDictionary *rgbOutputSettings = @{
        (NSString*)kCVPixelBufferPixelFormatTypeKey: @(kCMPixelFormat_32BGRA)
    };
    
    [[self.videoDataOutput connectionWithMediaType:AVMediaTypeVideo] setVideoOrientation:AVCaptureVideoOrientationPortrait];
    [self.videoDataOutput setAlwaysDiscardsLateVideoFrames:YES];
    [self.videoDataOutput setVideoSettings:rgbOutputSettings];
    
    [self.videoDataOutput setSampleBufferDelegate:self queue:self.videoDataOutputQueue];

    if ([self.session canAddOutput:self.videoDataOutput]) {
        [self.session addOutput:self.videoDataOutput];
    }
    
    [[self.videoDataOutput connectionWithMediaType:AVMediaTypeVideo] setEnabled:YES];

    // Preview

    self.previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
    [self.previewLayer setBackgroundColor:[[UIColor blackColor] CGColor]];
    [self.previewLayer setVideoGravity:AVLayerVideoGravityResizeAspect];
    // AVLayerVideoGravityResizeAspectFill
    
    CALayer* rootLayer = self.previewView.layer;
    [rootLayer setMasksToBounds:YES];
    [self.previewLayer setFrame:[rootLayer bounds]];
    [rootLayer addSublayer:self.previewLayer];
    
    // Kickoff
    
    [self.session startRunning];
    
    // Save options
    
    self.devicePosition = position;
}

- (void)setupSimulatedAVCapture {

#if TARGET_OS_SIMULATOR
    
    UIImage *image = [UIImage imageNamed:@"simulator-video-input"];
    CVPixelBufferRef pixelBuffer = TIOCVPixelBufferRotate(image.pixelBuffer, Rotate90Degrees);
    CMSampleBufferRef sampleBuffer = NULL;
    CMSampleTimingInfo timimgInfo = kCMTimingInfoInvalid;
    CMVideoFormatDescriptionRef videoInfo = NULL;
    
    CMVideoFormatDescriptionCreateForImageBuffer(NULL, pixelBuffer, &videoInfo);
    
    CMSampleBufferCreateForImageBuffer(
        kCFAllocatorDefault,
        pixelBuffer,
        true,
        NULL,
        NULL,
        videoInfo,
        &timimgInfo,
        &sampleBuffer
    );
    
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Wnonnull"
    
    [self captureOutput:nil didOutputSampleBuffer:sampleBuffer fromConnection:nil];
    
    #pragma clang diagnostic pop
    
    self.previewView.backgroundColor = UIColor.blackColor;
    self.previewView.layer.contentsGravity = kCAGravityResizeAspect;
    self.previewView.layer.contents = (id)image.CGImage;

    CFRelease(sampleBuffer);
    CVPixelBufferRelease(pixelBuffer);
    
#endif
}

- (void)showAVCaptureDeviceErrorAlert {
    UIAlertController *alert = [UIAlertController
        alertControllerWithTitle:NSLocalizedString(@"Unable to access your camera", @"Camera access error alert title")
        message:NSLocalizedString(@"There was an unknown problem accessing your device's camera", @"Camera access error alert message alert message")
        preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addAction:[UIAlertAction
        actionWithTitle:NSLocalizedString(@"Dismiss", @"Camera access error alert dismiss action")
        style:UIAlertActionStyleDefault
        handler:nil]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)teardownAVCapture {

#if TARGET_OS_SIMULATOR
    return;
#endif

    [self.session stopRunning];
    [self.previewLayer removeFromSuperlayer];
    [self.videoDataOutput setSampleBufferDelegate:nil queue:NULL];
    
    self.session = nil;
    self.videoDataOutput = nil;
    self.previewLayer = nil;
    
    self.videoDataOutputQueue = NULL;
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

#if TARGET_OS_SIMULATOR
    return nil;
#endif

    AVCaptureDevicePosition targetPosition = position == AVCaptureDevicePositionUnspecified
        ? AVCaptureDevicePositionBack
        : position;
    
    AVCaptureDeviceDiscoverySession *discovery = [AVCaptureDeviceDiscoverySession discoverySessionWithDeviceTypes:@[AVCaptureDeviceTypeBuiltInWideAngleCamera] mediaType:AVMediaTypeVideo position:targetPosition];
    
    NSArray<AVCaptureDevice*> *devices = discovery.devices;
    
    return devices.count > 0 ? devices[0] : nil;
}

- (AVCaptureVideoOrientation)AVOrientationForDeviceOrientation:(UIDeviceOrientation)deviceOrientation {
    AVCaptureVideoOrientation result = (AVCaptureVideoOrientation)(deviceOrientation);
    if (deviceOrientation == UIDeviceOrientationLandscapeLeft) {
        result = AVCaptureVideoOrientationLandscapeRight;
    } else if (deviceOrientation == UIDeviceOrientationLandscapeRight) {
        result = AVCaptureVideoOrientationLandscapeLeft;
    }
    return result;
}

- (IBAction)freezeVideo:(id)sender {
    
#if TARGET_OS_SIMULATOR
    return;
#endif

    if ([self.session isRunning]) {
        [self.session stopRunning];
        [self showPause];
    } else {
        [self.session startRunning];
    }
}

- (IBAction)swipeDeviceOrientation:(id)sender {
    
#if TARGET_OS_SIMULATOR
    return;
#endif

    if ( self.devicePosition == AVCaptureDevicePositionFront && [self hasDeviceInPosition:AVCaptureDevicePositionBack] ) {
        [self teardownAVCapture];
        [self setupAVCapture:AVCaptureDevicePositionBack];
    } else if ( self.devicePosition == AVCaptureDevicePositionBack && [self hasDeviceInPosition:AVCaptureDevicePositionFront] ) {
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

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString*,id> *)info {
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    [self setCaptureMode:CaptureModePhoto];
    [self setInfoHidden:NO];
    
    self.previousOutput = nil;
    
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    [self runModelOnImage:image];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    [self setInfoHidden:NO];
    
    self.previousOutput = nil;
    
    if (self.captureMode == CaptureModeLiveVideo && ![self.session isRunning]) {
        [self.session startRunning];
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
    
    auto const evaluator = [[CVPixelBufferEvaluator alloc] initWithModel:self.model pixelBuffer:pixelBuffer orientation:kCGImagePropertyOrientationRight];
    
    [evaluator evaluateWithCompletionHandler:^(NSDictionary * _Nonnull result, CVPixelBufferRef _Nullable inputPixelBuffer) {
        CVPixelBufferRetain(inputPixelBuffer); // No ARC bridging boo
        
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
                self.imageInputPreviewView.pixelBuffer = inputPixelBuffer;
            }

            // Cleanup
    
            CVPixelBufferRelease(inputPixelBuffer);

            #ifdef DEBUG
            NSLog(@"%@",[self modelStats:YES]);
            #endif
        });
    }];
}

/**
 * Run the model on an image.
 * Our utility image.pixelBuffer method returns the pixel format in ARGB: `kCVPixelFormatType_32ARGB`
 */

- (void)runModelOnImage:(UIImage*)image {
    
    auto const evaluator = [[CVPixelBufferEvaluator alloc] initWithModel:self.model pixelBuffer:image.pixelBuffer orientation:kCGImagePropertyOrientationUp];
    
    [evaluator evaluateWithCompletionHandler:^(NSDictionary * _Nonnull result, CVPixelBufferRef _Nullable inputPixelBuffer) {
        CVPixelBufferRetain(inputPixelBuffer); // No ARC bridging boo
        
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            
            id <ModelOutput> inference = result[kEvaluatorResultsKeyInferenceResults];
            const double inferenceLatency = [result[kEvaluatorResultsKeyInferenceLatency] doubleValue];
            const double preprocessingLatency = [result[kEvaluatorResultsKeyPreprocessingLatency] doubleValue];
            
            // Show results and latency
            
            [self.latencyCounter increaseImageProcessingLatency:preprocessingLatency];
            [self.latencyCounter increaseInferenceLatency:inferenceLatency];
            [self.latencyCounter incrementCount];
            
            [self showModelOutput:inference withDecay:NO];
            self.infoView.stats = [self modelStats:NO];
            
            // Preview
    
            self.photoImageView.image = image;
            
            // Visualize last pixel buffer used by model
    
            if ( [NSUserDefaults.standardUserDefaults boolForKey:kPrefsShowInputBuffers] ) {
                self.imageInputPreviewView.pixelBuffer = inputPixelBuffer;
            }

            // Cleanup

            CVPixelBufferRelease(inputPixelBuffer);

            #ifdef DEBUG
            NSLog(@"%@",[self modelStats:YES]);
            #endif
        });
    }];
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
            @"Latency:\n %.1lfms\n\n Average (of %d):\n %.1lfms",
                _latencyCounter.lastInferenceLatency,
                _latencyCounter.count,
                _latencyCounter.averageInferenceLatency
        ];
    }
}

- (void)showModelOutput:(id<ModelOutput>)modelOutput withDecay:(BOOL)withDecay {
    if ( withDecay ) {
        modelOutput = [modelOutput decayedOutput:self.previousOutput];
    }
    
    self.infoView.classifications = modelOutput.localizedDescription;
    self.previousOutput = modelOutput;
}

@end
