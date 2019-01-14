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
#import "NSDictionary+TIOData.h"
#import "TIOModelJSONParsing.h"

static NSString * const kTensorTypeVector = @"array";
static NSString * const kTensorTypeImage = @"image";

@implementation TIOPlaceholderModel {
    // Index to Interface Description
    NSArray<TIOLayerInterface*> *_indexedInputInterfaces;
    NSArray<TIOLayerInterface*> *_indexedOutputInterfaces;
    
    // Name to Interface Description
    NSDictionary<NSString*,TIOLayerInterface*> *_namedInputInterfaces;
    NSDictionary<NSString*,TIOLayerInterface*> *_namedOutputInterfaces;
    
    // Name to Index
    NSDictionary<NSString*,NSNumber*> *_namedInputToIndex;
    NSDictionary<NSString*,NSNumber*> *_namedOutputToIndex;
}

+ (nullable instancetype)modelWithBundleAtPath:(NSString*)path {
    return [[[TIOModelBundle alloc] initWithPath:path] newModel];
}

- (void)dealloc {
    #ifdef DEBUG
    NSLog(@"Deallocating model");
    #endif
}

- (nullable instancetype)initWithBundle:(TIOModelBundle*)bundle {
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
        
        // Input and output parsing
        
        NSArray<NSDictionary<NSString*,id>*> *inputs = bundle.info[@"inputs"];
        NSArray<NSDictionary<NSString*,id>*> *outputs = bundle.info[@"outputs"];
        
        if ( inputs == nil ) {
            NSLog(@"Expected input array field in model.json, none found");
            return nil;
        }
        
        if ( outputs == nil ) {
            NSLog(@"Expected output array field in model.json, none found");
            return nil;
        }
        
        if ( ![self _parseInputs:inputs] ) {
            NSLog(@"Unable to parse input field in model.json");
            return nil;
        }
        
        if ( ![self _parseOutputs:outputs] ) {
            NSLog(@"Unable to parse output field in model.json");
            return nil;
        }
    }
    
    return self;
}

- (nullable instancetype)init {
    self = [self initWithBundle:[[TIOModelBundle alloc] initWithPath:@""]];
    NSAssert(NO, @"Use the designated initializer initWithBundle:");
    return nil;
}

// MARK: - JSON Parsing

// TODO: Move JSON Parsing to an external function or to the model bundle class

/**
 * Enumerates through the json described inputs and constructs a `TIOLayerInterface` for each one.
 *
 * @param inputs An array of dictionaries describing the model's input layers
 *
 * @return BOOL `YES` if the json descriptions were successfully parsed, `NO` otherwise
 */

- (BOOL)_parseInputs:(NSArray<NSDictionary<NSString*,id>*>*)inputs {
    
    auto *indexedInputInterfaces = [NSMutableArray<TIOLayerInterface*> array];
    auto *namedInputInterfaces = [NSMutableDictionary<NSString*,TIOLayerInterface*> dictionary];
    auto *namedInputToIndex = [NSMutableDictionary<NSString*,NSNumber*> dictionary];
    
    auto isQuantized = self.quantized;
    auto isInput = YES;
    
    __block BOOL error = NO;
    
    [inputs enumerateObjectsUsingBlock:^(NSDictionary<NSString *,id> * _Nonnull input, NSUInteger idx, BOOL * _Nonnull stop) {
        
        NSString *type = input[@"type"];
        NSString *name = input[@"name"];
        
        TIOLayerInterface *interface;
        
        if ( [type isEqualToString:kTensorTypeVector] ) {
            interface = TIOTFLiteModelParseTIOVectorDescription(input, isInput, isQuantized, self->_bundle);
        } else if ( [type isEqualToString:kTensorTypeImage] ) {
            interface = TIOTFLiteModelParseTIOPixelBufferDescription(input, isInput, isQuantized);
        }
        
        if ( interface == nil ) {
            error = YES;
            *stop = YES;
            return;
        }
        
        [indexedInputInterfaces addObject:interface];
        namedInputInterfaces[name] = interface;
        namedInputToIndex[name] = @(idx);
    }];
    
    _indexedInputInterfaces = indexedInputInterfaces.copy;
    _namedInputInterfaces = namedInputInterfaces.copy;
    _namedInputToIndex = namedInputToIndex.copy;
    
    return !error;
}

