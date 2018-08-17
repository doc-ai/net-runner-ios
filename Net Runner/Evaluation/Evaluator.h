//
//  Evaluator.h
//  Net Runner
//
//  Created by Philip Dow on 7/18/18.
//  Copyright © 2018 doc.ai. All rights reserved.
//

#ifndef Evaluator_h
#define Evaluator_h

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

#import "Model.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * An `Evaluator` knows how to run a model on a particular kind of input.
 * For `VisonModel` evaluators, the higher level evaluators ultimately pass execution down to the
 * `CVPixelBufferEvaluator`, which loads the model and runs inference, returning the results and latency.
 *
 * Evaluators should dispatch their operation to run once and then set the model and any input to `nil`.
 * Running an evaluator a second time should have no effect.
 *
 * There is no default inititialization method for an evaluator, but each evaluator takes a `Model`
 * and produces results, which contain the inference, latency, and other information.
 */

@protocol Evaluator

/**
 * Completion block for the evaluate method.
 *
 * @param result Results. See EvaluatorConstants.h for a list of keys that may appear in this dictionary.
 * @param inputPixelBuffer The pixel buffer which the model actually sees before removing the alpha channel and
 * applying any normalization.
 */

typedef void (^EvaluatorCompletionBlock)(NSDictionary *result, CVPixelBufferRef _Nullable inputPixelBuffer);

/**
 * The `Model` object on which inference is run.
 *
 * Conforming objects should store the model in their initialization method and then set it to `nil` when
 * evaluation is complete.
 */

@property (readonly) id<Model> model;

/**
 * The function repsonsible for perfoming inference with the model. The function should store the results
 * of inference in the `results` property and pass that value to the completion handler.
 *
 * @param completionHandler the completion block called when evaluation is finished. May be called on
 * a separate thread.
 *
 * Conforming classes should dispatch their evaluation block once and then set the `model` and any intermediate
 * data to `nil` for aggressive memory management. Calling this method a second time should have no effect.
 */

- (void)evaluateWithCompletionHandler:(nullable EvaluatorCompletionBlock)completionHandler;

@end

NS_ASSUME_NONNULL_END

#endif /* Evaluator_h */
