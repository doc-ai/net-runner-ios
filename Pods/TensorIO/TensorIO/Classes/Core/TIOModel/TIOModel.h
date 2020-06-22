//
//  TIOModel.h
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

#import "TIOModelBundle.h"

NS_ASSUME_NONNULL_BEGIN

@protocol TIOData;
@protocol TIOLayerDescription;
@class TIOLayerInterface;
@class TIOModelOptions;
@class TIOModelModes;
@class TIOBatch;
@class TIOModelIO;

/**
 * An Obj-C wrapper around lower level, usually C++ model implementations. This is the primary
 * API provided by the TensorIO framework.
 *
 * A `TIOModel` is built from a bundle folder that contains the underlying model, a json description
 * of the model's input and output layers, and any additional assets required by the model, for
 * example, output labels.
 *
 * A conforming `TIOModel` begins by parsing a json description of the model's input and output
 * layers, producing a `TIOLayerInterface` for each layer. Each layer is fully described by a
 * conforming `TIOLayerDescription`, which describes the data the layer expects or produces, for
 * example, whether it is quantized, any transformations that should be applied to it, and the
 * number of bytes the layer expects.
 *
 * To perform inference with the underlying model, call `runOn:` with a conforming `TIOData` object.
 * `TIOData` objects simply know how to copy bytes to and receive bytes from a model's input
 * and output layers. Internally, this method matches `TIOData` objects with their corresponding
 * layers and ensures that bytes are copied to the right place. The `runOn:` method then returns a
 * conforming `TIOData` object, which is the result of performing inference with the model.
 * Objects that conform to the `TIOData` protocol include `NSNumber`, `NSArray`, `NSData`,
 * `NSDictionary`, and `TIOPixelBuffer`, which wraps a `CVPixelBuffer` for computer vision models.
 *
 * For more information about a model's interface, refer to the `TIOLayerInterface` and
 * `TIOLayerDescription` classes. For more information about the kinds of Objective-C data a
 * `TIOModel` can work with, refer to the `TIOData` protocol and its conforming classes. For more
 * information about the JSON file which describes a model, see TIOModelBundleJSONSchema.h
 *
 * Note that, currently, only TensorFlow Lite (TFLite) models are supported.
 *
 * @warning
 * Models are not thread safe. Models may be used on separate threads, so that you can perform
 * inference off the main thread, but you should not use the same model from multiple threads.
 */

@protocol TIOModel <NSObject>

/**
 * The `TIOModelBundle` object from which this model was instantiated.
 */

@property (readonly) TIOModelBundle *bundle;

/**
 * Options associated with this model.
 */

@property (readonly) TIOModelOptions *options;

/**
 * A string uniquely identifying this model, taken from the model bundle.
 */

@property (readonly) NSString* identifier;

/**
 * Human readable name of the model, taken from the model bundle.
 */

@property (readonly) NSString* name;

/**
 * Additional information about the model, taken from the model bundle.
 */

@property (readonly) NSString* details;

/**
 * The model's authors, taken from the model bundle.
 */

@property (readonly) NSString* author;

/**
 * The model's license, taken from the model bundle.
 */

@property (readonly) NSString* license;

/**
 * A boolean value indicating if this is a placeholder bundle.
 *
 * A placeholder bundle has no underlying model and instantiates a `TIOModel` that does nothing.
 * Placeholders bundles are used to collect labeled data for models that haven't been trained yet.
 */

@property (readonly) BOOL placeholder;

/**
 * A boolean value indicating if the model is quantized or not.
 *
 * Quantized models have 8 bit `uint8_t` interfaces while unquantized modesl have 32 bit, `float_t`
 * interfaces.
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
 * A boolean value indicating whether the model has been loaded or not. Conforming classes may want
 * to wrap the underlying models such that they can be aggressively loaded and unloaded from memory,
 * as some models contain hundreds of megabytes of paramters.
 */

@property (readonly) BOOL loaded;

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

// MARK: - Initialization

