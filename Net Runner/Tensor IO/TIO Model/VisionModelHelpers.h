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

// TODO: move pixel normalization to its own files

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
 * Pixels will typically normalized to values in the range `[0,1]` or `[-1,+1]`,
 * although separate biases may be applied to each of the RGB channels.
 */

typedef struct PixelNormalization {
    float scale;
    float redBias;
    float greenBias;
    float blueBias;
} PixelNormalization;

/**
 * Describes a denormalization, or how pixel values in some arbitrary range will be
 * denormalized back to pixe values in the range of `[0,255]`
 *
 * Pixels will typically be denormalized from values in the range `[0,1]` or `[-1,+1]`,
 * although separate denormaliation biases may be required for each of the RGB channels.
 */

typedef PixelNormalization PixelDenormalization;

/**
 * A `PixelNormalizer` is a function that transforms a pixel value in the range `[0,255]`
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
 * A `PixelDenormalizer` is a function that transforms a normalized pixel value, typically in the
 * range `[0,1]` or `[-1,1]` back to a pixel value in the range `[0,255]`, where the denormalization
 * may be channel dependent.
 *
 * The denormalizer will typically be constructed with the help of a `PixelDenormalization`
 * struct or using one of the core or standard denormalizers provided.
 *
 * @param value The four byte normalized pixel value being transformed
 * @param channel The RGB channel of the pixel value being transformed
 *
 * @return uint8_t The denormalized value
 */

typedef uint8_t (^PixelDenormalizer)(const float_t &value, const uint8_t &channel);

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
 * A scale of 1.0/255.0 and no bias
 */

extern const PixelNormalization kPixelNormalizationZeroToOne;

/**
 * Pixel normalization from -1 to 1.
 *
 * A scale of 2.0/255.0 and a bias of -1 to each channel.
 */

extern const PixelNormalization kPixelNormalizationNegativeOneToOne;

/**
 * An invalid pixel denormalization, used when there is an error parsing the denormalization settings.
 */

extern const PixelDenormalization kPixelDenormalizationInvalid;

/**
 * No pixel denormalization, so a scale of 1 and no bias.
 */

extern const PixelDenormalization kPixelDenormalizationNone;

/**
 * Pixel denormalization from a range of values 0 to 1.
 *
 * A scale of 255.0 and no bias
 */

extern const PixelDenormalization kPixelDenormalizationZeroToOne;

/**
 * Pixel denormalization from a range of values  -1 to 1.
 *
 * A scale of 255.0/2.0 and a bias of +1 to each channel.
 */

extern const PixelDenormalization kPixelDenormalizationNegativeOneToOne;

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
 * A normalizing function that applies no normalization to the pixel values, `nil`.
 */

PixelNormalizer _Nullable PixelNormalizerNone();

/**
 * A normalizing function that applies a scaling factor and equal bias to each pixel channel.
 */

PixelNormalizer PixelNormalizerSingleBias(const PixelNormalization& normalization);

/**
 * A normalizing function that applies a scaling factor and different biases to each pixel channel.
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

// MARK: - Core Pixel Denormalizers

/**
 * A denormalizing function that applies no denormalization to the pixel values, `nil`.
 */

PixelDenormalizer _Nullable PixelDenormalizerNone();

/**
 * A denormalizing function that applies a scaling factor and equal bias to each pixel channel.
 */

PixelDenormalizer PixelDenormalizerSingleBias(const PixelNormalization& normalization);

/**
 * A denormalizing function that applies a scaling factor and different biases to each pixel channel.
 */

PixelDenormalizer PixelDenormalizerPerChannelBias(const PixelNormalization& normalization);

// MARK: - Helpers for Constructing Standard Pixel Denormalizers

/**
 * Denormalizes pixel values from a range of `[0,1]` to `[0,255]`.
 *
 * This is equivalent to applying no channel bias a scaling factor of `255.0`.
 */

PixelDenormalizer PixelDenormalizerZeroToOne();

/**
 * Normalizes pixel values from a range of `[-1,1]` to `[0,255]`.
 *
 * This is equivalent to applying a bias of `1` to each channel and a scaling factor of `255.0/2.0`.
 */

PixelDenormalizer PixelDenormalizerNegativeOneToOne();

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

PixelNormalization PixelNormalizationForDictionary(NSDictionary *input);

/**
 * Returns the PixelNormalizer given an input dictionary.
 */

PixelNormalizer _Nullable PixelNormalizerForDictionary(NSDictionary *input);

/**
 * Returns the denormalizing PixelNormalization given an input dictionary
 */

PixelDenormalization PixelDenormalizationForDictionary(NSDictionary *input);

/**
 * Returns the denormalizer for a given input dictionary
 */

