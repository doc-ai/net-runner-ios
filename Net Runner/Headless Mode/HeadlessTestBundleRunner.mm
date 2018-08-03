//
//  HeadlessTestBundleRunner.m
//  Net Runner
//
//  Created by Philip Dow on 7/19/18.
//  Copyright © 2018 doc.ai. All rights reserved.
//

#import "HeadlessTestBundleRunner.h"

#import "HeadlessTestBundle.h"
#import "FileImageEvaluator.h"
#import "URLImageEvaluator.h"
#import "Evaluator.h"
#import "ModelBundleManager.h"
#import "VisionModel.h"
#import "Model.h"
#import "EvaluationMetric.h"
#import "NSArray+Extensions.h"
#import "ModelBundle.h"
#import "ModelOutput.h"
#import "EvaluatorConstants.h"

@interface HeadlessTestBundleRunner ()

@property (readwrite) HeadlessTestBundle *testBundle;
@property (readwrite) NSArray<NSDictionary*> *results;
@property (readwrite) NSArray<NSDictionary*> *summary;

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

// TODO: Use evaluator constants

- (void)evaluate {
    
    // Convert model ids to bundles
    
    NSArray<ModelBundle*> *modelBundles = [ModelBundleManager.sharedManager bundlesWithIds:self.testBundle.modelIds];
    
    if ( modelBundles.count != self.testBundle.modelIds.count ) {
        NSLog(@"Test Bundle %@: Didn't load all models", self.testBundle.identifier);
    }
    
    // For each model, image, iteration: build an evaluator
    
    NSMutableArray<id<Evaluator>> *evaluators = [[NSMutableArray<id<Evaluator>> alloc] init];
    
    NSUInteger iterations = self.testBundle.iterations;
    NSUInteger numberOfPhotos = 0;
    NSUInteger numberOfModels = 0;
    
    for ( ModelBundle *modelBundle in modelBundles ) {
        
        id<Model> model = [modelBundle newModel];
        
        if ( model == nil ) {
            NSLog(@"Test Bundle %@: Unable to instantiate model from model bundle: %@", self.testBundle.identifier, modelBundle.identifier);
            continue;
        }
        
        if ( ![model conformsToProtocol:@protocol(VisionModel)] ) {
            NSLog(@"Test Bundle %@: Model does not conform to VisionModel protocol: %@", self.testBundle.identifier, modelBundle.identifier);
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
                    evaluator = [[FileImageEvaluator alloc] initWithModel:(id<VisionModel>)model fileURL:imageURL name:name];
                } else if ( [imageType isEqualToString:@"url"] ) {
                    NSURL *imageURL = [NSURL URLWithString:image[@"url"]];
                    evaluator = [[URLImageEvaluator alloc] initWithModel:(id<VisionModel>)model URL:imageURL name:name];
                }
                
                [evaluators addObject:evaluator];
                numberOfPhotos++;
            }
        }
    }
    
    numberOfPhotos = numberOfPhotos / numberOfModels;
    
    // Execute the evaluators and collect the results
    
    NSLog(@"Test Bundle %@: Running %tu evaluators", self.testBundle.identifier, evaluators.count);
    
    NSMutableArray<NSDictionary*> *results = [[NSMutableArray<NSDictionary*> alloc] init];
    
    for ( id<Evaluator> evaluator in evaluators ) {

         @autoreleasepool {
            [evaluator evaluateWithCompletionHandler:^(NSDictionary * _Nonnull result) {
                NSMutableDictionary *resultCopy = [result mutableCopy];
                resultCopy[@"test_bundle"] = self.testBundle.identifier;
                [results addObject:[resultCopy copy]];
            }];
         }
    }
    
    // Save all the results: do with this whatever you want, e.g. push it to a server
    
    self.results = results;
    
    // Filter out results with an error for computing summary statistics
    
    NSDictionary *resultsByError = [results groupBy:kEvaluatorResultsKeyError];
    NSArray *resultsWithoutError = resultsByError[@(NO)];
    NSArray *resultsWithError = resultsByError[@(YES)];
    
    NSLog(@"Test Bundle: %@, Evaluation errors: %tu", self.testBundle.identifier, resultsWithError.count );
    
    // Group results by model
    
    NSDictionary *resultsByModel = [resultsWithoutError groupBy:kEvaluatorResultsKeyModel];
    
    // Prepare to collect summary statistics
    
    NSMutableDictionary *summaryStatistics = [[NSMutableDictionary alloc] init];
    for ( NSString *modelID in resultsByModel ) {
        summaryStatistics[modelID] = [[NSMutableDictionary alloc] init];
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
        
        NSDictionary *latencySummary = @{
            @"latency": @(averageLatency)
        };
        
        [summaryStatistics[modelID] addEntriesFromDictionary:latencySummary];
    }
    
    // Execute the evaluation metric if one is available, by model
    
    if ( id<EvaluationMetric> metric = self.testBundle.metric ) {
        
        for ( NSString *modelID in resultsByModel ) {
            NSArray *modelResults = resultsByModel[modelID];
            
            NSMutableArray<NSDictionary*> *metricResults = [[NSMutableArray<NSDictionary*> alloc] init];
        
            for ( NSDictionary *result in modelResults ) {
                
                NSString *identifier = result[kEvaluatorResultsKeyImage];
                id yhat = ((id<ModelOutput>)result[kEvaluatorResultsKeyEvaluation][kEvaluatorResultsKeyInferenceResults]).value;
                id y = self.testBundle.labels[identifier];
                
                NSDictionary *metricResult = [metric evaluate:y yhat:yhat];
                [metricResults addObject:metricResult];
            }
            
            NSDictionary *metricResultsSummary = [metric reduce:metricResults];

            [summaryStatistics[modelID] addEntriesFromDictionary:metricResultsSummary];
        }
    }
    
    // Convert summary statistics to an array
    
    NSMutableArray *summary = [[NSMutableArray alloc] init];
    
    for ( NSString *model in summaryStatistics ) {
        NSMutableDictionary *results = [summaryStatistics[model] mutableCopy];
        results[kEvaluatorResultsKeyModel] = model;
        [summary addObject:results];
    }
    
    self.summary = summary; // summaryStatistics;
    
    NSLog(@"Test Bundle %@: Summary statistics:\n%@", self.testBundle.identifier, summaryStatistics);
}

@end
