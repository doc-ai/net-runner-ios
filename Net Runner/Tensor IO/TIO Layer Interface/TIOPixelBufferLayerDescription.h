//
//  TIOPixelBufferLayerDescription.h
//  TensorIO
//
//  Created by Philip Dow on 8/5/18.
//  Copyright © 2018 doc.ai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

#import "TIOLayerDescription.h"
#import "TIOVisionModelHelpers.h"

// TODO: Do something about duplicate TIOPixelNormalization and TIOPixelNormalizer types. Do I really need both?
// And now I've got a quantizer and dequantizer, which do something similar

NS_ASSUME_NONNULL_BEGIN

/**
 * The description of a pixel buffer input or output layer.
 */

@interface TIOPixelBufferLayerDescription : NSObject <TIOLayerDescription>

/**
 * `YES` is the layer is quantized, `NO` otherwise
 */

@property (readonly, getter=isQuantized) BOOL quantized;

/**
 * The pixel format of the image data, must be kCVPixelFormatType_32BGRA or kCVPixelFormatType_32BGRA
 */

@property (readonly) OSType pixelFormat;

/**
 * The shape of the pixel data, including width, height, and channels
 */

@property (readonly) TIOImageVolume shape;

/**
 * A function that normalizes pixel values from a uint8_t range of `[0,255]` to some other
 * floating point range, may be `nil`.
 */

@property (nullable, readonly) TIOPixelNormalizer normalizer;

/**
 * A function that denormalizes pixel values from a floating point range back to uint8_t values
 * in the range `[0,255]`, may be nil.
 */

@property (nullable, readonly) TIOPixelDenormalizer denormalizer ;

/**
 * Designated initializer. Creates a pixel buffer description from the properties parsed in a
 * model.json file.
 *
 * @param pixelFormat The expected format of the pixels
 * @param normalization A description of how the pixels will be normalized for an input layer
 * @param normalizer A function which normalizes the pixel values for an input layer, may be `nil`.
 * @param denormalization A description of how the pixels will be denormalized for an output layer
 * @param denormalizer A function which denormalizes pixel values for an output layer, may be `nil`
 * @param quantized `YES` if this layer expectes quantized values, `NO` otherwise
 *
 * @return instancetype A read-only instance of `TIOPixelBufferLayerDescription`
 */

- (instancetype)initWithPixelFormat:(OSType)pixelFormat shape:(TIOImageVolume)shape normalizer:(nullable TIOPixelNormalizer)normalizer denormalizer:(nullable TIOPixelDenormalizer)denormalizer quantized:(BOOL)quantized NS_DESIGNATED_INITIALIZER;

/**
 * Use the designated initializer.
 */

- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
