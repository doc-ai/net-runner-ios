//
//  EvaluationMetricFactory.h
//  tflite_camera_example
//
//  Created by Philip Dow on 7/19/18.
//  Copyright © 2018 doc.ai. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol EvaluationMetric;

@interface EvaluationMetricFactory : NSObject

/**
 * Returns the shared instance of the EvaluationMetricFactory. The factory dyanamically instantiates
 * metric classes based on their class names. You should not need to use this class directly.
 */

+ (instancetype)sharedInstance;

- (id<EvaluationMetric>)evaluationMetricForName:(NSString*)name;

@end

NS_ASSUME_NONNULL_END
