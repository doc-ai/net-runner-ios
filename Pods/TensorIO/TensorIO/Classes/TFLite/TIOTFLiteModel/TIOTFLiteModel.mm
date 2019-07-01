//
//  TIOTFLiteModel.mm
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

#import "TIOTFLiteModel.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdocumentation"

#include "tensorflow/lite/kernels/register.h"
#include "tensorflow/lite/model.h"
#include "tensorflow/lite/string_util.h"

#pragma clang diagnostic pop

#import "TIOModelBundle.h"
#import "TIOTFLiteErrors.h"
#import "TIOTFLiteData.h"
#import "TIOLayerInterface.h"
#import "TIOLayerDescription.h"
#import "TIOPixelBufferLayerDescription.h"
#import "TIOVectorLayerDescription.h"
#import "TIOPixelBuffer.h"
#import "NSArray+TIOTFLiteData.h"
#import "NSNumber+TIOTFLiteData.h"
#import "NSData+TIOTFLiteData.h"
#import "NSDictionary+TIOTFLiteData.h"
#import "TIOPixelBuffer+TIOTFLiteData.h"
#import "NSArray+TIOExtensions.h"
#import "TIOBatch.h"
#import "TIOModelIO.h"

@implementation TIOTFLiteModel {
    std::unique_ptr<tflite::FlatBufferModel> model;
    std::unique_ptr<tflite::Interpreter> interpreter;
}

+ (nullable instancetype)modelWithBundleAtPath:(NSString *)path {
    return [[TIOTFLiteModel alloc] initWithBundle:[[TIOModelBundle alloc] initWithPath:path]];
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
        _backend = bundle.backend;
        _modes = bundle.modes;
        _io = bundle.io;
    }
    
    return self;
}

// MARK: - Model Memory Management

/**
 * Loads a model into memory and sets loaded=YES
 *
 * @param error An error describing any failure to load the model
 *
 * @return BOOL `YES` if the model is successfully loaded, `NO` otherwise.
 */

- (BOOL)load:(NSError * _Nullable *)error {
    if ( _loaded ) {
        return YES;
    }
    
    NSString *graphPath = self.bundle.modelFilepath;
    
    // Load Graph

    model = tflite::FlatBufferModel::BuildFromFile([graphPath UTF8String]);
    
    if (!model) {
        NSLog(@"Failed to mmap model at path %@", graphPath);
        if (error) {
            *error = kTIOTFLiteModelLoadModelError;
        }
        return NO;
    }

    #ifdef DEBUG
    NSLog(@"Loaded model");
    #endif
    
    model->error_reporter();
    
    #ifdef DEBUG
    NSLog(@"Resolved reporter");
    #endif

    tflite::ops::builtin::BuiltinOpResolver resolver;

    // Build model

    tflite::InterpreterBuilder(*model, resolver)(&interpreter);
   
    if (!interpreter) {
        NSLog(@"Failed to construct interpreter for model %@", self.identifier);
        if (error) {
            *error = kTIOTFLiteModelConstructInterpreterError;
        }
        return NO;
    }
    if (interpreter->AllocateTensors() != kTfLiteOk) {
        NSLog(@"Failed to allocate tensors for model %@", self.identifier);
        if (error) {
            *error = kTIOTFLiteModelAllocateTensorsError;
        }
        return NO;
    }
    
    _loaded = YES;
    return YES;
}

/**
 * Unloads the model and sets loaded=NO
 */

- (void)unload {
    if ( !_loaded ) {
        return;
    }
    
    interpreter.reset();
    model.reset();
   
    interpreter = nil;
    model = nil;
   
    _loaded = NO;
}

// MARK: - Input and Output Features

- (NSArray<TIOLayerInterface*>*)inputs {;
    return self.io.inputs.all;
}

- (NSArray<TIOLayerInterface*>*)outputs {
    return self.io.outputs.all;
}

- (id<TIOLayerDescription>)descriptionOfInputAtIndex:(NSUInteger)index {
    return self.io.inputs[index].dataDescription;
}

- (id<TIOLayerDescription>)descriptionOfInputWithName:(NSString *)name {
    return self.io.inputs[name].dataDescription;
}

