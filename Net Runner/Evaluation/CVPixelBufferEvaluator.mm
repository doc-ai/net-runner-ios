//
//  CVPixelBufferEvaluator.m
//  Net Runner
//
//  Created by Philip Dow on 7/26/18.
//  Copyright © 2018 doc.ai. All rights reserved.
//

#import "CVPixelBufferEvaluator.h"

#import "EvaluatorConstants.h"
#import "TIOVisionPipeline.h"
#import "Utilities.h"
#import "TIOObjcDefer.h"
#import "ModelOutput.h"
#import "ModelOutputManager.h"
#import "TIOPixelBufferLayerDescription.h"
#import "TIOPixelBuffer.h"
#import "NSDictionary+TIOData.h"

@interface CVPixelBufferEvaluator ()

@property (readwrite) id<TIOModel> model;
@property (nonatomic, readwrite) CVPixelBufferRef pixelBuffer;
@property (readwrite) CGImagePropertyOrientation orientation;

@end

@implementation CVPixelBufferEvaluator {
    dispatch_once_t _once;
}

- (instancetype)initWithModel:(id<TIOModel>)model pixelBuffer:(CVPixelBufferRef)pixelBuffer orientation:(CGImagePropertyOrientation)orientation {
    if (self = [super init]) {
        _model = model;
        _orientation = orientation;
        _pixelBuffer = pixelBuffer;
        CVPixelBufferRetain(_pixelBuffer);
    }
    
    return self;
}

- (void)dealloc {
    CVPixelBufferRelease(_pixelBuffer);
    _pixelBuffer = NULL;
}

- (void)setPixelBuffer:(CVPixelBufferRef _Nullable)pixelBuffer {
    CVPixelBufferRelease(_pixelBuffer);
    _pixelBuffer = pixelBuffer;
    CVPixelBufferRetain(_pixelBuffer);
}

- (void)evaluateWithCompletionHandler:(nullable EvaluatorCompletionBlock)completionHandler {
    dispatch_once(&_once, ^{
    
    tio_defer_block {
        self.model = nil;
        self.pixelBuffer = NULL;
    };
    
    double imageProcessingLatency;
    double inferenceLatency;
    
    // Ensure the model is loaded
    
    NSError *modelError;
    
    if ( ![self.model load:&modelError] ) {
        NSLog(@"Unable to load model, error: %@", modelError);
        NSDictionary *results = @{
            kEvaluatorResultsKeyPreprocessingError: @"Unable to load model"
        };
        safe_block(completionHandler, results, NULL);
        return;
    }
    
    // Transform the image to the required format
    
    TIOPixelBufferLayerDescription *description = [self.model descriptionOfInputAtIndex:0];
    TIOVisionPipeline *pipeline = [[TIOVisionPipeline alloc] initWithTIOPixelBufferDescription:description];
    __block CVPixelBufferRef transformedPixelBuffer = NULL;
    
    measuring_latency(&imageProcessingLatency, ^{
        transformedPixelBuffer = [pipeline transform:self.pixelBuffer orientation:self.orientation];
    });
    
    if (transformedPixelBuffer == NULL) {
        NSLog(@"Unable to transform pixel buffer for model processing");
        NSDictionary *results = @{
            kEvaluatorResultsKeyPreprocessingError: @"TIOVisionPipeline returned NULL CVPixelBuffer"
        };
        safe_block(completionHandler, results, NULL);
        return;
    }
    
    // Make prediction
    
    __block NSDictionary *results;
    TIOPixelBuffer *pixelBufferWrapper = [[TIOPixelBuffer alloc] initWithPixelBuffer:transformedPixelBuffer orientation:kCGImagePropertyOrientationUp];
    
    measuring_latency(&inferenceLatency, ^{
        results = (NSDictionary*)[self.model runOn:pixelBufferWrapper];
    });
    
    id<ModelOutput> modelOutput = [[[[ModelOutputManager sharedManager] classForType:self.model.type] alloc] initWithDictionary:results];
    
    if (modelOutput == nil) {
        NSLog(@"Running the model produced null results");
        NSDictionary *results = @{
            kEvaluatorResultsKeyInferenceError: @"Model returned nil results"
        };
        safe_block(completionHandler, results, NULL);
        return;
    }
    
    NSDictionary *evaluatorResults = @{
        kEvaluatorResultsKeyPreprocessingLatency: @(imageProcessingLatency),
        kEvaluatorResultsKeyInferenceLatency: @(inferenceLatency),
        kEvaluatorResultsKeyInferenceResults: modelOutput
    };
    
    safe_block(completionHandler, evaluatorResults, transformedPixelBuffer);
    
    }); // dispatch_once
}

@end
