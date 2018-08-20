//
//  TIOPixelBufferDescription.h
//  TensorIO
//
//  Created by Philip Dow on 8/5/18.
//  Copyright © 2018 doc.ai. All rights reserved.
//
//  TODO: Perhaps TIOPixelBufferDescription is TIOPixelBufferLayerDescription

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

#import "TIODataDescription.h"
#import "TIOVisionModelHelpers.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * The description of a pixel buffer input or output layer.
 */

@interface TIOPixelBufferDescription : NSObject <TIODataDescription>

@property (readonly, getter=isQuantized) BOOL quantized;
@property (readonly) OSType pixelFormat;
@property (readonly) TIOImageVolume shape;
@property (readonly) TIOPixelNormalization normalization;
@property (nullable, readonly) TIOPixelNormalizer normalizer;
@property (readonly) TIOPixelDenormalization denormalization;
@property (nullable, readonly) TIOPixelDenormalizer denormalizer;

// TODO: Do something about duplicate TIOPixelNormalization and TIOPixelNormalizer types. Do I really need both?
// And now I've got a quantizer and dequantizer, which do something similar

- (instancetype)initWithPixelFormat:(OSType)pixelFormat shape:(TIOImageVolume)shape normalization:(TIOPixelNormalization)normalization normalizer:(TIOPixelNormalizer)normalizer denormalization:(TIOPixelDenormalization)denormalization denormalizer:(TIOPixelDenormalizer)denormalizer quantized:(BOOL)quantized NS_DESIGNATED_INITIALIZER;

/**
 * Use the designated initializer.
 */

- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