/**
 * Enumerates through the json described outputs and constructs a `TIOLayerInterface` for each one.
 *
 * @param outputs An array of dictionaries describing the model's output layers
 *
 * @return BOOL `YES` if the json descriptions were successfully parsed, `NO` otherwise
 */

- (BOOL)_parseOutputs:(NSArray<NSDictionary<NSString*,id>*>*)outputs {
    
    auto *indexedOutputInterfaces = [NSMutableArray<TIOLayerInterface*> array];
    auto *namedOutputInterfaces = [NSMutableDictionary<NSString*,TIOLayerInterface*> dictionary];
    auto *namedOutputToIndex = [NSMutableDictionary<NSString*,NSNumber*> dictionary];
    
    auto isQuantized = self.quantized;
    auto isInput = NO;
    
    __block BOOL error = NO;
    
    [outputs enumerateObjectsUsingBlock:^(NSDictionary<NSString *,id> * _Nonnull output, NSUInteger idx, BOOL * _Nonnull stop) {
    
        NSString *type = output[@"type"];
        NSString *name = output[@"name"];
        
        TIOLayerInterface *interface;
        
        if ( [type isEqualToString:kTensorTypeVector] ) {
            interface = TIOTFLiteModelParseTIOVectorDescription(output, isInput, isQuantized, self->_bundle);
        } else if ( [type isEqualToString:kTensorTypeImage] ) {
            interface = TIOTFLiteModelParseTIOPixelBufferDescription(output, isInput, isQuantized);
        }
        
        if ( interface == nil ) {
            error = YES;
            *stop = YES;
            return;
        }
        
        [indexedOutputInterfaces addObject:interface];
        namedOutputInterfaces[name] = interface;
        namedOutputToIndex[name] = @(idx);
    }];
    
    _indexedOutputInterfaces = indexedOutputInterfaces.copy;
    _namedOutputInterfaces = namedOutputInterfaces.copy;
    _namedOutputToIndex = namedOutputToIndex.copy;
    
    return !error;
}

// MARK: - Model Memory Management

/**
 * Loads a model into memory and sets `loaded` = `YES`. A placeholder model does nothing here.
 */

- (BOOL)load:(NSError**)error {
    _loaded = YES;
    return YES;
}

/**
 * Unloads the model and sets `loaded` =`NO`. A placeholder model doest nothing here.
 */

- (void)unload {
    _loaded = NO;
}

// MARK: - Input and Output Features

- (NSArray<TIOLayerInterface*>*)inputs {
    return _indexedInputInterfaces;
}

- (NSArray<TIOLayerInterface*>*)outputs {
    return _indexedOutputInterfaces;
}

- (id<TIOLayerDescription>)descriptionOfInputAtIndex:(NSUInteger)index {
    return _indexedInputInterfaces[index].dataDescription;
}

- (id<TIOLayerDescription>)descriptionOfInputWithName:(NSString*)name {
    return _namedInputInterfaces[name].dataDescription;
}

- (id<TIOLayerDescription>)descriptionOfOutputAtIndex:(NSUInteger)index {
    return _indexedOutputInterfaces[index].dataDescription;
}

- (id<TIOLayerDescription>)descriptionOfOutputWithName:(NSString*)name {
    return _namedOutputInterfaces[name].dataDescription;
}

// MARK: - Perform Inference

/**
 * A placeholder model performs no inference and returns an empty dictionary
 */

- (id<TIOData>)runOn:(id<TIOData>)input {
    return @{};
}

@end
