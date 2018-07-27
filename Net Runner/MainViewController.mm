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

#import "ModelManager.h"
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

#define LOG(x) std::cerr

// MARK: -

@implementation MainViewController

- (void)dealloc {
  [self teardownAVCapture];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    lastScreenUpdate = [NSDate date];

    // UI
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(freezeVideo:)];
    [previewView addGestureRecognizer:tapRecognizer];
    
    infoView = [[ResultInfoView alloc] init];
    [self.view addSubview:infoView];
    
    infoView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [NSLayoutConstraint activateConstraints:@[
        [infoView.rightAnchor constraintEqualToAnchor:self.view.rightAnchor constant:-16],
        [infoView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor constant:-26],
        [infoView.leftAnchor constraintEqualToAnchor:self.view.leftAnchor constant:16],
        [infoView.heightAnchor constraintGreaterThanOrEqualToConstant:40]
    ]];

    // Load default model
    
    NSString *modelId = [NSUserDefaults.standardUserDefaults stringForKey:kPrefsSelectedModelID];
    NSError *modelError;
    
    _modelBundle = [ModelManager.sharedManager bundleWithId:modelId];
    _model = (id<VisionModel>)[_modelBundle newModel];
    
    if ( _model == nil ) {
        NSLog(@"Unable to find and instantiate model with id %@", modelId);
        _modelBundle = nil;
        _model = nil;
    }
    
    if ( ![_model conformsToProtocol:@protocol(VisionModel)] ) {
        NSLog(@"Model does not conform to protocol VisionModel, id: %@", modelId);
        _modelBundle = nil;
        _model = nil;
    }
    
    if ( ![_model load:&modelError] ) {
        NSLog(@"Model does could not be loaded, id: %@, error: %@", modelId, modelError);
        _modelBundle = nil;
        _model = nil;
    }
    
    self.title = _model.name;
    imageInputPreviewView.pixelFormat = _model.pixelFormat;

    _oldPredictionValues = [[NSMutableDictionary alloc] init];
    self.latencyCounter = [[LatencyCounter alloc] init];
    
    // Preferences
    
    imageInputPreviewView.hidden = ![NSUserDefaults.standardUserDefaults boolForKey:kPrefsShowInputBuffers];
    imageInputPreviewView.showsAlphaChannel = [NSUserDefaults.standardUserDefaults boolForKey:kPrefsShowInputBufferAlpha];
    
    // Prepare capture

    [self setupAVCapture];
    [self setCaptureMode:CaptureModeLiveVideo];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    CALayer* rootLayer = [previewView layer];
    [previewLayer setFrame:[rootLayer bounds]];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if (captureMode == CaptureModeLiveVideo && [session isRunning]) {
        [session stopRunning];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (captureMode == CaptureModeLiveVideo && ![session isRunning]) {
        [session startRunning];
    }
}

- (void)willMoveToParentViewController:(UIViewController *)parent {
    [super willMoveToParentViewController:parent];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ( [segue.identifier isEqualToString:@"SettingsSegue"] ) {
        SettingsTableViewController *destination = (SettingsTableViewController*)segue.destinationViewController;
        destination.selectedBundle = _modelBundle;
        destination.delegate = self;
    }
}

// MARK: - Settings Delegate

- (void)settingsTableViewControllerWillDisappear:(SettingsTableViewController*)viewController {
    
    // Model
    
    if ( viewController.selectedBundle != _modelBundle ) {
        
        ModelBundle *newBundle = viewController.selectedBundle;
        id<Model> newModel = [newBundle newModel];
        
        if ( newModel == nil ) {
            NSLog(@"Unable to instantiate model from bundle %@", _modelBundle.identifier);
            _modelBundle = nil;
            _model = nil;
            return;
        }
        
        if ( ![newModel conformsToProtocol:@protocol(VisionModel)] ) {
            NSLog(@"Model does not conform to vision model protocol");
            _modelBundle = nil;
            _model = nil;
            return;
        }
        
        _modelBundle = newBundle;
        _model = (id<VisionModel>)newModel;
        
        self.title = _model.name;
        imageInputPreviewView.pixelFormat = _model.pixelFormat;
        
        _oldPredictionValues = [NSMutableDictionary dictionary];
        self.latencyCounter = [[LatencyCounter alloc] init];
    }
    
    // Other Settings
    
    imageInputPreviewView.hidden = ![NSUserDefaults.standardUserDefaults boolForKey:kPrefsShowInputBuffers];
    imageInputPreviewView.showsAlphaChannel = [NSUserDefaults.standardUserDefaults boolForKey:kPrefsShowInputBufferAlpha];
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
    if (captureMode == CaptureModeLiveVideo && ![session isRunning]) {
        [session startRunning];
    }
}

