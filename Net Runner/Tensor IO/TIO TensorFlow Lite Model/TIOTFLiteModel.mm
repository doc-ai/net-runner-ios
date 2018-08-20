//
//  TIOTFLiteModel.m
//  Net Runner Parser
//
//  Created by Philip Dow on 8/3/18.
//  Copyright © 2018 doc.ai. All rights reserved.
//

#import "TIOTFLiteModel.h"

#import "TIOModelBundle.h"
#import "TIOTFLiteErrors.h"
#import "Utilities.h"

#include "tensorflow/contrib/lite/kernels/register.h"
#include "tensorflow/contrib/lite/model.h"
#include "tensorflow/contrib/lite/string_util.h"
#include "tensorflow/contrib/lite/tools/mutable_op_resolver.h"

#import "TIOData.h"
#import "TIODataInterface.h"
#import "TIODataDescription.h"
#import "TIOPixelBufferDescription.h"
#import "TIOVectorDescription.h"
#import "TIOPixelBuffer.h"
#import "NSArray+TIOData.h"
#import "NSNumber+TIOData.h"
#import "NSData+TIOData.h"
#import "NSDictionary+TIOData.h"
#import "NSArray+Extensions.h"
#import "TIOModelJSONParsing.h"

static NSString * const kTensorTypeVector = @"array";
static NSString * const kTensorTypeImage = @"image";

