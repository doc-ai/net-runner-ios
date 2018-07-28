//
//  ModelManager.h
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
 * The `ModelManager` manages model bundles in a provided directory. Use the returned
 * `ModelBundle` classes to instantiance instances of `Model` objects.
 */

@interface ModelManager : NSObject

/**
 * All available model bundles. You must call loadModelBundlesAtPath:error: before accessing models.
 */

@property (readonly) NSArray<ModelBundle*> *modelBundles;

/**
 * Returns the shared instance of the ModelManager.
 * You may create your own model managers if you require more than one.
 */

+ (instancetype)sharedManager;

/**
 * Loads the available models at the specified path, e.g. folders that end in .tfbundle
 * and assigns them to the models property. Models will be sorted by name by default.
 */

- (BOOL)loadModelBundlesAtPath:(NSString*)path error:(NSError**)error;

/**
 * Returns the models that match the given ids. You must call loadModelsAtPath:error:
 * before accessing models.
 */

- (NSArray<ModelBundle*>*)bundlesWithIds:(NSArray<NSString*>*)modelIds;
- (nullable ModelBundle*)bundleWithId:(NSString*)modelId;

@end

NS_ASSUME_NONNULL_END