PixelDenormalizer _Nullable PixelDenormalizerForDictionary(NSDictionary *input);

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
    
    if ( normalizer == nil ) {
        
        for (int y = 0; y < image_height; y++) {
            for (int x = 0; x < image_width; x++) {
                auto* in_pixel = in + (y * bytes_per_row) + (x * image_channels);
                auto* out_pixel = out + (y * tensor_bytes_per_row) + (x * tensor_channels);

                for (int c = 0; c < tensor_channels; ++c) {
                    out_pixel[c] = in_pixel[c+channel_offset];
                }
            }
        }
        
    } else {
    
        for (int y = 0; y < image_height; y++) {
            for (int x = 0; x < image_width; x++) {
                auto* in_pixel = in + (y * bytes_per_row) + (x * image_channels);
                auto* out_pixel = out + (y * tensor_bytes_per_row) + (x * tensor_channels);

                for (int c = 0; c < tensor_channels; ++c) {
                    out_pixel[c] = normalizer(in_pixel[c+channel_offset], c);
                }
            }
        }
        
    }
    
    CVPixelBufferUnlockBaseAddress(pixelBuffer, kNilOptions);
    CFRelease(pixelBuffer);
}

// TODO: ensure 16 byte pixel buffer alignment

/**
 * Copies tensor bytes directly into  a pixel buffer from a tensor, applying a denormalization
 * function and adjusting for the pixel format.
 *
 * The resulting pixel buffer will (eventually) be 16 byte aligned. The caller must release the
 * pixelBuffer with `CVPixelBufferRelease`.
 *
 * @param pixelBuffer A pointer to the pixel buffer that will be filled with the transformed tensor data
 * @param tensor A pointer to the tensor that contains the image data
 * @param shape The width, height, and number of channels of the tensor. Number of channels should be three.
 * @param pixelFormat The format of the tensor image data, must be kCVPixelFormatType_32ARGB or kCVPixelFormatType_32BGRA.
 * Note that the alpha channel is ignored.
 * @param denormalizer A function that can convert the tensor image data to pixel values, may be `nil`.
 *
 * @return CVReturn `kCVReturnSuccess` if the operation was successful, some other value if not
 */

template <typename tensor_t>
CVReturn CVPixelBufferCreateFromTensor(_Nonnull CVPixelBufferRef * _Nonnull pixelBuffer, tensor_t * _Nonnull tensor, ImageVolume shape, OSType pixelFormat, _Nullable PixelDenormalizer denormalizer) {
    
    assert( pixelFormat == kCVPixelFormatType_32ARGB || pixelFormat == kCVPixelFormatType_32BGRA );
    assert( shape.width % 16 == 0);
    
    const int tensor_channels = shape.channels;
    const int tensor_bytes_per_row = shape.width * tensor_channels;
    
    const int image_width = shape.width;
    const int image_height = shape.height;
    const int bytes_per_row = shape.width * 4;
    const int image_channels = 4; // by definition (ARGB, BGRA)
    
    CVPixelBufferRef outputBuffer = NULL;
    
    CVReturn status = CVPixelBufferCreate(
        kCFAllocatorDefault,
        image_width,
        image_height,
        pixelFormat,
        NULL,
        &outputBuffer);
    
    // Error handling
    
    if ( status != kCVReturnSuccess ) {
        NSLog(@"Couldn't create pixel buffer");
        return status;
    }
    
    // Copy the pixel data
    
    // channel_offset is used to skip the alpha channel when copying to the tensor
    // it is 1 for ARGB images and 0 for BGRA images.
    
    CVPixelBufferLockBaseAddress(outputBuffer, kNilOptions);
    
    const int channel_offset = pixelFormat == kCVPixelFormatType_32ARGB
        ? 1
        : 0;
    
    const int alpha_channel = pixelFormat == kCVPixelFormatType_32ARGB
        ? 0
        : 3;
    
    tensor_t* in_addr = tensor;
    uint8_t* out_addr = (uint8_t*)CVPixelBufferGetBaseAddress(outputBuffer);
    
    if ( denormalizer == nil ) {
    
        for (int y = 0; y < image_height; y++) {
            for (int x = 0; x < image_width; x++) {
                auto* in_pixel = in_addr + (y * tensor_bytes_per_row) + (x * tensor_channels);
                auto* out_pixel = out_addr + (y * bytes_per_row) + (x * image_channels);
                
                for (int c = 0; c < tensor_channels; ++c) {
                    out_pixel[c+channel_offset] = in_pixel[c];
                }
                
                out_pixel[alpha_channel] = 255;
            }
        }
    } else {
    
        for (int y = 0; y < image_height; y++) {
            for (int x = 0; x < image_width; x++) {
                auto* in_pixel = in_addr + (y * tensor_bytes_per_row) + (x * tensor_channels);
                auto* out_pixel = out_addr + (y * bytes_per_row) + (x * image_channels);
                
                for (int c = 0; c < tensor_channels; ++c) {
                    out_pixel[c+channel_offset] = denormalizer(in_pixel[c], c);
                }
                
                out_pixel[alpha_channel] = 255;
            }
        }
    }
    
    // Clean up
    
    CVPixelBufferUnlockBaseAddress(outputBuffer, kNilOptions);
    *pixelBuffer = outputBuffer;
    
    return kCVReturnSuccess;
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

/**
 * Checks if two PixelDenormalization structs are equal
 * @param a The first pixel denormalization to compare.
 * @param b The second pixel denormalization to compare,
 *
 * @return BOOL 'YES' if the two structs are equal, 'NO' otherwise.
 */

BOOL PixelDenormalizationsEqual(const PixelDenormalization& a, const PixelDenormalization& b);

NS_ASSUME_NONNULL_END

#endif /* VisionModelHelpers_h */
