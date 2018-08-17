//
//  ImageEvaluator.h
//  Net Runner
//
//  Created by Philip Dow on 7/18/18.
//  Copyright © 2018 doc.ai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "Evaluator.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * Runs inference on a `UIImage`. Appropriate for models with a single input node that expects a pixel buffer.
 *
 * Most `Model` will delegate evaluation to this object, which then delegates it to the `CVPixelBufferEvaluator`.
 */

@interface ImageEvaluator : NSObject <Evaluator>

/**
 * The `Model` object on which inference is run. Noted in the results dictionary under the `kEvaluatorResultsKeyModel` key.
 */

@property (readonly) id<Model> model;

/**
 * The image on which inference is being run.
 */

@property (readonly) UIImage *image;

/**
 * Designated initializer.
 *
 * @param model The `Model` object on which inference is being run. Noded in the results dictionary under the `kEvaluatorResultsKeyModel` key.
 * @param image The `UIImage` on which inference is being run.
 */

- (instancetype)initWithModel:(id<Model>)model image:(UIImage*)image NS_DESIGNATED_INITIALIZER;

/**
 * Use the designated initializer.
 */

- (instancetype)init NS_UNAVAILABLE;

/**
 * Acquires a `CVPixelBufferRef` from the contents of the image and delegates inference to an instance of `CVPixelBufferEvaluator`.
 * Stores the results of inference in the `results` property and passes that value to the completion handler.
 *
 * @param completionHandler the completion block called when evaluation is finished. May be called on
 * a separate thread.
 */

- (void)evaluateWithCompletionHandler:(nullable EvaluatorCompletionBlock)completionHandler;

@end

NS_ASSUME_NONNULL_END
