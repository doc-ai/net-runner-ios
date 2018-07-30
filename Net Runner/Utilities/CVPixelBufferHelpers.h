//
//  CVPixelBufferHelpers.h
//  tflite_camera_example
//
//  Created by Philip Dow on 7/3/18.
//  Copyright © 2018 doc.ai. All rights reserved.
//

#ifndef CVPixelBuffer_Utilities_h
#define CVPixelBuffer_Utilities_h

#import <AVFoundation/AVFoundation.h>
#import <Accelerate/Accelerate.h>

#include <stdio.h>

typedef struct ImageVolume {
    int width;
    int height;
    int channels;
} ImageVolume;

typedef enum : NSUInteger  {
    Rotate0Degrees = 0,
    Rotate90Degrees = 1,
    Rotate180Degrees = 2,
    Rotate270Degrees = 3
} CVPixelBufferCounterclockwiseRotation;

typedef float_t (^PixelNormalizer)(const uint8_t &value, const uint8_t &channel);

// MARK: -

float_t ScaledPixel(const uint8_t &value, uint8_t channel);

/**
 * Returns a copy of the pixel buffer
 */

CVPixelBufferRef CVPixelBufferCopy(CVPixelBufferRef srcBuffer);

/**
 * Rotates the pixel buffer 90° clockwise. The pixel buffer must be square
 *
 * rotation value:
 *  0 -- rotate 0 degrees (simply copy the data from src to dest)
 *  1 -- rotate 90 degrees counterclockwise
 *  2 -- rotate 180 degress
 *  3 -- rotate 270 degrees counterclockwise
 *
 * Caller must release the returned pixel buffer with CVPixelBufferRelease
 */

CVPixelBufferRef CVPixelBufferRotate(CVPixelBufferRef pixelBuffer, CVPixelBufferCounterclockwiseRotation rotation);

/**
 * Converts a pixel buffer in ARGB format to one in BGRA format
 *
 * Caller must release the returned pixel buffer with `CVPixelBufferRelease`
 */

CVPixelBufferRef CVPixelBufferCreateBGRAFromARGB(CVPixelBufferRef pixelBuffer);

/**
 * Converts a pixel buffer in BGRA format to one in ARGB format
 *
 * Caller must release the returned pixel buffer with `CVPixelBufferRelease`
 */

CVPixelBufferRef CVPixelBufferCreateARGBFromBGRA(CVPixelBufferRef pixelBuffer);

/**
 * Copies the pixel buffer's three color channels into separate grayscale pixel buffers
 * The srcBuffer must be in the ARGB or BGRA pixel format, and the output channels will
 * depend on that format. The alpha channel is ignored.
 *
 * Caller must release the three new pixel buffers with `CVPixelBufferRelease`
 */

CVReturn CVPixelBufferCopySeparateChannels(CVPixelBufferRef pixelBuffer, CVPixelBufferRef* channel0Buffer, CVPixelBufferRef* channel1Buffer, CVPixelBufferRef* channel2Buffer, CVPixelBufferRef* channel3Buffer);

/**
 * Returns a new copy of buffer scaled and center cropped to size.
 *
 * Size must have equal width and height, and the target size must be smaller
 * than the source size.
 *
 * Caller must release the returned pixel buffer with `CVPixelBufferRelease`
 */

CVPixelBufferRef CVPixelBufferResizeToSquare(CVPixelBufferRef srcBuffer, CGSize size);

/**
 * The pixelBuffer must already be in the shape and format expected by the input tensor,
 * with the shape parameter describing its dimensions
 *
 * `tensor_t` will be `float_t` (32 bits) or `uint8_t` for a quantized model
 */

template <typename tensor_t>
void CVPixelBufferCopyToTensor(CVPixelBufferRef pixelBuffer, tensor_t* tensor, ImageVolume shape, PixelNormalizer normalizer) {
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

template <typename tensor_t>
void CVPixelBufferCopyToTensor(CVPixelBufferRef pixelBuffer, tensor_t* tensor, ImageVolume shape) {
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

#endif /* CVPixelBuffer_Utilities_h */
