//
//  HeadlessTestBundleRunner.mm
//  Net Runner
//
//  Created by Philip Dow on 7/19/18.
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

#import "HeadlessTestBundleRunner.h"

#import "HeadlessTestBundle.h"
#import "FileImageEvaluator.h"
#import "URLImageEvaluator.h"
#import "Evaluator.h"
#import "EvaluationMetric.h"
#import "ModelOutput.h"
#import "EvaluatorConstants.h"

@import TensorIO;

@interface HeadlessTestBundleRunner ()

@property (readwrite) HeadlessTestBundle *testBundle;
@property (readwrite) NSArray<NSDictionary<NSString*,id>*> *results;
@property (readwrite) NSArray<NSDictionary<NSString*,id>*> *summary;

@end

@implementation HeadlessTestBundleRunner

- (instancetype)initWithTestBundle:(HeadlessTestBundle*)testBundle {
    if (self = [super init]) {
        _testBundle = testBundle;
    }
    
    return self;
}

// Future optimization might run each model on its own operation queue
// Use a queue, not an array to manage the evaluators
// See EvaluateResultsTableViewController

- (void)evaluate {
    
    // Convert model ids to bundles
    
    NSArray<TIOModelBundle*> *modelBundles = [TIOModelBundleManager.sharedManager bundlesWithIds:self.testBundle.modelIds];
    
    if ( modelBundles.count != self.testBundle.modelIds.count ) {
        NSLog(@"Test Bundle %@: Didn't load all models", self.testBundle.identifier);
    }
    
    // For each model, image, iteration: build an evaluator
    
    NSMutableArray<id<Evaluator>> *evaluators = [[NSMutableArray<id<Evaluator>> alloc] init];
    
    NSUInteger iterations = self.testBundle.iterations;
    NSUInteger numberOfPhotos = 0;
    NSUInteger numberOfModels = 0;
    
    for ( TIOModelBundle *modelBundle in modelBundles ) {
        
        id<TIOModel> model = [modelBundle newModel];
        
        if ( model == nil ) {
            NSLog(@"Test Bundle %@: Unable to instantiate model from model bundle: %@", self.testBundle.identifier, modelBundle.identifier);
            continue;
        }
        
        numberOfModels++;
        
        for ( NSDictionary *image in self.testBundle.images ) {
            NSString *imageType = image[@"type"];
            NSString *name = image[@"path"];
            
            assert([imageType isEqualToString:@"file"] || [imageType isEqualToString:@"url"]);
            
            for ( NSUInteger iter = 0; iter < iterations; iter++ ) {
            
                id<Evaluator> evaluator;
            
                if ( [imageType isEqualToString:@"file"] ) {
                    NSURL *imageURL = [NSURL fileURLWithPath:[self.testBundle filePathForImageInfo:image]];
                    evaluator = [[FileImageEvaluator alloc] initWithModel:model fileURL:imageURL name:name];
                } else if ( [imageType isEqualToString:@"url"] ) {
                    NSURL *imageURL = [NSURL URLWithString:image[@"url"]];
                    evaluator = [[URLImageEvaluator alloc] initWithModel:model URL:imageURL name:name];
                }
                
                [evaluators addObject:evaluator];
                numberOfPhotos++;
            }
        }
    }
    
    numberOfPhotos = numberOfPhotos / numberOfModels;
    
    // Execute the evaluators and collect the results
    
    NSLog(@"Test Bundle %@: Running %tu evaluators", self.testBundle.identifier, evaluators.count);
    
    NSMutableArray<NSDictionary<NSString*,id>*> *results = [[NSMutableArray<NSDictionary<NSString*,id>*> alloc] init];
    
    for ( id<Evaluator> evaluator in evaluators ) {

         @autoreleasepool {
            [evaluator evaluateWithCompletionHandler:^(NSDictionary * _Nonnull result, CVPixelBufferRef _Nullable inputPixelBuffer) {
                NSMutableDictionary *resultCopy = [result mutableCopy];
                resultCopy[@"test_bundle"] = self.testBundle.identifier;
                [results addObject:[resultCopy copy]];
            }];
         }
    }
    
    // Save all the results: do with this whatever you want, e.g. push it to a server
    
    self.results = results;
    
    // Filter out results with an error for computing summary statistics
    
    NSDictionary<NSNumber*,id> *resultsByError = [results groupBy:kEvaluatorResultsKeyError];
    NSArray<NSDictionary<NSString*,id>*> *resultsWithoutError = resultsByError[@(NO)];
    NSArray<NSDictionary<NSString*,id>*> *resultsWithError = resultsByError[@(YES)];
    
    NSLog(@"Test Bundle: %@, Evaluation errors: %tu", self.testBundle.identifier, resultsWithError.count );
    
    // Group results by model
    
    NSDictionary<NSString*,id> *resultsByModel = [resultsWithoutError groupBy:kEvaluatorResultsKeyModel];
    
    // Prepare to collect summary statistics
    
    NSMutableDictionary<NSString*,id> *summaryStatistics = [[NSMutableDictionary<NSString*,id> alloc] init];
    
    for ( NSString *modelID in resultsByModel ) {
        summaryStatistics[modelID] = [[NSMutableDictionary<NSString*,id> alloc] init];
    }
    
    // Calculate average latency, by model
    
    for ( NSString *modelID in resultsByModel ) {
        NSArray *modelResults = resultsByModel[modelID];
        
        double totalLatency =
            [[[modelResults
            map:^NSDictionary * _Nonnull(id  _Nonnull obj) {
                return obj[kEvaluatorResultsKeyEvaluation][kEvaluatorResultsKeyInferenceLatency];
            }]
            reduce:@(0.0) combine:^id _Nonnull(NSNumber * _Nonnull accumulator, NSNumber * _Nonnull item) {
                return @(accumulator.doubleValue + item.doubleValue);
            }]
            doubleValue
            ];
        
        double averageLatency = totalLatency / modelResults.count;
        
        NSDictionary<NSString*,NSNumber*> *latencySummary = @{
            @"latency": @(averageLatency)
        };
        
        [summaryStatistics[modelID] addEntriesFromDictionary:latencySummary];
    }
    
    // Execute the evaluation metric if one is available, by model
    
    if ( id<EvaluationMetric> metric = self.testBundle.metric ) {
        
        for ( NSString *modelID in resultsByModel ) {
            NSArray *modelResults = resultsByModel[modelID];
            
            NSMutableArray<NSDictionary<NSString*,id>*> *metricResults = [[NSMutableArray<NSDictionary<NSString*,id>*> alloc] init];
        
            for ( NSDictionary *result in modelResults ) {
                
                NSString *identifier = result[kEvaluatorResultsKeyImage];
                id yhat = ((id<ModelOutput>)result[kEvaluatorResultsKeyEvaluation][kEvaluatorResultsKeyInferenceResults]).value;
                id y = self.testBundle.labels[identifier];
                
                NSDictionary<NSString*,NSNumber*> *metricResult = [metric evaluate:y yhat:yhat];
                [metricResults addObject:metricResult];
            }
            
            NSDictionary<NSString*,NSNumber*> *metricResultsSummary = [metric reduce:metricResults];
            [summaryStatistics[modelID] addEntriesFromDictionary:metricResultsSummary];
        }
    }
    
    // Convert summary statistics to an array
    
    NSMutableArray *summary = [[NSMutableArray alloc] init];
    
    for ( NSString *model in summaryStatistics ) {
        NSMutableDictionary<NSString*,id> *results = [summaryStatistics[model] mutableCopy];
        results[kEvaluatorResultsKeyModel] = model;
        [summary addObject:results];
    }
    
    self.summary = summary;
    
    NSLog(@"Test Bundle %@: Summary statistics:\n%@", self.testBundle.identifier, summaryStatistics);
}

@end
