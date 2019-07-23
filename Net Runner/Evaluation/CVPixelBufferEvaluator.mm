//
//  CVPixelBufferEvaluator.mm
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

#import "CVPixelBufferEvaluator.h"

#import "EvaluatorConstants.h"
#import "Utilities.h"
#import "ModelOutput.h"
#import "ModelOutputManager.h"

@import TensorIO;

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
    
    __block TIOPixelBufferLayerDescription *description = nil;
    
    [self.model.io.inputs[0] matchCasePixelBuffer:^(TIOPixelBufferLayerDescription * _Nonnull pixelBufferDescription) {
        description = pixelBufferDescription;
    } caseVector:^(TIOVectorLayerDescription * _Nonnull vectorDescription) {
        ;
    } caseString:^(TIOStringLayerDescription * _Nonnull stringDescription) {
        ;
    }];
    
    if ( description == nil ) {
        NSLog(@"Model does not contain an image input at index 0");
        NSDictionary *results = @{
            kEvaluatorResultsKeyPreprocessingError: @"Model does not contain an image input in the first layer"
        };
        safe_block(completionHandler, results, NULL);
        return;
    }
    
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
        results = (NSDictionary*)[self.model runOn:pixelBufferWrapper error:nil];
    });
    
    id<ModelOutput> modelOutput = [[[[ModelOutputManager sharedManager] classForTypes:@[self.model.type, self.model.options.outputFormat]] alloc] initWithDictionary:results];
    
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
