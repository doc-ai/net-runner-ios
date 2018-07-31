//
//  EvaluationMetricFactory.h
//  Net Runner
//
//  Created by Philip Dow on 7/19/18.
//  Copyright © 2018 doc.ai. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol EvaluationMetric;

/**
 * Instantiates conforming evaluation metrics from class names.
 */

@interface EvaluationMetricFactory : NSObject

/**
 * Returns the shared instance of the EvaluationMetricFactory. The factory dyanamically instantiates
 * metric classes based on their class names. You should not need to use this class directly.
 */

+ (instancetype)sharedInstance;

/**
 * Instantiates and returns an EvaluationMetric given its class name.
 *
 * @param name The class name of the metric.
 *
 * @return A conforming instance of EvaluationMetric corresponding to the class name.
 */

- (id<EvaluationMetric>)evaluationMetricForName:(NSString*)name;

@end

NS_ASSUME_NONNULL_END
