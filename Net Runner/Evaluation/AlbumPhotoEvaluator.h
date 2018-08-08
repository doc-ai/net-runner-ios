//
//  AlbumPhotoEvaluator.h
//  Net Runner
//
//  Created by Philip Dow on 7/18/18.
//  Copyright © 2018 doc.ai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>

#import "Evaluator.h"
#import "VisionModel.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * Runs inference on a single album photo from the users photo library. Appropriate for models with
 * a single input node that expects a pixel buffer.
 */

@interface AlbumPhotoEvaluator : NSObject <Evaluator>

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
 * @param model The `VisionModel` object on which inference is being run. Noded in the results dictionary under the `kEvaluatorResultsKeyModel` key.
 * @param photo The `PHAsset` on which infererence is being run. Noted in the results dictionary under the kEvaluatorResultsKeyImage key.
 * @param album The `PHAssetCollection` to which the photo belongs. Noted in the results dictionary under the `kEvaluatorResultsKeyAlbum` key.
 * @param imageManager The 'PHCachingImageManager' used to manage the acquisition of assets.
 *
 * It is recommended that you share a single instance of `PHCachingImageManager` between the photo album evaluators you use to perform a set of inferences.
 */

- (instancetype)initWithModel:(id<VisionModel>)model photo:(PHAsset*)photo album:(PHAssetCollection*)album imageManager:(PHCachingImageManager*)imageManager NS_DESIGNATED_INITIALIZER;

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
