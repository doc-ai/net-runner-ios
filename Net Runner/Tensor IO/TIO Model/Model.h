//
//  Model.h
//  Net Runner
//
//  Created by Philip Dow on 7/10/18.
//  Copyright © 2018 doc.ai. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * The bit size of weights used by the model, either float32 ot uint8.
 * Quantized models use single byte weights while unquantized models
 * use four byte weights.
 */

typedef enum : NSUInteger {
    ModelWeightSizeFloat32,
    ModelWeightSizeUInt8,
} ModelWeightSize;

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
 * A boolean value indicated if the model is quantized or not. Quantized models have a weight size of `ModelWeightSizeUInt8`,
 * while unquantized models have a weight size of `ModelWeightSizeFloat32`.
 */

@property (readonly) BOOL quantized;

/**
 * A string indicating the kind of model this is, e.g. "image.classification.imagenet"
 */

@property (readonly) NSString *type;

/**
 * The model's weight size
 */

@property (readonly) ModelWeightSize weightSize;

/**
 * A boolen value indicated whether the model has been loaded or not. Conforming classes may want
 * to wrap the underlying models such that they can be aggressively loaded and unloaded from memory,
 * as some models contain hundreds of megabytes worth of paramters.
 */

@property (readonly) BOOL loaded;

/**
 * The `ModelBundle` calls the `initWithBundle:` factory initialization method,
 * which conforming classes may override to support custom initialization.
 *
 * @param bundle `ModelBundle` containing information about the model and its path
 */

- (nullable instancetype)initWithBundle:(ModelBundle*)bundle;

/**
 * A model should load itself before running on any input, but consumers of the model may want
 * more control over when a model is loaded in order to avoid placing parameters into memory
 * before they are needed.
 *
 * Conforming classes should override this method to perform custom loading and set loaded=YES.
 *
 * @param error Set to one of the errors in ModelHelpers.h or your own error.
 */

- (BOOL)load:(NSError**)error;

/**
 * A model should unload its resources automatically when it is deallocated, but the unload function
 * may do this as well in order to provide finer grained control to consumers.
 *
 * Conforming classes should override this method to perform custom unloading and set `loaded=NO`.
 */

- (void)unload;

// MARK: - New

- (id<TIOData>)runModelOn:(id<TIOData>)input;

- (id<TIODataDescription>)dataDescriptionForInputAtIndex:(NSUInteger)index;
- (id<TIODataDescription>)dataDescriptionForInputWithName:(NSString*)name;

- (id<TIODataDescription>)dataDescriptionForOutputAtIndex:(NSUInteger)index;
- (id<TIODataDescription>)dataDescriptionForOutputWithName:(NSString*)name;

@end

NS_ASSUME_NONNULL_END
