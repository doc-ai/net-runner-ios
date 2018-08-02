//
//  VisionModelHelpers.h
//  Net Runner
//
//  Created by Philip Dow on 7/12/18.
//  Copyright © 2018 doc.ai. All rights reserved.
//

#ifndef VisionModelHelpers_h
#define VisionModelHelpers_h

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

#import "Model.h"
#include <stdio.h>

NS_ASSUME_NONNULL_BEGIN

// MARK: - Types

/**
 * Describes the input volume of a tensor that takes an image
 */

typedef struct ImageVolume {
    int width;
    int height;
    int channels;
} ImageVolume;

/**
 * Describes how pixel values in the range of `[0,255]` will be normalized for
 * non-quantized, float32 models.
 *
 * Pixels will be typically normalized to values in the range `[0,1]` or `[-1,+1]`,
 * although separate biases may be applied to each of the RGB channels.
 */

typedef struct PixelNormalization {
    float scale;
    float redBias;
    float greenBias;
    float blueBias;
} PixelNormalization;

/**
 * A `PixelNormalizer` is a function that transforms a pixel value in the range [0,255]
 * to some other range, where the transformation may be channel dependent.
 *
 * The normalizer will typically be constructed with the help of a `PixelNormalization`
 * struct or using one of the core or standard normalizers provided.
 *
 * @param value The single byte pixel value being transformed
 * @param channel The RGB channel of the pixel value being transformed
 *
 * @return float_t The transformed value
 */

typedef float_t (^PixelNormalizer)(const uint8_t &value, const uint8_t &channel);

/**
 * An invalid pixel normalization, used when there is an error parsing the normalization settings.
 */

extern const PixelNormalization kPixelNormalizationInvalid;

/**
 * No pixel normalization, so a scale of 1 and no bias.
 */

extern const PixelNormalization kPixelNormalizationNone;

/**
 * Pixel normalization from 0 to 1.
 *
 * A scale of 1.0/255.0.
 */

extern const PixelNormalization kPixelNormalizerZeroToOne;

/**
 * Pixel normalization from -1 to 1.
 *
 * A scale of 2.0/255.0 and a bias of -1 to each channel.
 */

extern const PixelNormalization kPixelNormalizerNegativeOneToOne;

/**
 * No image volume, used to represent an error reading the image volume from the model.json file.
 */

extern const ImageVolume kImageVolumeInvalid;

/**
 * No pixel format, used to represent an error reading the pixel format from the model.json file.
 */

extern const OSType PixelFormatTypeInvalid;

// MARK: - Core Pixel Normalizers

/**
 * A function that applies no normalization to the pixel values, `nil`.
 */

PixelNormalizer _Nullable PixelNormalizerNone();

/**
 * A function that applies a scaling factor and equal bias to each pixel channel.
 */

PixelNormalizer PixelNormalizerSingleBias(const PixelNormalization& normalization);

/**
 * A function that applies a scaling factor and different biases to each pixel channel.
 */

PixelNormalizer PixelNormalizerPerChannelBias(const PixelNormalization& normalization);

// MARK: - Helpers for Constructing Standard Pixel Normalizers

/**
 * Normalizes pixel values from a range of `[0,255]` to `[0,1]`.
 *
 * This is equivalent to applying a scaling factor of `1.0/255.0` and no channel bias.
 */

PixelNormalizer PixelNormalizerZeroToOne();

/**
 * Normalizes pixel values from a range of `[0,255]` to `[-1,1]`.
 *
 * This is equivalent to applying a scaling factor of `2.0/255.0` and a bias of `-1` to each channel.
 */

PixelNormalizer PixelNormalizerNegativeOneToOne();

// MARK: - Initialization Helpers

/**
 * Converts an array of shape values to an `ImageVolume`.
 */

ImageVolume ImageVolumeForShape(NSArray<NSNumber*> *shape);

/**
 * Converts a pixel format string such as `"RGB"` or `"BGR"` to a Core Video pixel format type.
 */

OSType PixelFormatForString(NSString* formatString);

/**
 * Returns the PixelNormalization given an input dictionary.
 */

PixelNormalization PixelNormalizationForInput(NSDictionary *input);

/**
 * Returns the PixelNormalizer given an input dictionary.
 */

PixelNormalizer _Nullable PixelNormalizerForInput(NSDictionary *input);

// MARK: - CVPixelBuffer Tensor Utilities

/**
 * `CVPixelBufferCopyToTensor` copies a pixel buffer in ARGB or BGRA format to a tensor,
 * which is a pointer to an array of float_t or uint8_t.
 *
 * The pixel buffer must already be in the shape and format expected by the input tensor,
 * with the shape parameter describing its dimensions. The alpha channel will be ignored.
 *
 * If a normalizer is provided then the pixel buffer's values will be scaled using the
 * normalizer.
 *
 * `tensor_t` will be `float_t` (32 bits) for an unquantized model or `uint8_t` (8 bits)
 * for a quantized model.
 *
 * @param pixelBuffer The pixel buffer that will be copied to the tensor.
 * @param tensor The tensor that will receive the pixel buffer values.
 * @param shape The shape, i.e. width, height, and number of channels of the tensor.
 * @param normalizer A scaling function that will be applied to the pixel values as
 * they are copied to the tensor. May be `nil`.
 */

