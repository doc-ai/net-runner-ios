//
//  EvaluationMetricAccuracyTop5.h
//  Net Runner
//
//  Created by Philip Dow on 7/19/18.
//  Copyright © 2018 doc.ai. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "EvaluationMetric.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * The Top5 Accuracy metric returns 1 if the expected classification y is contained in
 * the top five hypothesized classifications yhat, and 0 otherwise. The reduced value
 * is the percentage of correct classifications.
 */

@interface EvaluationMetricAccuracyTop5 : NSObject <EvaluationMetric>

/**
 * 1 if y is contained in the top five values of yhat, 0 otherwise.
 *
 * @param y The expected classification
 * @param yhat The produced classification.
 *
 * @return `NSDictionary` with a single `@"accuracy"` key whose value is either 1 or 0.
 */

- (NSDictionary<NSString*,NSNumber*>*)evaluate:(NSDictionary<NSString*,id>*)y yhat:(NSDictionary<NSString*,id>*)yhat;

/**
 * The percentage of correct classifications
 *
 * @param metrics An array of results from calling `evaluate:yhat:`
 *
 * @return `NSDictionary` with a single `@"accuracy"` key whose value is the percentage of correct classifications.
 */

- (NSDictionary<NSString*,NSNumber*>*)reduce:(NSArray<NSDictionary<NSString*,NSNumber*>*>*)metrics;

@end

NS_ASSUME_NONNULL_END
