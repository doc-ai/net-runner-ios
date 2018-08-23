//
//  AlbumPhotoEvaluator.h
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
@import Photos;

#import "Evaluator.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * Runs inference on a single album photo from the users photo library. Appropriate for models with
 * a single input node that expects a pixel buffer.
 */

@interface AlbumPhotoEvaluator : NSObject <Evaluator>

/**
 * The `TIOModel` object on which inference is run. Noted in the results dictionary under the `kEvaluatorResultsKeyModel` key.
 */

@property (readonly) id<TIOModel> model;

/**
 * The photo on which inference is run. Noted in the results dictionary under the `kEvaluatorResultsKeyImage` key.
 */

@property (readonly) PHAsset *photo;

/**
 * The album to which this photo belongs. Noted in the results dictionary under the `kEvaluatorResultsKeyAlbum` key.
 */

@property (readonly) PHAssetCollection *album;

/**
 * The caching image manager, used to aggressively mananage image caching for album photos.
 */

@property (readonly) PHCachingImageManager *imageManager;

/**
 * Designated initializer.
 *
 * @param model The `TIOModel` object on which inference is being run. Noded in the results dictionary under the `kEvaluatorResultsKeyModel` key.
 * @param photo The `PHAsset` on which infererence is being run. Noted in the results dictionary under the kEvaluatorResultsKeyImage key.
 * @param album The `PHAssetCollection` to which the photo belongs. Noted in the results dictionary under the `kEvaluatorResultsKeyAlbum` key.
 * @param imageManager The 'PHCachingImageManager' used to manage the acquisition of assets.
 *
 * It is recommended that you share a single instance of `PHCachingImageManager` between the photo album evaluators you use to perform a set of inferences.
 */

- (instancetype)initWithModel:(id<TIOModel>)model photo:(PHAsset*)photo album:(PHAssetCollection*)album imageManager:(PHCachingImageManager*)imageManager NS_DESIGNATED_INITIALIZER;

/**
 * Use the designated initializer.
 */

- (instancetype)init NS_UNAVAILABLE;

/**
 * Acquires a `UIImage` from the image manager and delegates inference to an instance of `ImageEvaluator`.
 * Stores the results of inference in the `results` property and passes that value to the completion handler.
 *
 * @param completionHandler the completion block called when evaluation is finished. May be called on
 * a separate thread.
 */

- (void)evaluateWithCompletionHandler:(nullable EvaluatorCompletionBlock)completionHandler;

@end

NS_ASSUME_NONNULL_END
