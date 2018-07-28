//
//  ModelBundle.h
//  tflite_camera_example
//
//  Created by Philip Dow on 7/20/18.
//  Copyright © 2018 doc.ai. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class ModelOptions;
@protocol Model;

extern NSString * const kTFModelBundleExtension;
extern NSString * const kTFModelInfoFile;

/**
 * Encapsulates information about a Model without actaully loading the model,
 * used by the UI to show model details, used to instantiate model instances as a model factory,
 * one-to-one correspondence with a .tfbundle folder in the models directory.
 */

@interface ModelBundle : NSObject

@property (readonly) NSDictionary *info;
@property (readonly) NSString *path;

@property (readonly) NSString *identifier;
@property (readonly) NSString *name;
@property (readonly) NSString *version;
@property (readonly) NSString *details;
@property (readonly) NSString *author;
@property (readonly) NSString *license;
@property (readonly) BOOL quantized;

@property (readonly) ModelOptions *options;
@property (readonly) NSString *modelFilepath;

- (nullable instancetype)initWithPath:(NSString*)path;

/**
 * Creates and returns a new instance of the Model represented by this bundle.
 * Returns nil if the model cannot be instantiated.
 */

- (nullable id<Model>)newModel;

@end

NS_ASSUME_NONNULL_END