- (id<TIOLayerDescription>)descriptionOfOutputAtIndex:(NSUInteger)index {
    return self.io.outputs[index].dataDescription;
}

- (id<TIOLayerDescription>)descriptionOfOutputWithName:(NSString *)name {
    return self.io.outputs[name].dataDescription;
}

// MARK: - Perform Inference

- (id<TIOData>)runOn:(id<TIOData>)input {
    return [self runOn:input error:nil];
}

- (id<TIOData>)runOn:(id<TIOData>)input error:(NSError * _Nullable *)error {
    NSError *loadError;
    [self load:&loadError];
    
    if (loadError != nil) {
        NSLog(@"There was a problem loading the model from runOn, error: %@", loadError);
        if (*error) {
            *error = loadError;
        }
        return @{};
    }
    
    [self _prepareInput:input];
    [self _runInference];
    
    return [self _captureOutput];
}

- (id<TIOData>)run:(TIOBatch *)batch error:(NSError * _Nullable *)error {
    NSAssert([[NSSet setWithArray:batch.keys] isEqualToSet:[NSSet setWithArray:self.io.inputs.keys]], @"Batch keys do not match input layer names");
    NSAssert(batch.count == 1, @"Batch size must be 1 for TensorFlow Lite models");
    
    // Load
    
    NSError *loadError;
    [self load:&loadError];
    
    if (loadError != nil) {
        NSLog(@"There was a problem loading the model from run:error:, error: %@", loadError);
        if (*error) {
            *error = loadError;
        }
        return @{};
    }
    
    // Prepare Inputs
    
    TIOBatchItem *item = batch[0];
    
    for ( NSString *name in item ) {
        int index = [self.io.inputs indexForName:name].intValue;
        void *tensor = [self inputTensorAtIndex:index];
        TIOLayerInterface *interface = self.io.inputs[name];
        id<TIOData> input = item[name];
    
        [self _prepareInput:input tensor:tensor interface:interface];
    }
    
    // Run Inference and Return Output
    
    [self _runInference];
    return [self _captureOutput];
}

/**
 * Iterates through the provided `TIOData` inputs, matching them to the model's input layers, and
 * copies their bytes to those input layers.
 *
 * @param data Any class conforming to the `TIOData` protocol
 */

- (void)_prepareInput:(id<TIOData>)data  {
    
    // When preparing inputs we take into account the type of input provided
    // and the number of inputs that are available
    
    if ( [data isKindOfClass:NSDictionary.class] ) {
        
        // With a dictionary input, regardless the count, iterate through the keys and values, mapping them to indices,
        // and prepare the indexed tensors with the values
    
        NSDictionary<NSString*,id<TIOData>> *dictionaryData = (NSDictionary *)data;
        NSAssert([[NSSet setWithArray:dictionaryData.allKeys] isEqualToSet:[NSSet setWithArray:self.io.inputs.keys]],
            @"Batch keys do not match input layer names");
    
        for ( NSString *name in dictionaryData ) {
            int index = [self.io.inputs indexForName:name].intValue;
            void *tensor = [self inputTensorAtIndex:index];
            TIOLayerInterface *interface = self.io.inputs[name];
            id<TIOData> input = dictionaryData[name];
            
            [self _prepareInput:input tensor:tensor interface:interface];
        }
    }
    else if ( self.io.inputs.count == 1 ) {
    
        // If there is a single input available, simply take the input as it is
        
        void *tensor = [self inputTensorAtIndex:0];
        TIOLayerInterface *interface = self.io.inputs[0];
        id<TIOData> input = data;
        
        [self _prepareInput:input tensor:tensor interface:interface];
    }
    else {
        
        // With more than one input, we must accept an array
        
        assert( [data isKindOfClass:NSArray.class] );
        
        // With an array input, iterate through its entries, preparing the indexed tensors with their values
        
        NSArray<id<TIOData>> *arrayData = (NSArray *)data;
        assert(arrayData.count == self.io.inputs.count);
        
        for ( int index = 0; index < arrayData.count; index++ ) {
            void *tensor = [self inputTensorAtIndex:index];
            TIOLayerInterface *interface = self.io.inputs[index];
            id<TIOData> input = arrayData[index];
            
            [self _prepareInput:input tensor:tensor interface:interface];
        }
    }
}

