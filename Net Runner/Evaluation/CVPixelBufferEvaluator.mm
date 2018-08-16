//
//  CVPixelBufferEvaluator.m
//  Net Runner
//
//  Created by Philip Dow on 7/26/18.
//  Copyright © 2018 doc.ai. All rights reserved.
//

#import "CVPixelBufferEvaluator.h"

#import "EvaluatorConstants.h"
#import "VisionPipeline.h"
#import "Utilities.h"
#import "ObjcDefer.h"
#import "ModelOutput.h"
#import "ModelOutputManager.h"

// TODO: need some way to unify this: don't want to require a model output but do want to let the user specify one
#import "ImageNetClassificationModelOutput.h"

@interface CVPixelBufferEvaluator ()

@property (readwrite) NSDictionary *results;
@property (readwrite) id<VisionModel> model;
@property (nonatomic, readwrite) CVPixelBufferRef pixelBuffer;
@property (readwrite) CGImagePropertyOrientation orientation;

@end

@implementation CVPixelBufferEvaluator {
    dispatch_once_t _once;
}

- (void)setPixelBuffer:(CVPixelBufferRef)pixelBuffer {
    CVPixelBufferRelease(_pixelBuffer);
    _pixelBuffer = pixelBuffer;
    CVPixelBufferRetain(_pixelBuffer);
}

- (instancetype)initWithModel:(id<VisionModel>)model pixelBuffer:(CVPixelBufferRef)pixelBuffer orientation:(CGImagePropertyOrientation)orientation {
    if (self = [super init]) {
        _model = model;
        _orientation = orientation;
        _pixelBuffer = pixelBuffer;
        CVPixelBufferRetain(_pixelBuffer);
    }
    
    return self;
}

- (void)evaluateWithCompletionHandler:(nullable EvaluatorCompletionBlock)completionHandler {
    dispatch_once(&_once, ^{
    
    defer_block {
        self.model = nil;
        self.pixelBuffer = NULL;
    };
    
    double imageProcessingLatency;
    double inferenceLatency;
    
    // Ensure the model is loaded
    
    NSError *modelError;
    
    if ( ![self.model load:&modelError] ) {
        NSLog(@"Unable to load model, error: %@", modelError);
        self.results = @{
            kEvaluatorResultsKeyPreprocessingError: @"Unable to load model"
        };
        safe_block(completionHandler, self.results);
        return;
    }
    
    // Transform the image to the required format
    
    VisionPipeline *pipeline = [[VisionPipeline alloc] initWithVisionModel:self.model];
    __block CVPixelBufferRef transformedPixelBuffer = NULL;
    
    measuring_latency(&imageProcessingLatency, ^{
        transformedPixelBuffer = [pipeline transform:self.pixelBuffer orientation:self.orientation];
    });
    
    if (transformedPixelBuffer == NULL) {
        NSLog(@"Unable to transform pixel buffer for model processing");
        self.results = @{
            kEvaluatorResultsKeyPreprocessingError: @"VisionPipeline returned NULL CVPixelBuffer"
        };
        safe_block(completionHandler, self.results);
        return;
    }
    
    // Make prediction
    
    __block NSDictionary *results;
    
    measuring_latency(&inferenceLatency, ^{
        results = [self.model runModelOn:transformedPixelBuffer];
    });
    
    // Wrap output
    // TODO: This requires some thought
    
    id<ModelOutput> modelOutput = [[[[ModelOutputManager sharedManager] classForType:self.model.type] alloc] initWithDictionary:results];
    
//    if ( [self.model.type isEqualToString:@"image.classification.imagenet"] ) {
//        modelOutput = [[ImageNetClassificationModelOutput alloc] initWithDictionary:results];
//    } else {
//        assert(NO);
//    }
    
    if (modelOutput == nil) {
        NSLog(@"Running the model produced null results");
        self.results = @{
            kEvaluatorResultsKeyInferenceError: @"Model returned nil results"
        };
        safe_block(completionHandler, self.results);
        return;
    }
    
    self.results = @{
        kEvaluatorResultsKeyPreprocessingLatency: @(imageProcessingLatency),
        kEvaluatorResultsKeyInferenceLatency: @(inferenceLatency),
        kEvaluatorResultsKeyInferenceResults: modelOutput
    };
    
    safe_block(completionHandler, self.results);
    
    }); // dispatch_once
}

@end
