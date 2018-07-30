//
//  ModelBundleManager.h
//  tflite_camera_example
//
//  Created by Philip Dow on 7/10/18.
//  Copyright © 2018 doc.ai. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol Model;
@class ModelBundle;

NS_ASSUME_NONNULL_BEGIN

/**
 * The `ModelBundleManager` manages model bundles in a provided directory. Use the returned
 * `ModelBundle` classes to instantiante `Model` objects.
 */

@interface ModelBundleManager : NSObject

/**
 * All available model bundles.
 *
 * You must call `loadModelBundlesAtPath:error:` before accessing this property.
 */

@property (readonly) NSArray<ModelBundle*> *modelBundles;

/**
 * Returns the shared instance of the `ModelBundleManager`.
 * You may create your own model managers if you require more than one.
 */

+ (instancetype)sharedManager;

/**
 * Loads the available models at the specified path, e.g. folders that end in .tfbundle
 * and assigns them to the models property. Models will be sorted by name by default.
 
 * @param path directly where model bundles are located, may be in the application bundle,
 * application documents directory, or elsewhere.
 * @param error no error is currently set.
 *
 * @return `YES` if the bundles were successfully loaded, `NO` otherwise.
 */

- (BOOL)loadModelBundlesAtPath:(NSString*)path error:(NSError**)error;

/**
 * Returns the models that match the provided ids.
 *
 * You must call `loadModelsAtPath:error:` before calling this method.
 *
 * @param modelIds array of model ids in `NSString` format
 *
 * @return Array of `ModelBundle` matching the model ids
 */

- (NSArray<ModelBundle*>*)bundlesWithIds:(NSArray<NSString*>*)modelIds;

/**
 * Returns the single model that matches the provided id.
 *
 * You must call `loadModelsAtPath:error:` before calling this method.
 *
 * @param modelId the single model id whose bundle you would like.
 *
 * @return The `ModelBundle` matching the model id.
 */

- (nullable ModelBundle*)bundleWithId:(NSString*)modelId;

@end

NS_ASSUME_NONNULL_END
