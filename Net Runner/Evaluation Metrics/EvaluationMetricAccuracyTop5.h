//
//  EvaluationMetricAccuracyTop5.h
//  tflite_camera_example
//
//  Created by Philip Dow on 7/19/18.
//  Copyright © 2018 doc.ai. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "EvaluationMetric.h"

NS_ASSUME_NONNULL_BEGIN

/*
 * The Top5 Accuracy metric returns 1 if the expected classification y is contained in
 * the top five hypothesized classifications yhat, and 0 otherwise.
 */

@interface EvaluationMetricAccuracyTop5 : NSObject <EvaluationMetric>

- (NSDictionary*)evaluate:(NSDictionary*)y yhat:(NSDictionary*)yhat;
- (NSDictionary*)reduce:(NSArray<NSDictionary*>*)metrics;

@end

NS_ASSUME_NONNULL_END
