//
//  Model.h
//  Net Runner
//
//  Created by Philip Dow on 7/10/18.
//  Copyright © 2018 doc.ai. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol TIOData;
@protocol TIODataDescription;
@class ModelBundle;
@class ModelOptions;

// MARK: -

/**
 * An Obj-C wrapper around lower level, usually C++ model implementations.
 * Currently, only TensorFlow Lite (TFLite) models are supported.
 */

@protocol Model <NSObject>

/**
 * The `ModelBundle` object from which this model was instantiated.
 */

@property (readonly) ModelBundle *bundle;

/**
 * Options associated with this model.
 */

@property (readonly) ModelOptions *options;

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
 * A boolean value indicating whether the model has been loaded or not. Conforming classes may want
 * to wrap the underlying models such that they can be aggressively loaded and unloaded from memory,
 * as some models contain hundreds of megabytes of paramters.
 */

@property (readonly) BOOL loaded;

/**
 * The designated initializer for conforming classes.
 *
 * You should not need to call this method directly. Instead, acquire an instance of a `ModelBundle`
 * associated with this model by way of the model's identifier. Then the `ModelBundle` class
 * calls this `initWithBundle:` factory initialization method, which conforming classes may override
 * to support custom initialization.
 *
 * @param bundle `ModelBundle` containing information about the model and its path
 *
 * @return instancetype An instance of the conforming class, may be `nil`.
 */

- (nullable instancetype)initWithBundle:(ModelBundle*)bundle;

/**
 * Loads a model into memory.
 *
 * A model should load itself prior to running on any input, but consumers of the model may want
 * more control over when a model is loaded in order to avoid placing parameters into memory
 * before they are needed.
 *
 * Conforming classes should override this method to perform custom loading and set loaded=YES.
 *
 * @param error Set to one of the errors in ModelHelpers.h or your own error.
 *
 * @return BOOL `YES` if the model is successfully loaded, `NO` otherwise.
 */

- (BOOL)load:(NSError**)error;

/**
 * Unloads a model from memory
 *
 * A model will unload its resources automatically when it is deallocated, but the unload function
 * may do this as well in order to provide finer grained control to consumers.
 *
 * Conforming classes should override this method to perform custom unloading and set `loaded=NO`.
 */

- (void)unload;

/**
 * Performs inference on the provided input and returns the results. The primary interface to a
 * conforming class.
 *
 * @param input Any class conforming to `TIOData` that you want to run inference on
 *
 * @return TIOData The results of performing inference
 */

- (id<TIOData>)runOn:(id<TIOData>)input;

/**
 * Returns a description of the model's input at a given index
 *
 * Model inputs and outputs are organized by index and name. In the model.json file that descrbies
 * the interface to a model, an array of named inputs includes information such as the type of
 * data the input expects, its volume, and any transformations that will be applied to it.
 *
 * This information is encapsulated in a `TIODataDescription`, which is used to prepare
 * inputs provided to the `runOn:` method prior to performing inference. See ModelBundleJSONSchema.h
 * for more information about this json file.
 */

- (id<TIODataDescription>)descriptionOfInputAtIndex:(NSUInteger)index;

/**
 * Returns a description of the model's input for a given name
 *
 * Model inputs and outputs are organized by index and name. In the model.json file that descrbies
 * the interface to a model, an array of named inputs includes information such as the type of
 * data the input expects, its volume, and any transformations that will be applied to it.
 *
 * This information is encapsulated in a `TIODataDescription`, which is used to prepare
 * inputs provided to the `runOn:` method prior to performing inference. See ModelBundleJSONSchema.h
 * for more information about this json file.
 */
- (id<TIODataDescription>)descriptionOfInputWithName:(NSString*)name;

/**
 * Returns a description of the model's output at a given index
 *
 * Model inputs and outputs are organized by index and name. In the model.json file that descrbies
 * the interface to a model, an array of named inputs includes information such as the type of
 * data the input expects, its volume, and any transformations that will be applied to it.
 *
 * This information is encapsulated in a `TIODataDescription`, which is used to prepare the results
 * of performing inference and returned from the `runOn:` method. See ModelBundleJSONSchema.h
 * for more information about this json file.
 */

- (id<TIODataDescription>)descriptionOfOutputAtIndex:(NSUInteger)index;

/**
 * Returns a description of the model's output for a given name
 *
 * Model inputs and outputs are organized by index and name. In the model.json file that descrbies
 * the interface to a model, an array of named inputs includes information such as the type of
 * data the input expects, its volume, and any transformations that will be applied to it.
 *
 * This information is encapsulated in a `TIODataDescription`, which is used to prepare the results
 * of performing inference and returned from the `runOn:` method. See ModelBundleJSONSchema.h
 * for more information about this json file.
 */

- (id<TIODataDescription>)descriptionOfOutputWithName:(NSString*)name;

@end

NS_ASSUME_NONNULL_END