template <typename tensor_t>
void CVPixelBufferCopyToTensor(CVPixelBufferRef pixelBuffer, tensor_t* _Nonnull tensor, ImageVolume shape, _Nullable PixelNormalizer normalizer) {
    if ( normalizer == nil ) {
        CVPixelBufferCopyToTensor(pixelBuffer, tensor, shape);
        return;
    }
    
    assert(pixelBuffer != NULL);
    assert(tensor != NULL);
    
    CFRetain(pixelBuffer);
    CVPixelBufferLockBaseAddress(pixelBuffer, kNilOptions);
    
    OSType sourcePixelFormat = CVPixelBufferGetPixelFormatType(pixelBuffer);
    const int bytes_per_row = (int)CVPixelBufferGetBytesPerRow(pixelBuffer);
    const int image_width = (int)CVPixelBufferGetWidth(pixelBuffer);
    const int image_height = (int)CVPixelBufferGetHeight(pixelBuffer);
    const int image_channels = 4; // by definition (ARGB, BGRA)
    
    assert(sourcePixelFormat == kCVPixelFormatType_32ARGB
        || sourcePixelFormat == kCVPixelFormatType_32BGRA);
    
    assert(image_width == shape.width);
    assert(image_height == shape.height);
    assert(image_channels >= shape.channels);
    
    const int tensor_channels = shape.channels;
    const int tensor_bytes_per_row = shape.width * tensor_channels;
    
    // channel_offset is used to skip the alpha channel when copying to the tensor
    // it is 1 for ARGB images and 0 for BGRA images.
    
    const int channel_offset = sourcePixelFormat == kCVPixelFormatType_32ARGB
        ? 1
        : 0;
    
    uint8_t* in = (uint8_t*)CVPixelBufferGetBaseAddress(pixelBuffer);
    tensor_t* out = tensor;
    
    for (int y = 0; y < image_height; y++) {
        for (int x = 0; x < image_width; x++) {
            auto* in_pixel = in + (y * bytes_per_row) + (x * image_channels);
            auto* out_pixel = out + (y * tensor_bytes_per_row) + (x * tensor_channels);

            for (int c = 0; c < tensor_channels; ++c) {
                out_pixel[c] = normalizer(in_pixel[c+channel_offset], c);
            }
        }
    }
    
    CVPixelBufferUnlockBaseAddress(pixelBuffer, kNilOptions);
    CFRelease(pixelBuffer);
}

/**
 * `CVPixelBufferCopyToTensor` copies a pixel buffer in ARGB or BGRA format to a tensor,
 * which is a pointer to an array of `float_t` or `uint8_t`.
 *
 * The pixel buffer must already be in the shape and format expected by the input tensor,
 * with the shape parameter describing its dimensions. The alpha channel will be ignored.
 *
 * If a normalizer is provided then the pixel buffer's values will be scaled using the
 * normalizer.
 *
 * `tensor_t` will be `float_t` (32 bits) for an unquantized model or `uint8_t` (8 bits)
 * for a quantized model.
 *
 * @param pixelBuffer The pixel buffer that will be copied to the tensor.
 * @param tensor The tensor that will receive the pixel buffer values.
 * @param shape The shape, i.e. width, height, and number of channels of the tensor.
 */

template <typename tensor_t>
void CVPixelBufferCopyToTensor(CVPixelBufferRef pixelBuffer, tensor_t* _Nonnull tensor, ImageVolume shape) {
    assert(pixelBuffer != NULL);
    assert(tensor != NULL);
    
    CFRetain(pixelBuffer);
    CVPixelBufferLockBaseAddress(pixelBuffer, kNilOptions);
    
    OSType sourcePixelFormat = CVPixelBufferGetPixelFormatType(pixelBuffer);
    const int bytes_per_row = (int)CVPixelBufferGetBytesPerRow(pixelBuffer);
    const int image_width = (int)CVPixelBufferGetWidth(pixelBuffer);
    const int image_height = (int)CVPixelBufferGetHeight(pixelBuffer);
    const int image_channels = 4; // by definition (ARGB, BGRA)
    
    assert(sourcePixelFormat == kCVPixelFormatType_32ARGB
        || sourcePixelFormat == kCVPixelFormatType_32BGRA);
    
    assert(image_width == shape.width);
    assert(image_height == shape.height);
    assert(image_channels >= shape.channels);
    
    const int tensor_channels = shape.channels;
    const int tensor_bytes_per_row = shape.width * tensor_channels;
    
    // channel_offset is used to skip the alpha channel when copying to the tensor
    // it is 1 for ARGB images and 0 for BGRA images.
    
    const int channel_offset = sourcePixelFormat == kCVPixelFormatType_32ARGB
        ? 1
        : 0;
    
    uint8_t* in = (uint8_t*)CVPixelBufferGetBaseAddress(pixelBuffer);
    tensor_t* out = tensor;
    
    for (int y = 0; y < image_height; y++) {
        for (int x = 0; x < image_width; x++) {
            auto* in_pixel = in + (y * bytes_per_row) + (x * image_channels);
            auto* out_pixel = out + (y * tensor_bytes_per_row) + (x * tensor_channels);

            for (int c = 0; c < tensor_channels; ++c) {
                out_pixel[c] = in_pixel[c+channel_offset];
            }
        }
    }
    
    CVPixelBufferUnlockBaseAddress(pixelBuffer, kNilOptions);
    CFRelease(pixelBuffer);
}

// MARK: - Utilities

/**
 * Checks if two image volumes are equal.
 *
 * @param a The first image volume to compare.
 * @param b The second image volume to compare.
 *
 * @return BOOL `YES` if two image volumes are equal, `NO` otherwise.
 */

BOOL ImageVolumesEqual(const ImageVolume& a, const ImageVolume& b);

/**
 * Checks if two PixelNormalization structs are equal
 * @param a The first pixel normalization to compare.
 * @param b The second pixel normalization to compare,
 *
 * @return BOOL 'YES' if the two structs are equal, 'NO' otherwise.
 */

BOOL PixelNormalizationsEqual(const PixelNormalization& a, const PixelNormalization& b);

NS_ASSUME_NONNULL_END

#endif /* VisionModelHelpers_h */
