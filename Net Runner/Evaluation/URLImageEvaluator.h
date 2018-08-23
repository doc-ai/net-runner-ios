//
//  URLImageEvaluator.h
//  Net Runner
//
//  Created by Philip Dow on 7/18/18.
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

#import "Evaluator.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * Runs inference on a single URL. Appropriate for models with a single input node that expects a pixel buffer.
 *
 * @warning Currently unimplemented.
 */

@interface URLImageEvaluator : NSObject <Evaluator>

/**
 * The `TIOModel` object on which inference is run. Noted in the results dictionary under the `kEvaluatorResultsKeyModel` key.
 */

@property (readonly) id<TIOModel> model;

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
 * @param model The `TIOModel` object on which inference is being run. Noded in the results dictionary under the `kEvaluatorResultsKeyModel` key.
 * @param URL The `NSURL` on which infererence is being run.
 * @param name The `NSString` name of the image URL on which infererence is being run. Noted in the results dictionary under the kEvaluatorResultsKeyImage key.
 */

- (instancetype)initWithModel:(id<TIOModel>)model URL:(NSURL*)URL name:(NSString*)name NS_DESIGNATED_INITIALIZER;

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
