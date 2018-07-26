//
//  Evaluator.h
//  tflite_camera_example
//
//  Created by Philip Dow on 7/18/18.
//  Copyright © 2018 doc.ai. All rights reserved.
//

#ifndef Evaluator_h
#define Evaluator_h

#import "Model.h"
#import "VisionModel.h"

NS_ASSUME_NONNULL_BEGIN

/*
 * Evaluators should dispatch their operation to run once and then set the model and any input to nil.
 * Running an evaluator a second time should have no effect.
 */

@protocol Evaluator

typedef void (^EvaluatorCompletionBlock)(NSDictionary *result);

@property (readonly) id<VisionModel> model; // Model
@property (readonly) NSDictionary *results;

- (void)evaluateWithCompletionHandler:(nullable EvaluatorCompletionBlock)completionHandler;

@end

NS_ASSUME_NONNULL_END

#endif /* Evaluator_h */
