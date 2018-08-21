//
//  TIOTFLiteModel.h
//  TensorIO
//
//  Created by Philip Dow on 8/3/18.
//  Copyright © 2018 doc.ai. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "TIOLayerInterface.h"
#import "TIOData.h"
#import "TIOModel.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * An Objective-C wrapper around TensorFlow lite models that provides a unified interface to the
 * input and output layers of the underlying model.
 *
 * See `TIOModel` for more information about TensorIO models.
 */

@interface TIOTFLiteModel : NSObject <TIOModel>

// Model Protocol Properties

@property (readonly) TIOModelBundle *bundle;
@property (readonly) TIOModelOptions *options;
@property (readonly) NSString* identifier;
@property (readonly) NSString* name;
@property (readonly) NSString* details;
@property (readonly) NSString* author;
@property (readonly) NSString* license;
@property (readonly) BOOL quantized;
@property (readonly) NSString *type;
@property (readonly) BOOL loaded;

// Model Protocol Methods

- (nullable instancetype)initWithBundle:(TIOModelBundle*)bundle NS_DESIGNATED_INITIALIZER;

- (nullable instancetype)init NS_UNAVAILABLE;

- (BOOL)load:(NSError**)error;
- (void)unload;

- (id<TIOData>)runOn:(id<TIOData>)input;

- (id<TIOLayerDescription>)descriptionOfInputAtIndex:(NSUInteger)index;
- (id<TIOLayerDescription>)descriptionOfInputWithName:(NSString*)name;

- (id<TIOLayerDescription>)descriptionOfOutputAtIndex:(NSUInteger)index;
- (id<TIOLayerDescription>)descriptionOfOutputWithName:(NSString*)name;

@end

NS_ASSUME_NONNULL_END