@implementation TIOTFLiteModel {
    @protected
    std::unique_ptr<tflite::FlatBufferModel> model;
    std::unique_ptr<tflite::Interpreter> interpreter;
    
    // Index to Interface Description
    NSArray<TIODataInterface*> *_indexedInputInterfaces;
    NSArray<TIODataInterface*> *_indexedOutputInterfaces;
    
    // Name to Interface Description
    NSDictionary<NSString*,TIODataInterface*> *_namedInputInterfaces;
    NSDictionary<NSString*,TIODataInterface*> *_namedOutputInterfaces;
    
    // Name to Index
    NSDictionary<NSString*,NSNumber*> *_namedInputToIndex;
    NSDictionary<NSString*,NSNumber*> *_namedOutputToIndex;
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

/**
 * Enumerates through the json described inputs and constructs a `TIODataInterface` for each one.
 *
 * @param inputs An array of dictionaries describing the model's input layers
 *
 * @return BOOL `YES` if the json descriptions were successfully parsed, `NO` otherwise
 */

- (BOOL)_parseInputs:(NSArray<NSDictionary<NSString*,id>*>*)inputs {
    
    auto *indexedInputInterfaces = [NSMutableArray<TIODataInterface*> array];
    auto *namedInputInterfaces = [NSMutableDictionary<NSString*,TIODataInterface*> dictionary];
    auto *namedInputToIndex = [NSMutableDictionary<NSString*,NSNumber*> dictionary];
    
    auto isQuantized = self.quantized;
    auto isInput = YES;
    
    __block BOOL error = NO;
    
    [inputs enumerateObjectsUsingBlock:^(NSDictionary<NSString *,id> * _Nonnull input, NSUInteger idx, BOOL * _Nonnull stop) {
        
        NSString *type = input[@"type"];
        NSString *name = input[@"name"];
        
        TIODataInterface *interface;
        
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
 * Enumerates through the json described outputs and constructs a `TIODataInterface` for each one.
 *
 * @param outputs An array of dictionaries describing the model's output layers
 *
 * @return BOOL `YES` if the json descriptions were successfully parsed, `NO` otherwise
 */

- (BOOL)_parseOutputs:(NSArray<NSDictionary<NSString*,id>*>*)outputs {
    
    auto *indexedOutputInterfaces = [NSMutableArray<TIODataInterface*> array];
    auto *namedOutputInterfaces = [NSMutableDictionary<NSString*,TIODataInterface*> dictionary];
    auto *namedOutputToIndex = [NSMutableDictionary<NSString*,NSNumber*> dictionary];
    
    auto isQuantized = self.quantized;
    auto isInput = NO;
    
    __block BOOL error = NO;
    
    [outputs enumerateObjectsUsingBlock:^(NSDictionary<NSString *,id> * _Nonnull output, NSUInteger idx, BOOL * _Nonnull stop) {
    
        NSString *type = output[@"type"];
        NSString *name = output[@"name"];
        
        TIODataInterface *interface;
        
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
 * Loads a model into memory and sets loaded=YES
 *
 * @param error An error describing any failure to load the model
 *
 * @return BOOL `YES` if the model is successfully loaded, `NO` otherwise.
 */

- (BOOL)load:(NSError**)error {
    if ( _loaded ) {
        return YES;
    }
    
    NSString *graphPath = self.bundle.modelFilepath;
    
    // Load Graph

    model = tflite::FlatBufferModel::BuildFromFile([graphPath UTF8String]);
    
    if (!model) {
        NSLog(@"Failed to mmap model at path %@", graphPath);
        *error = kTFLiteModelLoadModelError;
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
        *error = kTFLiteModelConstructInterpreterError;
        return NO;
    }
    if (interpreter->AllocateTensors() != kTfLiteOk) {
        NSLog(@"Failed to allocate tensors for model %@", self.identifier);
        *error = kTFLiteModelAllocateTensorsError;
        return NO;
    }
    
    _loaded = YES;
    
    return YES;
}

/**
 * Unloads the model and sets loaded=NO
 */

- (void)unload {
    interpreter.reset();
    model.reset();
   
    interpreter = nil;
    model = nil;
    
    _indexedInputInterfaces = nil;
    _indexedOutputInterfaces = nil;
    _namedInputInterfaces = nil;
    _namedOutputInterfaces = nil;
   
    _loaded = NO;
}

// MARK: - Input and Output Features

- (id<TIODataDescription>)descriptionOfInputAtIndex:(NSUInteger)index {
    return _indexedInputInterfaces[index].dataDescription;
}

- (id<TIODataDescription>)descriptionOfInputWithName:(NSString*)name {
    return _namedInputInterfaces[name].dataDescription;
}

- (id<TIODataDescription>)descriptionOfOutputAtIndex:(NSUInteger)index {
    return _indexedOutputInterfaces[index].dataDescription;
}

- (id<TIODataDescription>)descriptionOfOutputWithName:(NSString*)name {
    return _namedOutputInterfaces[name].dataDescription;
}

// MARK: - Perform Inference

/**
 * Prepares the model's input tensors and performs inference, returning the results.
 *
 * @param input Any class conforming to `TIOData` whose bytes will be copied to the input tensors
 *
 * @return TIOData The results of performing inference
 */

- (id<TIOData>)runOn:(id<TIOData>)input {
    [self _prepareInput:input];
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
    
        NSDictionary<NSString*,id<TIOData>> *dictionaryData = (NSDictionary*)data;
        assert(dictionaryData.count == _namedInputInterfaces.count);
    
        for ( NSString *name in dictionaryData ) {
            assert([_namedInputInterfaces.allKeys containsObject:name]);
            
            int index = _namedOutputToIndex[name].intValue;
            void *tensor = [self inputTensorAtIndex:index];
            TIODataInterface *interface = _namedInputInterfaces[name];
            id<TIOData> input = dictionaryData[name];
            
            [self _prepareInput:input tensor:tensor interface:interface];
        }
    }
    else if ( _indexedInputInterfaces.count == 1 ) {
    
        // If there is a single input available, simply take the input as it is
        
        void *tensor = [self inputTensorAtIndex:0];
        TIODataInterface *interface = _indexedInputInterfaces[0];
        id<TIOData> input = data;
        
        [self _prepareInput:input tensor:tensor interface:interface];
    }
    else {
        
        // With more than one input, we must accept an array
        
        assert( [data isKindOfClass:NSArray.class] );
        
        // With an array input, iterate through its entries, preparing the indexed tensors with their values
        
        NSArray<id<TIOData>> *arrayData = (NSArray*)data;
        assert(arrayData.count == _indexedInputInterfaces.count);
        
        for ( int index = 0; index < arrayData.count; index++ ) {
            void *tensor = [self inputTensorAtIndex:index];
            TIODataInterface *interface = _indexedInputInterfaces[index];
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

- (void)_prepareInput:(id<TIOData>)input tensor:(void *)tensor interface:(TIODataInterface*)interface {

    size_t byteSize = self.quantized ? sizeof(uint8_t) : sizeof(float_t);

    [interface
        matchCasePixelBuffer:^(TIOPixelBufferDescription *pixelBufferDescription) {
            
            assert( [input isKindOfClass:TIOPixelBuffer.class] );
            
            size_t byteCount
                = pixelBufferDescription.shape.width
                * pixelBufferDescription.shape.height
                * pixelBufferDescription.shape.channels
                * byteSize;
            
            [input getBytes:tensor length:byteCount description:pixelBufferDescription];
            
        } caseVector:^(TIOVectorDescription *vectorDescription) {
            
            assert( [input isKindOfClass:NSArray.class]
                ||  [input isKindOfClass:NSData.class]
                ||  [input isKindOfClass:NSNumber.class] );
            
            size_t byteCount
                = vectorDescription.length
                * byteSize;
            
            [input getBytes:tensor length:byteCount description:vectorDescription];
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
 * wrapped in an instance of `NSDictionary` whose keys are taken from the json description of the
 * model outputs.
 */

- (id<TIOData>)_captureOutput {
   
    NSMutableDictionary<NSString*,id<TIOData>> *outputs = [[NSMutableDictionary alloc] init];

    for ( int index = 0; index < _indexedOutputInterfaces.count; index++ ) {
        TIODataInterface *interface = _indexedOutputInterfaces[index];
        void *tensor = [self outputTensorAtIndex:index];
        
        id<TIOData> data = [self _captureOutput:tensor interface:interface];
        outputs[interface.name] = data;
    }

    return [outputs copy];
}

/**
 * Copies bytes from the tensor to an appropricate class that conforms to `TIOData`
 *
 * @param tensor The output tensor whose bytes will be captured
 * @param interface A description of the data which this tensor contains
 */

- (id<TIOData>)_captureOutput:(void *)tensor interface:(TIODataInterface*)interface {
    __block id<TIOData> data;
    
    [interface
        matchCasePixelBuffer:^(TIOPixelBufferDescription * _Nonnull pixelBufferDescription) {
            
            data = [[TIOPixelBuffer alloc] initWithBytes:tensor length:0 description:pixelBufferDescription];
        
        } caseVector:^(TIOVectorDescription * _Nonnull vectorDescription) {
            
            TIOVector *vector = [[TIOVector alloc] initWithBytes:tensor length:vectorDescription.length description:vectorDescription];
            
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
