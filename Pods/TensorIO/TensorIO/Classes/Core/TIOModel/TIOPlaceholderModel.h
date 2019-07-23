//
//  TIOPlaceholderModel.h
//  TensorIO
//
//  Created by Philip Dow on 1/11/19.
//  Copyright © 2019 doc.ai (http://doc.ai)
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
 * A placeholder model declares an interface but does not contain any underlying model
 * implementation. It is used to gather labeled data for a model that has not been trained
 * yet. Performing inference with a placeholder model will return an empty result.
 */

@interface TIOPlaceholderModel : NSObject <TIOModel>

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

// MARK: - Initialization

- (nullable instancetype)initWithBundle:(TIOModelBundle *)bundle NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;

+ (nullable instancetype)modelWithBundleAtPath:(NSString *)path;

// MARK: - Lifecycle

- (BOOL)load:(NSError * _Nullable *)error;
- (void)unload;

// MARK: - Run

- (id<TIOData>)runOn:(id<TIOData>)input error:(NSError* _Nullable *)error;
- (id<TIOData>)runOn:(id<TIOData>)input placeholders:(nullable NSDictionary<NSString*,id<TIOData>> *)placeholders error:(NSError* _Nullable *)error;
- (id<TIOData>)run:(TIOBatch *)batch error:(NSError * _Nullable *)error;
- (id<TIOData>)run:(TIOBatch *)batch placeholders:(nullable NSDictionary<NSString*,id<TIOData>> *)placeholders error:(NSError * _Nullable *)error;
- (id<TIOData>)runOn:(id<TIOData>)input __attribute__((deprecated));

@end

NS_ASSUME_NONNULL_END
