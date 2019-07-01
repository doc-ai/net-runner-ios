//
//  TIOTFLiteModel.h
//  TensorIO
//
//  Created by Philip Dow on 8/3/18.
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

#import "TIOLayerInterface.h"
#import "TIOData.h"
#import "TIOModel.h"

NS_ASSUME_NONNULL_BEGIN

@class TIOModelIO;

/**
 * An Objective-C wrapper around TensorFlow lite models that provides a unified interface to the
 * input and output layers of the underlying model.
 *
 * See `TIOModel` for more information about TensorIO models and for a description of the
 * conforming properties and methods here.
 */

@interface TIOTFLiteModel : NSObject <TIOModel>

+ (nullable instancetype)modelWithBundleAtPath:(NSString *)path;

// Model Protocol Properties

@property (readonly) TIOModelBundle *bundle;
@property (readonly) TIOModelOptions *options;
@property (readonly) NSString* identifier;
@property (readonly) NSString* name;
@property (readonly) NSString* details;
@property (readonly) NSString* author;
@property (readonly) NSString* license;
@property (readonly) BOOL placeholder;
@property (readonly) BOOL quantized;
@property (readonly) NSString *type;
@property (readonly) NSString *backend;
@property (readonly) TIOModelModes *modes;
@property (readonly) BOOL loaded;
@property (readonly) TIOModelIO *io;

// Model Protocol Methods

- (nullable instancetype)initWithBundle:(TIOModelBundle *)bundle NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;

- (BOOL)load:(NSError * _Nullable *)error;
- (void)unload;

/**
 * Performs inference on the provided input and returns the results. The primary
 * interface to a conforming class.
 *
 * @param input Any class conforming to `TIOData` that you want to run
 *  inference on
 *
 * @return TIOData The results of performing inference, or an empty dictionary
 *  if the model has not been loaded yet and a load error occurs.
 */

- (id<TIOData>)runOn:(id<TIOData>)input;
- (id<TIOData>)runOn:(id<TIOData>)input error:(NSError * _Nullable *)error;
- (id<TIOData>)run:(TIOBatch *)batch error:(NSError * _Nullable *)error;

// TODO: Where are these used? Can we deprecate them? By the data collection UI?
// Use `io` instead

@property (readonly) NSArray<TIOLayerInterface*> *inputs __attribute__((deprecated));
@property (readonly) NSArray<TIOLayerInterface*> *outputs __attribute__((deprecated));

- (id<TIOLayerDescription>)descriptionOfInputAtIndex:(NSUInteger)index __attribute__((deprecated));
- (id<TIOLayerDescription>)descriptionOfInputWithName:(NSString *)name __attribute__((deprecated));

- (id<TIOLayerDescription>)descriptionOfOutputAtIndex:(NSUInteger)index __attribute__((deprecated));
- (id<TIOLayerDescription>)descriptionOfOutputWithName:(NSString *)name __attribute__((deprecated));

@end

NS_ASSUME_NONNULL_END