- (void)setCaptureMode:(CaptureMode)mode {
    captureMode = mode;
    
    switch (mode) {
    case CaptureModeLiveVideo:
        photoImageView.hidden = YES;
        previewView.hidden = NO;
        break;
    case CaptureModePhoto:
        photoImageView.hidden = NO;
        previewView.hidden = YES;
        break;
    }
}

// MARK: - AV Capture

- (void)setupAVCapture {
    NSError* error = nil;
    
    // Session
    
    session = [AVCaptureSession new];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        [session setSessionPreset:AVCaptureSessionPreset640x480];
    } else {
        [session setSessionPreset:AVCaptureSessionPresetPhoto];
    }
    
    // Device and input

    AVCaptureDevice* device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    AVCaptureDeviceInput* deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];

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
    
    CALayer* rootLayer = [previewView layer];
    [rootLayer setMasksToBounds:YES];
    [previewLayer setFrame:[rootLayer bounds]];
    [rootLayer addSublayer:previewLayer];
    
    // Kickoff
    
    [session startRunning];
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

- (void)teardownAVCapture {
  [previewLayer removeFromSuperlayer];
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
    if (captureMode == CaptureModeLiveVideo && ![session isRunning]) {
        [session startRunning];
    }
}

- (void)setInfoHidden:(BOOL)hidden {
    [UIView animateWithDuration:0.1 animations:^{
        self->infoView.alpha = hidden ? 0 : 1;
    }];
}

// MARK: - Run Model

/*
 * Incoming pixelBuffer is guaranteed to be in the BGRA format: kCMPixelFormat_32BGRA, as specified
 * when setting up the AVCaptureDevice
 */

 // TODO: Use the ImageEvaluator or a PixelBuffer Evaluator to run the vision pipeline and model

- (void)runModelOnFrame:(CVPixelBufferRef)pixelBuffer {
    
    auto const evaluator = [[CVPixelBufferEvaluator alloc] initWithPixelBuffer:pixelBuffer orientation:kCGImagePropertyOrientationRight model:_model];
    
    [evaluator evaluateWithCompletionHandler:^(NSDictionary * _Nonnull result) {
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            
            NSDictionary *inference = result[kEvaluatorResultsKeyInferenceResults];
            const double inferenceLatency = [result[kEvaluatorResultsKeyInferenceLatency] doubleValue];
            const double preprocessingLatency = [result[kEvaluatorResultsKeyPreprocessingLatency] doubleValue];
            
            // Show results and latency
            
            [self.latencyCounter increaseImageProcessingLatency:preprocessingLatency];
            [self.latencyCounter increaseInferenceLatency:inferenceLatency];
            [self.latencyCounter incrementCount];
            
            [self setPredictionValues:inference withDecay:YES];
            self->infoView.stats = [self modelStats:NO];
            
            // Visualize last pixel buffer used by model
    
            if ( [NSUserDefaults.standardUserDefaults boolForKey:kPrefsShowInputBuffers] ) {
                self->imageInputPreviewView.pixelBuffer = [self->_model inputPixelBuffer];
            }

            #ifdef DEBUG
            NSLog(@"%@",[self modelStats:YES]);
            #endif
        });
    }];
}

- (void)runModelOnImage:(UIImage*)image {
    
    CVPixelBufferRef pixelBuffer = image.pixelBuffer; // Returns ARGB
    auto const evaluator = [[CVPixelBufferEvaluator alloc] initWithPixelBuffer:pixelBuffer orientation:kCGImagePropertyOrientationUp model:_model];
    
    [evaluator evaluateWithCompletionHandler:^(NSDictionary * _Nonnull result) {
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            
            NSDictionary *inference = result[kEvaluatorResultsKeyInferenceResults];
            const double inferenceLatency = [result[kEvaluatorResultsKeyInferenceLatency] doubleValue];
            const double preprocessingLatency = [result[kEvaluatorResultsKeyPreprocessingLatency] doubleValue];
            
            // Show results and latency
            
            [self.latencyCounter increaseImageProcessingLatency:preprocessingLatency];
            [self.latencyCounter increaseInferenceLatency:inferenceLatency];
            [self.latencyCounter incrementCount];
            
            self->_oldPredictionValues = [NSMutableDictionary dictionary];
            [self setPredictionValues:inference withDecay:YES];
            self->infoView.stats = [self modelStats:NO];
            
            // Preview
    
            self->photoImageView.image = image;
            
            // Visualize last pixel buffer used by model
    
            if ( [NSUserDefaults.standardUserDefaults boolForKey:kPrefsShowInputBuffers] ) {
                self->imageInputPreviewView.pixelBuffer = [self->_model inputPixelBuffer];
            }

            #ifdef DEBUG
            NSLog(@"%@",[self modelStats:YES]);
            #endif
        });
    }];
}

