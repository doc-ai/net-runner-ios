//
//  CVPixelBufferEvaluator.h
//  Net Runner
//
//  Created by Philip Dow on 7/26/18.
//  Copyright © 2018 doc.ai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

#import "Evaluator.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * Runs inference on a single `CVPixelBufferRef`, applying any required transformations to the input.
 * Appropriate for models with a single input node that expects a pixel buffer.
 */

@interface CVPixelBufferEvaluator : NSObject <Evaluator>

/**
 * The `VisionModel` object on which inference is run. Noted in the results dictionary under the `kEvaluatorResultsKeyModel` key.
 */

@property (readonly) id<VisionModel> model;

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
 * @param model The `VisionModel` object on which inference is being run.
 * @param pixelBuffer The `CVPixelBufferRef` on which inference is being run.
 * @param orientation The `CGImagePropertyOrientation` of the incoming pixel buffer before transformations are applied to ensure it is upright.
 */

- (instancetype)initWithModel:(id<VisionModel>)model pixelBuffer:(CVPixelBufferRef)pixelBuffer orientation:(CGImagePropertyOrientation)orientation NS_DESIGNATED_INITIALIZER;

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
