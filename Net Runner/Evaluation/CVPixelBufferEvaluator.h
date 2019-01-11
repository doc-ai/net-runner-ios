//
//  CVPixelBufferEvaluator.h
//  Net Runner
//
//  Created by Philip Dow on 7/26/18.
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

@import UIKit;
@import AVFoundation;

#import "Evaluator.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * Runs inference on a single `CVPixelBufferRef`, applying any required transformations to the input.
 * Appropriate for models with a single input layer that expects a pixel buffer.
 */

@interface CVPixelBufferEvaluator : NSObject <Evaluator>

/**
 * The `TIOModel` object on which inference is run. Noted in the results dictionary under the
 * `kEvaluatorResultsKeyModel` key.
 */

@property (readonly) id<TIOModel> model;

/**
 * The pixel buffer on which inference is being run.
 */ 

@property (nullable, nonatomic, readonly) CVPixelBufferRef pixelBuffer;

/**
 * The orientation of the incoming pixel buffer. A transformation will be applied to ensure the final
 * orientation of the pixel buffer is upright before being passed to the model.
 */

@property (readonly) CGImagePropertyOrientation orientation;

/**
 * Designated initializer.
 *
 * @param model The `TIOModel` object on which inference is being run.
 * @param pixelBuffer The `CVPixelBufferRef` on which inference is being run.
 * @param orientation The `CGImagePropertyOrientation` of the incoming pixel buffer before transformations are applied to ensure it is upright.
 */

- (instancetype)initWithModel:(id<TIOModel>)model pixelBuffer:(CVPixelBufferRef)pixelBuffer orientation:(CGImagePropertyOrientation)orientation NS_DESIGNATED_INITIALIZER;

/**
 * Use the designated initializer.
 */

- (instancetype)init NS_UNAVAILABLE;

/**
 * Runs inference on the input after transforming it to the format expected by the model.
 * Stores the results of inference in the `results` property and passes that value to the completion handler.
 *
 * @param completionHandler the completion block called when evaluation is finished. May be called on
 * a separate thread.
 */

- (void)evaluateWithCompletionHandler:(nullable EvaluatorCompletionBlock)completionHandler;

@end

NS_ASSUME_NONNULL_END