- (BOOL)throttle:(NSTimeInterval)delta {
    NSDate *now = [NSDate date];
    NSTimeInterval diff = [now timeIntervalSinceDate:lastScreenUpdate];
    BOOL throttle = diff < delta;
    if (!throttle) { lastScreenUpdate = now; }
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

- (void)setPredictionValues:(NSDictionary*)newValues withDecay:(BOOL)withDecay {
//    const float decayValue = 0.75f;
//    const float updateValue = 0.25f;
//    const float minimumThreshold = 0.01f;
//
//    NSMutableArray *candidateLabels = [NSMutableArray array];
//
//    if (withDecay) {
//
//        NSMutableDictionary* decayedPredictionValues = [[NSMutableDictionary alloc] init];
//
//        for (NSString* label in _oldPredictionValues) {
//            NSNumber* oldPredictionValueObject = [_oldPredictionValues objectForKey:label];
//            const float oldPredictionValue = [oldPredictionValueObject floatValue];
//            const float decayedPredictionValue = (oldPredictionValue * decayValue);
//            if (decayedPredictionValue > minimumThreshold) {
//                NSNumber* decayedPredictionValueObject = [NSNumber numberWithFloat:decayedPredictionValue];
//                [decayedPredictionValues setObject:decayedPredictionValueObject forKey:label];
//            }
//        }
//
//        _oldPredictionValues = decayedPredictionValues;
//
//        for (NSString* label in newValues) {
//            NSNumber* newPredictionValueObject = [newValues objectForKey:label];
//            NSNumber* oldPredictionValueObject = [_oldPredictionValues objectForKey:label];
//            if (!oldPredictionValueObject) {
//                oldPredictionValueObject = [NSNumber numberWithFloat:0.0f];
//            }
//            const float newPredictionValue = [newPredictionValueObject floatValue];
//            const float oldPredictionValue = [oldPredictionValueObject floatValue];
//            const float updatedPredictionValue = (oldPredictionValue + (newPredictionValue * updateValue));
//            NSNumber* updatedPredictionValueObject = [NSNumber numberWithFloat:updatedPredictionValue];
//            [_oldPredictionValues setObject:updatedPredictionValueObject forKey:label];
//        }
//
//        for (NSString* label in _oldPredictionValues) {
//            NSNumber* oldPredictionValueObject = [_oldPredictionValues objectForKey:label];
//            const float oldPredictionValue = [oldPredictionValueObject floatValue];
//            if (oldPredictionValue > 0.05f) {
//                NSDictionary* entry = @{@"label" : label, @"value" : oldPredictionValueObject};
//                candidateLabels = [candidateLabels arrayByAddingObject:entry];
//            }
//        }
//
//    } else {
//
//        for (NSString* label in newValues) {
//            NSNumber* oldPredictionValueObject = [newValues objectForKey:label];
//            const float oldPredictionValue = [oldPredictionValueObject floatValue];
//            if (oldPredictionValue > 0.05f) {
//                NSDictionary* entry = @{@"label" : label, @"value" : oldPredictionValueObject};
//                candidateLabels = [candidateLabels arrayByAddingObject:entry];
//            }
//        }
//    }
    
    NSMutableArray *candidateLabels = [NSMutableArray array];
    
    for ( NSString *label in newValues ) {
        [candidateLabels addObject:@{
            @"label" : label,
            @"value" : [newValues objectForKey:label]
        }];
    }
    
    NSSortDescriptor* sort = [NSSortDescriptor sortDescriptorWithKey:@"value" ascending:NO];
    NSArray* sortedLabels = [candidateLabels sortedArrayUsingDescriptors:[NSArray arrayWithObject:sort]];

    // NSMutableString *classificationsString = [@"Classifications:\n" mutableCopy];
    NSMutableString *classificationsString = [NSMutableString string];
    NSInteger count = 0;

    for (NSDictionary* entry in sortedLabels) {
        NSString* label = [entry objectForKey:@"label"];
        const int percentage = (int)roundf([[entry objectForKey:@"value"] floatValue] * 100.0f);
        [classificationsString appendFormat:@"  (%.2f) %@\n", percentage / 100.0f, label];
        count++;
    }
    
    for (NSInteger i = count; i < 5-1; i++ ) {
        [classificationsString appendString:@"\n"];
    }

    infoView.classifications = classificationsString;
}

@end
