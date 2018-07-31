//
//  EvaluationResultsActivityItemProvider.h
//  Net Runner
//
//  Created by Philip Dow on 7/24/18.
//  Copyright © 2018 doc.ai. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface EvaluationResultsActivityItemProvider : UIActivityItemProvider

/**
 * Results must be JSON serializable
 */

- (instancetype)initWithResults:(id)results;

@property (readonly) id results;

@end

NS_ASSUME_NONNULL_END
