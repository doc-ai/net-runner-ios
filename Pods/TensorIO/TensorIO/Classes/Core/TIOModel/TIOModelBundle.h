//
//  TIOModelBundle.h
//  TensorIO
//
//  Created by Philip Dow on 7/20/18.
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

NS_ASSUME_NONNULL_BEGIN

@class TIOModelOptions;
@class TIOModelModes;
@class TIOModelIO;
@protocol TIOModel;

/**
 * The file extension used to identify a TensorIO tensorflow or tensorflow lite
 * bundle, currently '.tfbundle'. This bundle extension is deprecated. Use
 * `TIOModelBundleExtension` instead and indicate the desired backend in the
 * model.json's model.backend field.
 */

extern NSString * const TIOTFModelBundleExtension __attribute__((deprecated));

/**
 * The file extension used to identify a TensorIO bundle, currently '.tiobundle'.
 */

extern NSString * const TIOModelBundleExtension;

/**
 * The name of the file inside a TensorIO bundle that contains the model spec, currently 'model.json'.
 */

extern NSString * const TIOModelInfoFile;

/**
 * The name of the directory inside a TensorIO bundle that contains additional data, currently 'assets'.
 */

extern NSString * const TIOModelAssetsDirectory;

/**
 * Encapsulates information about a `TIOModel` without actually loading the model.
 *
 * A `TIOModelBundle` is used by the UI to show model details and is used to instantiate model
 * instances as a model factory. There is currently a one-to-one correspondence between a
 * `TIOModelBundle` and a .tiobundle folder in the models directory.
 *
 * A model bundle folder must contain at least a model.json file, which contains information
 * about the model. Some information is required, such as the identifier and name field,
 * while other information may be added as needed by your use case.
 *
 * See TIOModelBundleJSONSchema.h for a list of required fields and their types.
 */

@interface TIOModelBundle : NSObject

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
 * A boolean value indicating if this is a placeholder bundle.
 *
 * A placeholder bundle has no underlying model and instantiates a `TIOModel` that does nothing.
 * Placeholders bundles are used to collect labeled data for models that haven't been trained yet.
 */

@property (readonly, getter=isPlaceholder) BOOL placeholder;

/**
 * A boolean value indicating if the model represnted by this bundle is quantized or not.
 */

@property (readonly) BOOL quantized;

/**
 * A string indicating the kind of model this is, e.g. "image.classification.imagenet"
 */

@property (readonly) NSString *type;

/**
 * A string indicating the backend to use with this model
 */

@property (readonly) NSString *backend;

/**
 * The modes available to this model, i.e. predict, train, and eval.
 */

@property (readonly) TIOModelModes *modes;

/**
 * Options associated with the model represented by this bundle.
 */

@property (readonly) TIOModelOptions *options;

/**
 * Contains the descriptions of the model's inputs, outputs, and placeholders
 * accessible by numeric index or by name. Not all model backends support
 * placeholders.
 *
 * @code
 * io.inputs[0]
 * io.inputs[@"image"]
 * io.outputs[0]
 * io.outputs[@"label"]
 * io.placeholders[0]
 * io.placeholders[@"label"]
 * @endcode
 */

@property (readonly) TIOModelIO *io;

/**
 * The file path to the actual underlying model contained in this bundle.
 *
 * Currently, only tflite models are supported. If this `placeholder` is `YES` this property
 * returns `nil`.
 */

@property (nullable, readonly) NSString *modelFilepath;

/**
 * Designated initializer.
 *
 * @param path Fully qualified path to the model bundle folder.
 *
 * @return An instance of a `TIOModelBundle` or `nil` if no bundle could be loaded at that path.
 */

- (nullable instancetype)initWithPath:(NSString *)path NS_DESIGNATED_INITIALIZER;

/**
 * Use the designated initializer.
 */

- (instancetype)init NS_UNAVAILABLE;

/**
 * Creates and returns a new instance of the `TIOModel` represented by this bundle.
 * Returns `nil` if the model cannot be instantiated.
 */

- (nullable id<TIOModel>)newModel;

/**
 * Returns the path to an asset in the bundle
 *
 * @param filename Asset's filename, including extension
 *
 * @return NSString The full path to the file
 */

- (NSString *)pathToAsset:(NSString *)filename;

@end

NS_ASSUME_NONNULL_END
