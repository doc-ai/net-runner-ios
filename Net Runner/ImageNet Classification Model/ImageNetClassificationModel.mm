//
//  ImageNetClassificationModel.m
//  Net Runner
//
//  Created by Philip Dow on 7/5/18.
//  Copyright © 2018 doc.ai. All rights reserved.
//

#import "ImageNetClassificationModel.h"

#import "ImageNetClassificationHelpers.h"
#import "ImageNetClassificationModelOutput.h"
#import "ModelBundle.h"
#import "ModelHelpers.h"
#import "Utilities.h"
#import "VisionModelHelpers.h"

#include <vector>

#include "tensorflow/contrib/lite/kernels/register.h"
#include "tensorflow/contrib/lite/model.h"
#include "tensorflow/contrib/lite/string_util.h"
#include "tensorflow/contrib/lite/tools/mutable_op_resolver.h"

@interface ImageNetClassificationModelFloat32: ImageNetClassificationModel
@end

@interface ImageNetClassificationModelUInt8: ImageNetClassificationModel
@end

// MARK: -

@implementation ImageNetClassificationModel {
    @protected
    std::vector<std::string> labels;
    std::unique_ptr<tflite::FlatBufferModel> model;
    std::unique_ptr<tflite::Interpreter> interpreter;
    
    CVPixelBufferRef _inputPixelBuffer;
}

- (void)dealloc {
    #ifdef DEBUG
    NSLog(@"Deallocating model");
    #endif
}

- (nullable instancetype)initWithBundle:(ModelBundle*)bundle {
    
    // Use class cluster to handle models with different weight sizes, would like to unify this if possible
    
    if ( bundle.quantized ) {
        self = [[ImageNetClassificationModelUInt8 alloc] init];
        _weightSize = ModelWeightSizeUInt8;
    } else {
        self = [[ImageNetClassificationModelFloat32 alloc] init];
        _weightSize = ModelWeightSizeFloat32;
    }
    
    // Model Initialization
    
    _bundle = bundle;
    _options = bundle.options;
    
    _identifier = bundle.identifier;
    _name = bundle.name;
    _details = bundle.details;
    _author = bundle.author;
    _license = bundle.license;
    _quantized = bundle.quantized;
    _type = bundle.type;
    
    // Vision Model Initialization
    
    NSDictionary *input = bundle.info[@"input"];
    
    if ( input == nil ) {
        NSLog(@"Expected input dictionary field in model.json, none found");
        return nil;
    }
    
    _imageVolume = ImageVolumeForShape(input[@"shape"]);
    
    if ( ImageVolumesEqual(_imageVolume, kImageVolumeInvalid ) ) {
        NSLog(@"Expected input.shape array field with three elements in model.json, found %@", input[@"shape"]);
        return nil;
    }
    
    _pixelFormat = PixelFormatForString(input[@"format"]);
    
    if ( _pixelFormat == PixelFormatTypeInvalid ) {
        NSLog(@"Expected input.format string to be RGB or BGR in model.json, found %@", input[@"format"]);
        return nil;
    }
    
    _normalization = PixelNormalizationForInput(input);
    _normalizer = PixelNormalizerForInput(input);
    
    if ( PixelNormalizationsEqual(_normalization, kPixelNormalizationInvalid) ) {
        NSLog(@"Expected input.normalizer string to be '[0,1]' or '[-1,1]', or input.scale and input.bias values, found normalization: %@, scale: %@, bias: %@", input[@"normalize"], input[@"scale"], input[@"bias"]);
        return nil;
    }
    
    return self;
}

- (CVPixelBufferRef)inputPixelBuffer {
    return _inputPixelBuffer;
}

- (void)setInputPixelBuffer:(CVPixelBufferRef _Nonnull)pixelBuffer {
    CVPixelBufferRelease(_inputPixelBuffer);
    _inputPixelBuffer = pixelBuffer;
    CVPixelBufferRetain(_inputPixelBuffer);
}

