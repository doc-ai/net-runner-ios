//
//  TIOModelBundleManager.h
//  TensorIO
//
//  Created by Philip Dow on 7/10/18.
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

#import <Foundation/Foundation.h>

@protocol TIOModel;
@class TIOModelBundle;

NS_ASSUME_NONNULL_BEGIN

/**
 * The `TIOModelBundleManager` manages model bundles in a provided directory. Use the returned
 * `TIOModelBundle` classes to instantiante `TIOModel` objects.
 *
 * Usage:
 * @code
 * [TIOModelBundleManager.sharedManager loadModelBundlesAtPath:modelsPath error:&error];
 * TIOModelBundle *bundle = [TIOModelBundleManager.sharedManager bundleWithId:@"model-id"];
 * id<TIOModel> model = [bundle newModel];
 * @endcode
 */

@interface TIOModelBundleManager : NSObject

/**
 * All available model bundles.
 *
 * You must call `loadModelBundlesAtPath:error:` before accessing this property.
 */

@property (readonly) NSArray<TIOModelBundle*> *modelBundles;

/**
 * Returns the shared instance of the `TIOModelBundleManager`.
 * You may create your own model managers if you require more than one.
 */

+ (instancetype)sharedManager;

/**
 * Loads the available models at the specified path, e.g. folders that end in .tfbundle
 * and assigns them to the models property. Models will be sorted by name by default.
 
 * @param path Directory where model bundles are located, may be in the application bundle,
 * application documents directory, or elsewhere.
 * @param error An error if the model bundles could not be loaded.
 *
 * @return `YES` if the bundles were successfully loaded, `NO` otherwise.
 */

- (BOOL)loadModelBundlesAtPath:(NSString*)path error:(NSError**)error;

/**
 * Returns the models that match the provided ids.
 *
 * You must call `loadModelsAtPath:error:` before calling this method.
 *
 * @param modelIds Array of model ids in `NSString` format
 *
 * @return Array of `TIOModelBundle` matching the model ids
 */

- (NSArray<TIOModelBundle*>*)bundlesWithIds:(NSArray<NSString*>*)modelIds;

/**
 * Returns the single model that matches the provided id.
 *
 * You must call `loadModelsAtPath:error:` before calling this method.
 *
 * @param modelId The single model id whose bundle you would like.
 *
 * @return The `TIOModelBundle` matching the model id.
 */

- (nullable TIOModelBundle*)bundleWithId:(NSString*)modelId;

@end

NS_ASSUME_NONNULL_END
