//
//  Model.h
//  tflite_camera_example
//
//  Created by Philip Dow on 7/10/18.
//  Copyright © 2018 doc.ai. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    ModelWeightSizeFloat32,
    ModelWeightSizeUInt8,
} ModelWeightSize;

@class ModelBundle;
@class ModelOptions;

// MARK: -

@protocol Model <NSObject>

@property (readonly) ModelBundle *bundle;
@property (readonly) ModelOptions *options;

@property (readonly) NSString* identifier;
@property (readonly) NSString* name;
@property (readonly) NSString* details;
@property (readonly) NSString* author;
@property (readonly) NSString* license;
@property (readonly) BOOL quantized;
@property (readonly) ModelWeightSize weightSize;
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
 * @param error No error is currently set
 */

- (BOOL)load:(NSError**)error;

/**
 * A model should unload its resources automatically when it is deallocated, but the unload function
 * may do this as well in order to provide finer grained control to consumers.
 *
 * Conforming classes should override this method to perform custom unloading and set `loaded=NO`.
 */

- (void)unload;

@end

NS_ASSUME_NONNULL_END
