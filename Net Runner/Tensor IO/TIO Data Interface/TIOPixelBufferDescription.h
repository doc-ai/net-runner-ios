//
//  TIOPixelBufferDescription.h
//  Net Runner Parser
//
//  Created by Philip Dow on 8/5/18.
//  Copyright © 2018 doc.ai. All rights reserved.
//
//  TODO: Perhaps TIOPixelBufferDescription is TIOPixelBufferLayerDescription

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

#import "TIODataDescription.h"
#import "VisionModelHelpers.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * The description of a pixel buffer input or output layer.
 */

@interface TIOPixelBufferDescription : NSObject <TIODataDescription>

@property (readonly, getter=isQuantized) BOOL quantized;
@property (readonly) OSType pixelFormat;
@property (readonly) ImageVolume shape;
@property (readonly) PixelNormalization normalization;
@property (nullable, readonly) PixelNormalizer normalizer;
@property (readonly) PixelDenormalization denormalization;
@property (nullable, readonly) PixelDenormalizer denormalizer;

// TODO: Do something about duplicate PixelNormalization and PixelNormalizer types. Do I really need both?
// And now I've got a quantizer and dequantizer, which do something similar

- (instancetype)initWithPixelFormat:(OSType)pixelFormat shape:(ImageVolume)shape normalization:(PixelNormalization)normalization normalizer:(PixelNormalizer)normalizer denormalization:(PixelDenormalization)denormalization denormalizer:(PixelDenormalizer)denormalizer quantized:(BOOL)quantized NS_DESIGNATED_INITIALIZER;

/**
 * Use the designated initializer.
 */

- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