/**
 * The designated initializer for conforming classes.
 *
 * You should not need to call this method directly. Instead, acquire an instance of a `TIOModelBundle`
 * associated with this model by way of the model's identifier. Then the `TIOModelBundle` class
 * calls this `initWithBundle:` factory initialization method, which conforming classes may override
 * to support custom initialization.
 *
 * @param bundle `TIOModelBundle` containing information about the model and its path
 *
 * @return instancetype An instance of the conforming class, may be `nil`.
 */

- (nullable instancetype)initWithBundle:(TIOModelBundle *)bundle;

/**
 * Convenience method for initializing a model directly from bundle at some path
 *
 * @param path The path to the model bundle folder
 *
 * @return instancetype An instance of the model, or `nil`.
 */

+ (nullable instancetype)modelWithBundleAtPath:(NSString *)path;

// MARK: - Lifecycle

/**
 * Loads a model into memory.
 *
 * A model should load itself prior to running on any input, but consumers of the model may want
 * more control over when a model is loaded in order to avoid placing parameters into memory
 * before they are needed.
 *
 * Conforming classes should override this method to perform custom loading and set loaded=YES.
 *
 * @param error Set to one of the errors in TIOTFLiteErrors.h for TFLiteModels, or one of your own error.
 *
 * @return BOOL `YES` if the model is successfully loaded, `NO` otherwise.
 */

- (BOOL)load:(NSError * _Nullable *)error;

/**
 * Unloads a model from memory
 *
 * A model will unload its resources automatically when it is deallocated, but the unload function
 * may do this as well in order to provide finer grained control to consumers.
 *
 * Conforming classes should override this method to perform custom unloading and set `loaded=NO`.
 */

- (void)unload;

// MARK: - Run

/**
 * Performs inference on the provided input and returns the results. The primary
 * interface to a conforming class.
 *
 * @param input Any class conforming to `TIOData`.
 * @param error Set if an error occurred during inference. May be nil.
 * @return TIOData The results of performing inference on input.
 */

- (id<TIOData>)runOn:(id<TIOData>)input error:(NSError* _Nullable *)error;

/**
 * Performs inference on the provided input and returns the results.
 *
 * @warning
 * Not all model backends support the use of placeholders.
 *
 * @param input Any class conforming to `TIOData`.
 * @param placeholders A dictionary of `TIOData` conforming placeholder values,
 *  which will be matched to placeholder layers in the model. May be nil.
 * @param error Set if an error occurred during inference. May be nil.
 * @return TIOData The results of performing inference on input.
 */

- (id<TIOData>)runOn:(id<TIOData>)input placeholders:(nullable NSDictionary<NSString*,id<TIOData>> *)placeholders error:(NSError* _Nullable *)error;

/**
 * Performs inference on the provided batch and returns the results. A batch is
 * a more well defined way of providing data to a model and is comprised of
 * batch items, effectively rows of data, each of which contains feature values
 * as columns. See `TIOBatch` for more information.
 *
 * @param batch A batch of input data.
 * @param error Set if an error occurred during inference. May be nil.
 * @return TIOData The results of performing inference on input.
 */

- (id<TIOData>)run:(TIOBatch *)batch error:(NSError * _Nullable *)error;

/**
 * Performs inference on the provided batch and returns the results. A batch is
 * a more well defined way of providing data to a model and is comprised of
 * batch items, effectively rows of data, each of which contains feature values
 * as columns. See `TIOBatch` for more information.
 *
 * @warning
 * Not all model backends support the use of placeholders.
 *
 * @param batch A batch of input data.
 * @param placeholders A dictionary of `TIOData` conforming placeholder values,
 *  which will be matched to placeholder layers in the model. May be nil.
 * @param error Set if an error occurred during inference. May be nil.
 * @return TIOData The results of performing inference on input.
 */

- (id<TIOData>)run:(TIOBatch *)batch placeholders:(nullable NSDictionary<NSString*,id<TIOData>> *)placeholders error:(NSError * _Nullable *)error;

/**
 * Deprecated. Use `runOn:error:` or one of the other similar methods instead.
 */

- (id<TIOData>)runOn:(id<TIOData>)input __attribute__((deprecated));

@end

NS_ASSUME_NONNULL_END
