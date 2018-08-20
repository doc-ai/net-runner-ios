//
//  TIOPixelBufferDescription.m
//  Net Runner Parser
//
//  Created by Philip Dow on 8/5/18.
//  Copyright © 2018 doc.ai. All rights reserved.
//

#import "TIOPixelBufferDescription.h"

@implementation TIOPixelBufferDescription

- (instancetype)initWithPixelFormat:(OSType)pixelFormat shape:(TIOImageVolume)shape normalization:(TIOPixelNormalization)normalization normalizer:(TIOPixelNormalizer)normalizer denormalization:(TIOPixelDenormalization)denormalization denormalizer:(TIOPixelDenormalizer)denormalizer quantized:(BOOL)quantized {
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
