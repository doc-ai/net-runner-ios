//
//  MainViewController.h
//  Net Runner
//
//  Created by Philip Dow on 7/26/18.
//  Copyright © 2018 doc.ai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

#import "SettingsTableViewController.h"

NS_ASSUME_NONNULL_BEGIN

@class ImageInputPreviewView;
@class ResultInfoView;
@class LatencyCounter;
@class ModelBundle;

@protocol Model;
@protocol VisionModel;

typedef enum : NSUInteger {
    CaptureModeLiveVideo,
    CaptureModePhoto,
} CaptureMode;

@interface MainViewController : UIViewController <UIGestureRecognizerDelegate, AVCaptureVideoDataOutputSampleBufferDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, SettingsTableViewControllerDelegate> {
    
    IBOutlet UIImageView *photoImageView;
    IBOutlet UIView* previewView;
    IBOutlet ImageInputPreviewView *imageInputPreviewView;
    
    AVCaptureVideoPreviewLayer* previewLayer;
    AVCaptureVideoDataOutput* videoDataOutput;
    AVCaptureSession* session;
    dispatch_queue_t videoDataOutputQueue;
    
    BOOL isUsingFrontFacingCamera;
    NSMutableDictionary* _oldPredictionValues;
   
    CaptureMode captureMode;
    NSDate *lastScreenUpdate;
   
    ResultInfoView *infoView;
    
    ModelBundle *_modelBundle;
    id<VisionModel> _model;
}

@property(strong, nonatomic) CATextLayer* predictionTextLayer;

@property LatencyCounter *latencyCounter;

- (IBAction)selectInputSource:(id)sender;

@end

NS_ASSUME_NONNULL_END
