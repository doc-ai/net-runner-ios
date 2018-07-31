//
//  EvaluationMetric.h
//  Net Runner
//
//  Created by Philip Dow on 7/19/18.
//  Copyright © 2018 doc.ai. All rights reserved.
//

#import <Foundation/Foundation.h>

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

- (NSDictionary*)evaluate:(NSDictionary*)y yhat:(NSDictionary*)yhat;

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

- (NSDictionary*)reduce:(NSArray<NSDictionary*>*)metrics;

@end

NS_ASSUME_NONNULL_END
