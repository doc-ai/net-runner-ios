//
//  TIOPixelBufferDescription.m
//  Net Runner Parser
//
//  Created by Philip Dow on 8/5/18.
//  Copyright © 2018 doc.ai. All rights reserved.
//

#import "TIOPixelBufferDescription.h"

@implementation TIOPixelBufferDescription

- (instancetype)initWithPixelFormat:(OSType)pixelFormat shape:(ImageVolume)shape normalization:(PixelNormalization)normalization normalizer:(PixelNormalizer)normalizer denormalization:(PixelDenormalization)denormalization denormalizer:(PixelDenormalizer)denormalizer quantized:(BOOL)quantized {
    if (self=[super init]) {
        _pixelFormat = pixelFormat;
        _shape = shape;
        _normalization = normalization;
        _normalizer = normalizer;
        _denormalization = denormalization;
        _denormalizer = denormalizer;
        _quantized = quantized;
    }
    return self;
}

@end
