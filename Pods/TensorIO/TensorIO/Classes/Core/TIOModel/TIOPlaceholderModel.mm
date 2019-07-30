//
//  TIOPlaceholderModel.m
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

#import "TIOPlaceholderModel.h"

#import "TIOLayerInterface.h"
#import "TIOModelBundle.h"
#import "TIOData.h"
#import "TIOLayerInterface.h"
#import "TIOLayerDescription.h"
#import "TIOPixelBufferLayerDescription.h"
#import "TIOVectorLayerDescription.h"
#import "TIOModelIO.h"

@implementation TIOPlaceholderModel

+ (nullable instancetype)modelWithBundleAtPath:(NSString *)path {
    return [[[TIOModelBundle alloc] initWithPath:path] newModel];
}

- (void)dealloc {
    #ifdef DEBUG
    NSLog(@"Deallocating model");
    #endif
}

- (nullable instancetype)initWithBundle:(TIOModelBundle *)bundle {
    if (self = [super init]) {
        _bundle = bundle;
        _options = bundle.options;
        
        _identifier = bundle.identifier;
        _name = bundle.name;
        _details = bundle.details;
        _author = bundle.author;
        _license = bundle.license;
        _placeholder = bundle.placeholder;
        _quantized = bundle.quantized;
        _type = bundle.type;
        _io = bundle.io;
    }
    
    return self;
}

// MARK: - Model Memory Management

/**
 * Loads a model into memory and sets `loaded` = `YES`. A placeholder model does nothing here.
 */

- (BOOL)load:(NSError * _Nullable *)error {
    _loaded = YES;
    return YES;
}

/**
 * Unloads the model and sets `loaded` =`NO`. A placeholder model doest nothing here.
 */

- (void)unload {
    _loaded = NO;
}

// MARK: - Perform Inference

/**
 * A placeholder model performs no inference and returns an empty dictionary
 */

- (id<TIOData>)runOn:(id<TIOData>)input error:(NSError* _Nullable *)error {
    return @{};
}

- (id<TIOData>)runOn:(id<TIOData>)input placeholders:(nullable NSDictionary<NSString*,id<TIOData>> *)placeholders error:(NSError* _Nullable *)error {
    return @{};
}

- (id<TIOData>)run:(TIOBatch *)batch error:(NSError * _Nullable *)error {
    return @{};
}

- (id<TIOData>)run:(TIOBatch *)batch placeholders:(nullable NSDictionary<NSString*,id<TIOData>> *)placeholders error:(NSError * _Nullable *)error {
    return @{};
}

- (id<TIOData>)runOn:(id<TIOData>)input __attribute__((deprecated)) {
    return @{};
}

@end
