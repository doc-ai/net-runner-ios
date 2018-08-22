//
//  TIOPixelBufferLayerDescription.m
//  TensorIO
//
//  Created by Philip Dow on 8/5/18.
//  Copyright © 2018 doc.ai. All rights reserved.
//

#import "TIOPixelBufferLayerDescription.h"

@implementation TIOPixelBufferLayerDescription

- (instancetype)initWithPixelFormat:(OSType)pixelFormat shape:(TIOImageVolume)shape normalizer:(nullable TIOPixelNormalizer)normalizer denormalizer:(nullable TIOPixelDenormalizer)denormalizer quantized:(BOOL)quantized {
    if (self=[super init]) {
        _pixelFormat = pixelFormat;
        _shape = shape;
        _normalizer = normalizer;
        _denormalizer = denormalizer;
        _quantized = quantized;
    }
    return self;
}

@end
