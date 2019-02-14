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

/**
 * An Objective-C wrapper around TensorFlow lite models that provides a unified interface to the
 * input and output layers of the underlying model.
 *
 * See `TIOModel` for more information about TensorIO models and for a description of the
 * conforming properties and methods here.
 */

@interface TIOTFLiteModel : NSObject <TIOModel>

+ (nullable instancetype)modelWithBundleAtPath:(NSString*)path;

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
@property (readonly) BOOL loaded;

@property (readonly) NSArray<TIOLayerInterface*> *inputs;
@property (readonly) NSArray<TIOLayerInterface*> *outputs;

// Model Protocol Methods

- (nullable instancetype)initWithBundle:(TIOModelBundle*)bundle NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;

- (BOOL)load:(NSError**)error;
- (void)unload;

- (id<TIOData>)runOn:(id<TIOData>)input;

- (id<TIOLayerDescription>)descriptionOfInputAtIndex:(NSUInteger)index;
- (id<TIOLayerDescription>)descriptionOfInputWithName:(NSString*)name;

- (id<TIOLayerDescription>)descriptionOfOutputAtIndex:(NSUInteger)index;
- (id<TIOLayerDescription>)descriptionOfOutputWithName:(NSString*)name;

@end

NS_ASSUME_NONNULL_END
