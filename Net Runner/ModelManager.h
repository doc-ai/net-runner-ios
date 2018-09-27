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
 * Wraps the `TIOModelBundleManager` to provide application specific functionality
 * such as model location and deleting models.
 */

@interface ModelManager : NSObject

/**
 * Returns the shared model manager.
 */

+ (instancetype)sharedManager;

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

@end

NS_ASSUME_NONNULL_END
