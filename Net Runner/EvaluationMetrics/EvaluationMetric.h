//
//  EvaluationMetric.h
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

@protocol EvaluationMetric <NSObject>

/**
 * Produce a set of evaluation metrics given the known output y and the predicted output yhat.
 * The metrics may consist of and be organized by whatever scheme is appropriate.
 * It is up to you how you would like to use these metrics
 *
 * For example, for an RMSE error, this function could return the individual error term for this example:
 *
 * @code
 * @{
 *   @"RMSE: (yhat-y)^2
 * }
 * @endcode
 *
 */

- (NSDictionary<NSString*,NSNumber*>*)evaluate:(NSDictionary<NSString*,id>*)y yhat:(NSDictionary<NSString*,id>*)yhat;

/**
 * Given a set of individual evaluation metrics, return the aggregate metrics.
 *
 * For example, for an RMSE error, this function could sum the individual squared error terms
 * and then divide by the number of terms, taking the square root for the final value:
 *
 * @code
 * @{
 *   @"RMSE: sqrt(sum(individual_rmse)/count)
 * }
 * @endcode
 *
 */

- (NSDictionary<NSString*,NSNumber*>*)reduce:(NSArray<NSDictionary<NSString*,NSNumber*>*>*)metrics;

@end

NS_ASSUME_NONNULL_END
