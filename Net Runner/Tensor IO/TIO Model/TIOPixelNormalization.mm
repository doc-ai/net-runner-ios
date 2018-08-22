//
//  TIOPixelNormalization.mm
//  TensorIO
//
//  Created by Philip Dow on 8/19/18.
//  Copyright © 2018 doc.ai (http://doc.ai)
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import "TIOPixelNormalization.h"

// Standard Pixel Normalizers

const TIOPixelNormalization kTIOPixelNormalizationInvalid = {
    .scale      = FLT_MAX,
    .redBias    = FLT_MAX,
    .greenBias  = FLT_MAX,
    .blueBias   = FLT_MAX
};

const TIOPixelNormalization kTIOPixelNormalizationNone = {
    .scale      = 1,
    .redBias    = 0,
    .greenBias  = 0,
    .blueBias   = 0
};

const TIOPixelNormalization kTIOPixelNormalizationZeroToOne = {
    .scale      = 1.0/255.0,
    .redBias    = 0,
    .greenBias  = 0,
    .blueBias   = 0
};

const TIOPixelNormalization kTIOPixelNormalizationNegativeOneToOne = {
    .scale      = 2.0/255.0,
    .redBias    = -1,
    .greenBias  = -1,
    .blueBias   = -1
};

// Standard Pixel Denormalizers

const TIOPixelDenormalization kTIOPixelDenormalizationInvalid = {
    .scale      = FLT_MAX,
    .redBias    = FLT_MAX,
    .greenBias  = FLT_MAX,
    .blueBias   = FLT_MAX
};

const TIOPixelDenormalization kTIOPixelDenormalizationNone = {
    .scale      = 1,
    .redBias    = 0,
    .greenBias  = 0,
    .blueBias   = 0
};

const TIOPixelDenormalization kTIOPixelDenormalizationZeroToOne = {
    .scale      = 255.0,
    .redBias    = 0,
    .greenBias  = 0,
    .blueBias   = 0
};

const TIOPixelDenormalization kTIOPixelDenormalizationNegativeOneToOne = {
    .scale      = 255.0/2.0,
    .redBias    = 1,
    .greenBias  = 1,
    .blueBias   = 1
};

// MARK: - Core Pixel Normalizers

TIOPixelNormalizer _Nullable TIOPixelNormalizerNone() {
    return nil;
}

TIOPixelNormalizer TIOPixelNormalizerSingleBias(const TIOPixelNormalization& normalization) {
    const float scale = normalization.scale;
    const float bias = normalization.redBias;
    
    return ^float_t (const uint8_t &value, const uint8_t &channel) {
        return ((float_t)value * scale) + bias;
    };
}

TIOPixelNormalizer TIOPixelNormalizerPerChannelBias(const TIOPixelNormalization& normalization) {
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

TIOPixelNormalizer TIOPixelNormalizerZeroToOne() {
    const float scale = 1.0/255.0;
    
    return ^float_t (const uint8_t &value, const uint8_t &channel) {
        return ((float_t)value * scale);
    };
}

TIOPixelNormalizer TIOPixelNormalizerNegativeOneToOne() {
    const float scale = 2.0/255.0;
    const float bias = -1;
    
    return ^float_t (const uint8_t &value, const uint8_t &channel) {
        return ((float_t)value * scale) + bias;
    };
}

// MARK: - Core Pixel Denormalizers

TIOPixelDenormalizer _Nullable TIOPixelDenormalizerNone() {
    return nil;
}

TIOPixelDenormalizer TIOPixelDenormalizerSingleBias(const TIOPixelNormalization& normalization) {
    const float scale = normalization.scale;
    const float bias = normalization.redBias;
    
    return ^uint8_t (const float_t &value, const uint8_t &channel) {
        return (uint8_t)((value + bias) * scale);
    };
}

TIOPixelDenormalizer TIOPixelDenormalizerPerChannelBias(const TIOPixelNormalization& normalization) {
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

TIOPixelDenormalizer TIOPixelDenormalizerZeroToOne() {
    const float scale = 255.0;
    
    return ^uint8_t (const float_t &value, const uint8_t &channel) {
        return (uint8_t)(value * scale);
    };
}

TIOPixelDenormalizer TIOPixelDenormalizerNegativeOneToOne() {
    const float scale = 255.0/2.0;
    const float bias = 1;
    
    return ^uint8_t (const float_t &value, const uint8_t &channel) {
        return (uint8_t)((value + bias) * scale);
    };
}

// MARK: - Utilities

BOOL TIOPixelNormalizationsEqual(const TIOPixelNormalization& a, const TIOPixelNormalization& b) {
    return a.scale == b.scale
        && a.redBias == b.redBias
        && a.greenBias == b.greenBias
        && a.blueBias == b.blueBias;
}

BOOL TIOPixelDenormalizationsEqual(const TIOPixelDenormalization& a, const TIOPixelDenormalization& b) {
    return a.scale == b.scale
        && a.redBias == b.redBias
        && a.greenBias == b.greenBias
        && a.blueBias == b.blueBias;
}
