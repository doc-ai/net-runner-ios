//
//  ImageEvaluator.m
//  tflite_camera_example
//
//  Created by Philip Dow on 7/18/18.
//  Copyright © 2018 doc.ai. All rights reserved.
//

#import "ImageEvaluator.h"

#import "VisionPipeline.h"
#import "UIImage+CVPixelBuffer.h"
#import "Utilities.h"
#import "ObjcDefer.h"

NSString * const kImageEvaluatorPreprocessingLatencyKey = @"preprocessor_latency";
NSString * const kImageEvaluatorInferenceLatencyKey = @"inference_latency";
NSString * const kInferenceResultsKey = @"inference_results";

NSString * const kImageEvaluatorPreprocessingErrorKey = @"preprocessor_error";
NSString * const kImageEvaluatorInferenceErrorKey = @"inference_error";

@interface ImageEvaluator ()

@property (readwrite) NSDictionary *results;
@property (readwrite) id<VisionModel> model;
@property (readwrite) UIImage *image;

@end

@implementation ImageEvaluator {
    dispatch_once_t _once;
}

- (instancetype)initWithImage:(UIImage*)image model:(id<VisionModel>)model {
    if (self = [super init]) {
        _image = image;
        _model = model;
    }
    
    return self;
}

- (void)evaluateWithCompletionHandler:(nullable EvaluatorCompletionBlock)completionHandler {
    dispatch_once (&_once, ^{
    
    defer_block {
        self.model = nil;
        self.image = nil;
    };
    
    double imageProcessingLatency;
    double inferenceLatency;
    
    // Ensure the model is loaded
    
    NSError *modelError;
    
    if ( ![self.model load:&modelError] ) {
        NSLog(@"Unable to load model, error: %@", modelError);
        self.results = @{
            kImageEvaluatorPreprocessingErrorKey: @"Unable to load model"
        };
        safe_block(completionHandler, self.results);
        return;
    }
    
    // Transform the image to the required format
    
    VisionPipeline *pipeline = [[VisionPipeline alloc] initWithVisionModel:self.model];
    __block CVPixelBufferRef transformedPixelBuffer = NULL;
    
    measuring_latency(&imageProcessingLatency, ^{
        CVPixelBufferRef pixelBuffer = [self.image pixelBuffer]; // Returns ARGB
        transformedPixelBuffer = [pipeline transform:pixelBuffer orientation:kCGImagePropertyOrientationUp];
    });
    
    if (transformedPixelBuffer == NULL) {
        NSLog(@"Unable to transform pixel buffer for model processing");
        self.results = @{
            kImageEvaluatorPreprocessingErrorKey: @"VisionPipeline returned NULL CVPixelBuffer"
        };
        safe_block(completionHandler, self.results);
        return;
    }
    
    // Make prediction
    
    __block NSDictionary *newValues;
    
    measuring_latency(&inferenceLatency, ^{
        newValues = [self.model runModelOn:transformedPixelBuffer];
    });
    
    if (newValues == nil) {
        NSLog(@"Running the model produced null results");
        self.results = @{
            kImageEvaluatorInferenceErrorKey: @"Model returned nil results"
        };
        safe_block(completionHandler, self.results);
        return;
    }
    
    self.results = @{
        kImageEvaluatorPreprocessingLatencyKey: @(imageProcessingLatency),
        kImageEvaluatorInferenceLatencyKey: @(inferenceLatency),
        kInferenceResultsKey: newValues
    };
    
    safe_block(completionHandler, self.results);
    
    }); // dispatch_once
}

@end
