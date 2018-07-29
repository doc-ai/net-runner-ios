//
//  ImageNetClassificationModel.m
//  tflite_camera_example
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

#include "tensorflow/contrib/lite/kernels/register.h"
#include "tensorflow/contrib/lite/model.h"
#include "tensorflow/contrib/lite/string_util.h"
#include "tensorflow/contrib/lite/tools/mutable_op_resolver.h"

#include <vector>

#define LOG(x) std::cerr

// MARK: -

@interface ImageNetClassificationModelFloat32: ImageNetClassificationModel
@end

// MARK: -

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
    
    // Vision Model Initialization
    
    NSDictionary *input = bundle.info[@"input"];
    
    if ( input == nil ) {
        NSLog(@"Expected input dictionary field in model.json, none found");
        return nil;
    }
    
    _imageVolume = ImageVolumeForShape(input[@"shape"]);
    
    if ( ImageVolumesEqual(_imageVolume, kNoImageVolume ) ) {
        NSLog(@"Expected input.shape array field with three elements in model.json, found %@", input[@"shape"]);
        return nil;
    }
    
    _pixelFormat = PixelFormatForString(input[@"format"]);
    
    if ( _pixelFormat == OSTypeNone ) {
        NSLog(@"Expected input.format string to be RGB or BGR in model.json, found %@", input[@"format"]);
        return nil;
    }
    
    _normalization = PixelNormalizationForInput(input);
    _normalizer = PixelNormalizerForInput(input);
    
    // Do want to be able to report some kind of error here if the normalize string was incorrect,
    // but no normalization is a valid option. Maybe the bundle should be clear about that
    
    // NSLog(@"Expected input.normalize string or input.scale and input.bias strings, found normalize: %@, scale: %@, bias: %@", input[@"normalize"], input[@"scale"], input[@"bias"]);
    // return nil;
    
    return self;
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
        LOG(FATAL) << "Failed to mmap model " << graphPath;
        *error = kTFModelLoadModelError;
        return NO;
    }

    LOG(INFO) << "Loaded model " << graphPath;
    model->error_reporter();
    LOG(INFO) << "resolved reporter";

    tflite::ops::builtin::BuiltinOpResolver resolver;

    // Load labels

    LoadLabels(labelsPath, &labels);

    // Build model

    tflite::InterpreterBuilder(*model, resolver)(&interpreter);
   
    if (!interpreter) {
        LOG(FATAL) << "Failed to construct interpreter";
        *error = kTFModelConstructInterpreterError;
        return NO;
    }
    if (interpreter->AllocateTensors() != kTfLiteOk) {
        LOG(FATAL) << "Failed to allocate tensors!";
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

- (ImageNetClassificationModelOutput*)runModelOn:(CVPixelBufferRef)pixelBuffer {
    if ( !_loaded ) { [self load:nil]; }
    
    ImageNetClassificationModelOutput *output;

    // Prepare input: copy pixel buffer to input tensor
    
    [self _prepareInputs:pixelBuffer];
    
    // Run inference
    
    [self _runInference];
    
    // Capture output and interpret
    
    output = [self _captureOutputs];
    
    return output;
}

/**
 * Prepare inputs by scaling and cropping pixel buffer and copying it to the input tensor.
 * Base class implementation is effectively a virtual function so that subclasses can handle differences between weight sizes
 *
 * Was super nice to use `auto* tensor = interpreter->typed_tensor<weight_t>(input)` where `weight_t` was `float32_t` or `uint8_t`
 * but not sure how we can simplify without the switch. Problem is we can't use c++ templates with obj-c methods and
 * model weights may only be known at runtime.
 *
 * @param pixelBuffer core video pixel buffer that will be preprocessed and passed to the model
 */

- (void)_prepareInputs:(CVPixelBufferRef)pixelBuffer  {
    NSAssert(NO, @"Do not call this method directly, use one of ImageNetClassificationModel's subclasses");
}

/**
 * Run inference. You must call `_prepareInputs` first
 */

- (void)_runInference {
    if (interpreter->Invoke() != kTfLiteOk) {
        LOG(FATAL) << "Failed to invoke!";
    }
}

/**
 * Capture output and interpret. Base class implementation is effectively a virtual function
 * so that subclasses can handle differences between weight sizes
 *
 * @return top five predictions
 */

- (ImageNetClassificationModelOutput*)_captureOutputs {
    NSAssert(NO, @"Do not call this method directly, use one of ImageNetClassificationModel's subclasses");
    return nil;
}

- (CVPixelBufferRef)inputPixelBuffer {
    return _inputPixelBuffer;
}

- (void)setInputPixelBuffer:(CVPixelBufferRef _Nonnull)pixelBuffer {
    CVPixelBufferRelease(_inputPixelBuffer);
    _inputPixelBuffer = pixelBuffer;
    CVPixelBufferRetain(_inputPixelBuffer);
}

@end

// MARK: -

@implementation ImageNetClassificationModelFloat32

- (void)_prepareInputs:(CVPixelBufferRef)pixelBuffer  {
    int input = interpreter->inputs()[0];
    float32_t* tensor = interpreter->typed_tensor<float32_t>(input);

    CVPixelBufferCopyToTensor(pixelBuffer, tensor, self.imageVolume, self.normalizer);
    [self setInputPixelBuffer:pixelBuffer];
}

- (ImageNetClassificationModelOutput*)_captureOutputs {
    float32_t* output = interpreter->typed_output_tensor<float32_t>(0);
    NSDictionary *predictions = CaptureOutput(output, labels);
    return [[ImageNetClassificationModelOutput alloc] initWithDictionary:predictions];
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

- (ImageNetClassificationModelOutput*)_captureOutputs {
    uint8_t* output = interpreter->typed_output_tensor<uint8_t>(0);
    NSDictionary *predictions = CaptureOutput(output, labels);
    return [[ImageNetClassificationModelOutput alloc] initWithDictionary:predictions];
}

@end
