//
//  ModelManager.h
//  Net Runner
//
//  Created by Phil Dow on 9/27/18.
//  Copyright © 2018 doc.ai. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * Notification posted when a model is deleted
 *
 * The `"model"` key contains the identifier of the model that was deleted.
 */

extern NSString * const NRModelManagerDidDeleteModelNotification;

@class TIOModelBundle;

/**
 * Wraps the `TIOModelBundleManager` to provide application specific functionality
 * such as model location and deleting models.
 */

@interface ModelManager : NSObject

/**
 * Returns the shared model manager.
 */

+ (instancetype)sharedManager;

/**
 * Returns an array of model ids that ship with the application.
 *
 * These models cannot, for example, be deleted.
 */

- (NSArray<NSString*>*)defaultModelIDs;

/*!
 @abstract Returns path to the directory of models presented to Net Runner at build time
 @discussion The models at this path are copied over to the modelsPath and loaded from there
 when the application is run. Apart from the first time that Net Runner is launched, the
 models in this directory are not used.
 */

- (NSString*)initialModelsPath;

/*!
 @abstract Returns path to the directory from which Net Runner loads models at run time
 @discussion Net Runner only loads models from this directory when it is launched.
 */

- (NSString*)modelsPath;

/**
 * Deletes the specified model, removing it from the file system
 *
 * @param modelBundle A bundle representing the model you'd like to delete
 * @param error Pointer to an error that will be set if the model cannot be deleted
 *
 * @return BOOL `YES` if the model is succeesfully deleted, `NO` otherwise
 */

- (BOOL)deleteModel:(TIOModelBundle*)modelBundle error:(NSError**)error;

@end

NS_ASSUME_NONNULL_END
