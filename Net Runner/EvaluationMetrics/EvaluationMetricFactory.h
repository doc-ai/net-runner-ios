//
//  EvaluationMetricFactory.h
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

@import Foundation;

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
