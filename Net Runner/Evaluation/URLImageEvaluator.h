//
//  URLImageEvaluator.h
//  Net Runner
//
//  Created by Philip Dow on 7/18/18.
//  Copyright © 2018 doc.ai. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Evaluator.h"
#import "VisionModel.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * Runs inference on a single URL. Appropriate for models with a single input node that expects a pixel buffer.
 *
 * @warning Currently unimplemented.
 */

@interface URLImageEvaluator : NSObject <Evaluator>

/**
 * The `VisionModel` object on which inference is run. Noted in the results dictionary under the `kEvaluatorResultsKeyModel` key.
 */

@property (readonly) id<VisionModel> model;

/**
 * The results of running inference on the model. See EvaluatorConstants.h for a list of keys that may
 * appear in this dictionary.
 */

@property (readonly) NSDictionary *results;

/**
 * The URL of the image being evaluated.
 */

@property (readonly) NSURL *URL;

/**
 * The name of the image URL being evaluated. You may use the string represention of the URL.
 * Noted in the results dictionary under the `kEvaluatorResultsKeyImage` key.
 */

@property (readonly) NSString *name;

/**
 * Designated initializer.
 *
 * @param model The `VisionModel` object on which inference is being run. Noded in the results dictionary under the `kEvaluatorResultsKeyModel` key.
 * @param URL The `NSURL` on which infererence is being run.
 * @param name The `NSString` name of the image URL on which infererence is being run. Noted in the results dictionary under the kEvaluatorResultsKeyImage key.
 */

- (instancetype)initWithModel:(id<VisionModel>)model URL:(NSURL*)URL name:(NSString*)name NS_DESIGNATED_INITIALIZER;

/**
 * Use the designated initializer.
 */

- (instancetype)init NS_UNAVAILABLE;

/**
 * Acquires a `UIImage` from the contents of the URL and delegates inference to an instance of `ImageEvaluator`.
 * Stores the results of inference in the `results` property and passes that value to the completion handler.
 *
 * @param completionHandler the completion block called when evaluation is finished. May be called on
 * a separate thread.
 */

- (void)evaluateWithCompletionHandler:(nullable EvaluatorCompletionBlock)completionHandler;

@end

NS_ASSUME_NONNULL_END