/**
 * Requests the input to copy its bytes to the tensor
 *
 * @param input The data whose bytes will be copied to the tensor
 * @param tensor A pointer to the tensor which will receive those bytes
 * @param interface A description of the data which the tensor expects
 */

- (void)_prepareInput:(id<TIOData>)input tensor:(void *)tensor interface:(TIOLayerInterface *)interface {

    [interface
        matchCasePixelBuffer:^(TIOPixelBufferLayerDescription *pixelBufferDescription) {
            
            assert( [input isKindOfClass:TIOPixelBuffer.class] );
            
            [(id<TIOTFLiteData>)input getBytes:tensor description:pixelBufferDescription];
            
        } caseVector:^(TIOVectorLayerDescription *vectorDescription) {
            
            assert( [input isKindOfClass:NSArray.class]
                ||  [input isKindOfClass:NSData.class]
                ||  [input isKindOfClass:NSNumber.class] );
            
            [(id<TIOTFLiteData>)input getBytes:tensor description:vectorDescription];
        }];
}

/**
 * Runs inference on the model. Inputs must be copied to the input tensors prior to calling this method
 */

- (void)_runInference {
    if (interpreter->Invoke() != kTfLiteOk) {
        NSLog(@"Failed to invoke for model %@", self.identifier);
    }
}

/**
 * Captures outputs from the model.
 *
 * @return TIOData A class that is appropriate to the model output. Currently all outputs are
 * wrapped in an instance of `NSDictionary` whose keys are taken from the JSON description of the
 * model outputs.
 */

- (id<TIOData>)_captureOutput {
   
    NSMutableDictionary<NSString*,id<TIOData>> *outputs = [[NSMutableDictionary alloc] init];

    for ( int index = 0; index < self.io.outputs.count; index++ ) {
        TIOLayerInterface *interface = self.io.outputs[index];
        void *tensor = [self outputTensorAtIndex:index];
        
        id<TIOData> data = [self _captureOutput:tensor interface:interface];
        outputs[interface.name] = data;
    }

    return [outputs copy];
}

/**
 * Copies bytes from the tensor to an appropriate class that conforms to `TIOData`
 *
 * @param tensor The output tensor whose bytes will be captured
 * @param interface A description of the data which this tensor contains
 */

- (id<TIOData>)_captureOutput:(void *)tensor interface:(TIOLayerInterface *)interface {
    __block id<TIOData> data;
    
    [interface
        matchCasePixelBuffer:^(TIOPixelBufferLayerDescription * _Nonnull pixelBufferDescription) {
            
            data = [[TIOPixelBuffer alloc] initWithBytes:tensor description:pixelBufferDescription];
        
        } caseVector:^(TIOVectorLayerDescription * _Nonnull vectorDescription) {
            
            TIOVector *vector = [[TIOVector alloc] initWithBytes:tensor description:vectorDescription];
            
            if ( vectorDescription.isLabeled ) {
                // If the vector's output is labeled, return a dictionary mapping labels to values
                data = [vectorDescription labeledValues:vector];
            } else {
                // If the vector's output is single-valued just return that value
                data = vector.count == 1
                    ? vector[0]
                    : vector;
            }
        }];
    
    return data;
}

// MARK: - Utilities

/**
 * Returns a pointer to an input tensor at a given index
 */

- (void *)inputTensorAtIndex:(NSUInteger)index {
    int tensor_input = interpreter->inputs()[index];
    if ( self.quantized ) {
        return interpreter->typed_tensor<uint8_t>(tensor_input);
    } else {
        return interpreter->typed_tensor<float_t>(tensor_input);
    }
}

/**
 * Returns a pointer to an output tensor at a given index
 */

- (void *)outputTensorAtIndex:(NSUInteger)index {
    if ( self.quantized ) {
        return interpreter->typed_output_tensor<uint8_t>((int)index);
    } else {
        return interpreter->typed_output_tensor<float_t>((int)index);
    }
}

@end
