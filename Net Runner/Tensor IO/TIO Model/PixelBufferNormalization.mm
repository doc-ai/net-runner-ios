//
//  PixelBufferNormalization.m
//  Net Runner
//
//  Created by Philip Dow on 8/19/18.
//  Copyright © 2018 doc.ai. All rights reserved.
//

#import "PixelBufferNormalization.h"

// Standard Pixel Normalizers

const PixelNormalization kPixelNormalizationInvalid = {
    .scale      = FLT_MAX,
    .redBias    = FLT_MAX,
    .greenBias  = FLT_MAX,
    .blueBias   = FLT_MAX
};

const PixelNormalization kPixelNormalizationNone = {
    .scale      = 1,
    .redBias    = 0,
    .greenBias  = 0,
    .blueBias   = 0
};

const PixelNormalization kPixelNormalizationZeroToOne = {
    .scale      = 1.0/255.0,
    .redBias    = 0,
    .greenBias  = 0,
    .blueBias   = 0
};

const PixelNormalization kPixelNormalizationNegativeOneToOne = {
    .scale      = 2.0/255.0,
    .redBias    = -1,
    .greenBias  = -1,
    .blueBias   = -1
};

// Standard Pixel Denormalizers

const PixelDenormalization kPixelDenormalizationInvalid = {
    .scale      = FLT_MAX,
    .redBias    = FLT_MAX,
    .greenBias  = FLT_MAX,
    .blueBias   = FLT_MAX
};

const PixelDenormalization kPixelDenormalizationNone = {
    .scale      = 1,
    .redBias    = 0,
    .greenBias  = 0,
    .blueBias   = 0
};

const PixelDenormalization kPixelDenormalizationZeroToOne = {
    .scale      = 255.0,
    .redBias    = 0,
    .greenBias  = 0,
    .blueBias   = 0
};

const PixelDenormalization kPixelDenormalizationNegativeOneToOne = {
    .scale      = 255.0/2.0,
    .redBias    = 1,
    .greenBias  = 1,
    .blueBias   = 1
};

// MARK: - Core Pixel Normalizers

PixelNormalizer _Nullable PixelNormalizerNone() {
    return nil;
}

PixelNormalizer PixelNormalizerSingleBias(const PixelNormalization& normalization) {
    const float scale = normalization.scale;
    const float bias = normalization.redBias;
    
    return ^float_t (const uint8_t &value, const uint8_t &channel) {
        return ((float_t)value * scale) + bias;
    };
}

PixelNormalizer PixelNormalizerPerChannelBias(const PixelNormalization& normalization) {
    const float scale = normalization.scale;
    const float redBias = normalization.redBias;
    const float greenBias = normalization.greenBias;
    const float blueBias = normalization.blueBias;
    
    return ^float_t (const uint8_t &value, const uint8_t &channel) {
        switch (channel) {
        case 0:
            return ((float_t)value * scale) + redBias;
        case 1:
            return ((float_t)value * scale) + greenBias;
        case 2:
            return ((float_t)value * scale) + blueBias;
        default:
            NSLog(@"Unexpected channel in scaling block: %hhu", channel);
            assert(false);
        }
    };
}

// MARK: - Helpers for Constructing Standard Pixel Normalizers

PixelNormalizer PixelNormalizerZeroToOne() {
    const float scale = 1.0/255.0;
    
    return ^float_t (const uint8_t &value, const uint8_t &channel) {
        return ((float_t)value * scale);
    };
}

PixelNormalizer PixelNormalizerNegativeOneToOne() {
    const float scale = 2.0/255.0;
    const float bias = -1;
    
    return ^float_t (const uint8_t &value, const uint8_t &channel) {
        return ((float_t)value * scale) + bias;
    };
}

// MARK: - Core Pixel Denormalizers

PixelDenormalizer _Nullable PixelDenormalizerNone() {
    return nil;
}

PixelDenormalizer PixelDenormalizerSingleBias(const PixelNormalization& normalization) {
    const float scale = normalization.scale;
    const float bias = normalization.redBias;
    
    return ^uint8_t (const float_t &value, const uint8_t &channel) {
        return (uint8_t)((value + bias) * scale);
    };
}

PixelDenormalizer PixelDenormalizerPerChannelBias(const PixelNormalization& normalization) {
    const float scale = normalization.scale;
    const float redBias = normalization.redBias;
    const float greenBias = normalization.greenBias;
    const float blueBias = normalization.blueBias;
    
    return ^uint8_t (const float_t &value, const uint8_t &channel) {
        switch (channel) {
        case 0:
            return (uint8_t)((value + redBias) * scale);
        case 1:
            return (uint8_t)((value + greenBias) * scale);
        case 2:
            return (uint8_t)((value + blueBias) * scale);
        default:
            NSLog(@"Unexpected channel in scaling block: %hhu", channel);
            assert(false);
        }
    };
}

// MARK: - Helpers for Constructing Standard Pixel Denormalizers

PixelDenormalizer PixelDenormalizerZeroToOne() {
    const float scale = 255.0;
    
    return ^uint8_t (const float_t &value, const uint8_t &channel) {
        return (uint8_t)(value * scale);
    };
}

PixelDenormalizer PixelDenormalizerNegativeOneToOne() {
    const float scale = 255.0/2.0;
    const float bias = 1;
    
    return ^uint8_t (const float_t &value, const uint8_t &channel) {
        return (uint8_t)((value + bias) * scale);
    };
}

// MARK: - Utilities

BOOL PixelNormalizationsEqual(const PixelNormalization& a, const PixelNormalization& b) {
    return a.scale == b.scale
        && a.redBias == b.redBias
        && a.greenBias == b.greenBias
        && a.blueBias == b.blueBias;
}

BOOL PixelDenormalizationsEqual(const PixelDenormalization& a, const PixelDenormalization& b) {
    return a.scale == b.scale
        && a.redBias == b.redBias
        && a.greenBias == b.greenBias
        && a.blueBias == b.blueBias;
}
