//
//  FileImageEvaluator.h
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
 * Runs inference on a single file URL corresponding to a file on disk. Useful for headless evaluation.
 * Appropriate for models with a single input node that expects a pixel buffer.
 */

@interface FileImageEvaluator : NSObject <Evaluator>

/**
 * The `TIOModel` object on which inference is run. Noted in the results dictionary under the `kEvaluatorResultsKeyModel` key.
 */

@property (readonly) id<TIOModel> model;

/**
 * The URL of the file being evaluated.
 */

@property (readonly) NSURL *fileURL;

/**
 * The name of the file being evaluated. You may use the string represention of the file URL.
 * Noted in the results dictionary under the `kEvaluatorResultsKeyImage` key.
 */

@property (readonly) NSString *name;

/**
 * Designated initializer.
 *
 * @param model The `TIOModel` object on which inference is being run. Noded in the results dictionary under the `kEvaluatorResultsKeyModel` key.
 * @param fileURL The file backed `NSURL` on which infererence is being run.
 * @param name The `NSString` name of the file on which infererence is being run. Noted in the results dictionary under the kEvaluatorResultsKeyImage key.
 */

- (instancetype)initWithModel:(id<TIOModel>)model fileURL:(NSURL*)fileURL name:(NSString*)name NS_DESIGNATED_INITIALIZER;

/**
 * Use the designated initializer.
 */

- (instancetype)init NS_UNAVAILABLE;

/**
 * Acquires a `UIImage` from the contents of the file and delegates inference to an instance of `ImageEvaluator`.
 * Stores the results of inference in the `results` property and passes that value to the completion handler.
 *
 * @param completionHandler the completion block called when evaluation is finished. May be called on
 * a separate thread.
 */

- (void)evaluateWithCompletionHandler:(nullable EvaluatorCompletionBlock)completionHandler;

@end

NS_ASSUME_NONNULL_END
