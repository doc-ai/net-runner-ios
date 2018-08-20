//
//  ModelBundle.h
//  Net Runner
//
//  Created by Philip Dow on 7/20/18.
//  Copyright © 2018 doc.ai. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class TIOModelOptions;
@protocol Model;

extern NSString * const kTFModelBundleExtension;
extern NSString * const kTFModelInfoFile;

/**
 * Encapsulates information about a `Model` without actaully loading the model.
 *
 * A `ModelBundle` is used by the UI to show model details and is used to instantiate model
 * instances as a model factory. There is currently a one-to-one correspondence between a
 * `ModelBundle` and a .tfbundle folder in the models directory.
 *
 * A model bundle folder must contain at least a model.json file, which contains information
 * about the model. Some information is required, such as the identifier and name field,
 * while other information may be added as needed by your use case.
 *
 * See ModelBundleJSONSchema.h for a list of required fields and their types.
 */

@interface ModelBundle : NSObject

/**
 * The deserialized information contained in the model.json file.
 */

@property (readonly) NSDictionary *info;

/**
 * The full path to the model bundle folder.
 */

@property (readonly) NSString *path;

/**
 * A string uniquely identifying the model represented by this bundle.
 */

@property (readonly) NSString *identifier;

/**
 * Human readable name of the model represented by this bundle
 */

@property (readonly) NSString *name;

/**
 * The version of the model reprsented by this bundle.
 *
 * A model's unique identifier may remain the same as the version is incremented.
 */

@property (readonly) NSString *version;

/**
 * Additional information about the model represented by this bundle.
 */

@property (readonly) NSString *details;

/**
 * The authors of the model represented by this bundle.
 */

@property (readonly) NSString *author;

/**
 * The license of the model represented by this bundle.
 */

@property (readonly) NSString *license;

/**
 * A boolean value indicated if the model represnted by this bundle is quantized or not.
 */

@property (readonly) BOOL quantized;

/**
 * A string indicating the kind of model this is, e.g. "image.classification.imagenet"
 */

@property (readonly) NSString *type;

/**
 * Options associated with the model represented by this bundle.
 */

@property (readonly) TIOModelOptions *options;

/**
 * The file path to the actual underlying model contained in this bundle.
 *
 * Currently, only tflite models are supported.
 */

@property (readonly) NSString *modelFilepath;

/**
 * Designated initializer.
 *
 * @param path Fully qualified path to the model bundle folder.
 *
 * @return An instance of a `ModelBundle` or `nil` if no bundle could be loaded at that path.
 */

- (nullable instancetype)initWithPath:(NSString*)path NS_DESIGNATED_INITIALIZER;

/**
 * Use the designated initializer.
 */

- (instancetype)init NS_UNAVAILABLE;

/**
 * Creates and returns a new instance of the `Model` represented by this bundle.
 * Returns `nil` if the model cannot be instantiated.
 */

- (nullable id<Model>)newModel;

/**
 * Returns the path to an asset in the bundle
 *
 * @param filename Asset's filename, including extension
 *
 * @return NSString The full path to the file
 */

- (NSString*)pathToAsset:(NSString*)filename;

@end

NS_ASSUME_NONNULL_END