- (BOOL)load:(NSError**)error {
    if ( _loaded ) {
        return YES;
    }
    
    NSString *graphPath = self.bundle.modelFilepath;
    NSString *labelsPath = [self.bundle.path stringByAppendingPathComponent:_bundle.info[@"model"][@"labels"]];
    
    // Load Graph

    model = tflite::FlatBufferModel::BuildFromFile([graphPath UTF8String]);
    
    if (!model) {
        NSLog(@"Failed to mmap model at path %@", graphPath);
        *error = kTFModelLoadModelError;
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

    // Load labels

    LoadLabels(labelsPath, &labels);

    // Build model

    tflite::InterpreterBuilder(*model, resolver)(&interpreter);
   
    if (!interpreter) {
        NSLog(@"Failed to construct interpreter for model %@", self.identifier);
        *error = kTFModelConstructInterpreterError;
        return NO;
    }
    if (interpreter->AllocateTensors() != kTfLiteOk) {
        NSLog(@"Failed to allocate tensors for model %@", self.identifier);
        *error = kTFModelAllocateTensorsError;
        return NO;
    }
    
    _loaded = YES;
    
    return YES;
}

- (void)unload {
    CVPixelBufferRelease(_inputPixelBuffer);
    _inputPixelBuffer = nil;
    
    labels.clear(); // does not free memory
    
    interpreter.reset();
    model.reset();
   
    interpreter = nil;
    model = nil;
   
    _loaded = NO;
}

- (NSDictionary*)runModelOn:(CVPixelBufferRef)pixelBuffer {
    if ( !_loaded ) {
        [self load:nil];
    }
    
    // Prepare input: copy pixel buffer to input tensor
    
    [self _prepareInputs:pixelBuffer];
    
    // Run inference
    
    [self _runInference];
    
    // Capture output and interpret
    
    return [self _captureOutputs];
}

/**
 * Copies the pixel buffer to the input tensor, applying a normalization function if the
 * model is unquantized and one is specified.
 *
 * The base class implementation is effectively a virtual function so that subclasses
 * can handle differences between weight sizes.
 *
 * Was super nice to use `auto* tensor = interpreter->typed_tensor<weight_t>(input)` where
 * `weight_t` was `float32_t` or `uint8_t`, but wee can't use c++ templates with obj-c methods and
 * model weights may only be known at runtime.
 *
 * @param pixelBuffer pixel buffer that will be normalized and passed to the model.
 */

- (void)_prepareInputs:(CVPixelBufferRef)pixelBuffer  {
    NSAssert(NO, @"Do not call this method directly, use one of ImageNetClassificationModel's subclasses");
}

/**
 * Run inference. You must call `_prepareInputs:` first
 */

- (void)_runInference {
    if (interpreter->Invoke() != kTfLiteOk) {
        NSLog(@"Failed to invoke for model %@", self.identifier);
    }
}

/**
 * Capture output and interpret.
 *
 * Base class implementation is effectively a virtual function so that subclasses can handle differences between weight sizes.
 *
 * @return Top five predictions
 */

- (NSDictionary*)_captureOutputs {
    NSAssert(NO, @"Do not call this method directly, use one of ImageNetClassificationModel's subclasses");
    return nil;
}

@end

// MARK: -

@implementation ImageNetClassificationModelFloat32

- (void)_prepareInputs:(CVPixelBufferRef)pixelBuffer  {
    int input = interpreter->inputs()[0];
    float_t* tensor = interpreter->typed_tensor<float_t>(input);

    CVPixelBufferCopyToTensor(pixelBuffer, tensor, self.imageVolume, self.normalizer);
    [self setInputPixelBuffer:pixelBuffer];
}

- (NSDictionary*)_captureOutputs {
    float_t* output = interpreter->typed_output_tensor<float_t>(0);
    return CaptureOutput(output, labels);
}

@end

// MARK: -

@implementation ImageNetClassificationModelUInt8

- (void)_prepareInputs:(CVPixelBufferRef)pixelBuffer  {
    int input = interpreter->inputs()[0];
    uint8_t* tensor = interpreter->typed_tensor<uint8_t>(input);
    
    CVPixelBufferCopyToTensor(pixelBuffer, tensor, self.imageVolume, self.normalizer);
    [self setInputPixelBuffer:pixelBuffer];
}

- (NSDictionary*)_captureOutputs {
    uint8_t* output = interpreter->typed_output_tensor<uint8_t>(0);
    return CaptureOutput(output, labels);
}

@end
