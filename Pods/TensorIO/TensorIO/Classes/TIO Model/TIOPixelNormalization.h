//
//  TIOPixelNormalization.h
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

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * Describes how pixel values in the range of `[0,255]` will be normalized for
 * non-quantized, float32 models.
 *
 * Pixels will typically normalized to values in the range `[0,1]` or `[-1,+1]`,
 * although separate biases may be applied to each of the RGB channels.
 *
 * Pixel normalization is like quantization but in the opposite direction.
 */

typedef struct TIOPixelNormalization {
    float scale;
    float redBias;
    float greenBias;
    float blueBias;
} TIOPixelNormalization;

/**
 * Describes a denormalization, or how pixel values in some arbitrary range will be
 * denormalized back to pixe values in the range of `[0,255]`
 *
 * Pixels will typically be denormalized from values in the range `[0,1]` or `[-1,+1]`,
 * although separate denormaliation biases may be required for each of the RGB channels.
 *
 * Normalization and denormalization apply the same operations with scaling and bias values,
 * but they are typically inverses of one another.
 */

typedef TIOPixelNormalization TIOPixelDenormalization;

/**
 * A `TIOPixelNormalizer` is a function that transforms a pixel value in the range `[0,255]`
 * to some other range, where the transformation may be channel dependent.
 *
 * The normalizer will typically be constructed with the help of a `TIOPixelNormalization`
 * struct or using one of the core or standard normalizers provided.
 *
 * @param value The single byte pixel value being transformed.
 * @param channel The RGB channel of the pixel value being transformed.
 *
 * @return float_t The transformed value.
 */

typedef float_t (^TIOPixelNormalizer)(const uint8_t &value, const uint8_t &channel);

/**
 * A `TIOPixelDenormalizer` is a function that transforms a normalized pixel value, typically in the
 * range `[0,1]` or `[-1,1]` back to a pixel value in the range `[0,255]`, where the denormalization
 * may be channel dependent.
 *
 * The denormalizer will typically be constructed with the help of a `TIOPixelDenormalization`
 * struct or using one of the core or standard denormalizers provided.
 *
 * @param value The four byte normalized pixel value being transformed.
 * @param channel The RGB channel of the pixel value being transformed.
 *
 * @return uint8_t The denormalized value.
 */

typedef uint8_t (^TIOPixelDenormalizer)(const float_t &value, const uint8_t &channel);

/**
 * An invalid pixel normalization, used when there is an error parsing the normalization settings.
 */

extern const TIOPixelNormalization kTIOPixelNormalizationInvalid;

/**
 * No pixel normalization, so a scale of 1 and no bias.
 */

extern const TIOPixelNormalization kTIOPixelNormalizationNone;

/**
 * Pixel normalization from 0 to 1.
 *
 * A scale of 1.0/255.0 and no bias.
 */

extern const TIOPixelNormalization kTIOPixelNormalizationZeroToOne;

/**
 * Pixel normalization from -1 to 1.
 *
 * A scale of 2.0/255.0 and a bias of -1 to each channel.
 */

extern const TIOPixelNormalization kTIOPixelNormalizationNegativeOneToOne;

/**
 * An invalid pixel denormalization, used when there is an error parsing the denormalization settings.
 */

extern const TIOPixelDenormalization kTIOPixelDenormalizationInvalid;

/**
 * No pixel denormalization, so a scale of 1 and no bias.
 */

extern const TIOPixelDenormalization kTIOPixelDenormalizationNone;

/**
 * Pixel denormalization from a range of values 0 to 1.
 *
 * A scale of 255.0 and no bias.
 */

extern const TIOPixelDenormalization kTIOPixelDenormalizationZeroToOne;

/**
 * Pixel denormalization from a range of values  -1 to 1.
 *
 * A scale of 255.0/2.0 and a bias of +1 to each channel.
 */

extern const TIOPixelDenormalization kTIOPixelDenormalizationNegativeOneToOne;

// MARK: - Core Pixel Normalizers

/**
 * A normalizing function that applies no normalization to the pixel values, `nil`.
 */

TIOPixelNormalizer _Nullable TIOPixelNormalizerNone();

/**
 * A normalizing function that applies a scaling factor and equal bias to each pixel channel.
 */

TIOPixelNormalizer TIOPixelNormalizerSingleBias(const TIOPixelNormalization& normalization);

/**
 * A normalizing function that applies a scaling factor and different biases to each pixel channel.
 */

TIOPixelNormalizer TIOPixelNormalizerPerChannelBias(const TIOPixelNormalization& normalization);

// MARK: - Helpers for Constructing Standard Pixel Normalizers

/**
 * Normalizes pixel values from a range of `[0,255]` to `[0,1]`.
 *
 * This is equivalent to applying a scaling factor of `1.0/255.0` and no channel bias.
 */

TIOPixelNormalizer TIOPixelNormalizerZeroToOne();

/**
 * Normalizes pixel values from a range of `[0,255]` to `[-1,1]`.
 *
 * This is equivalent to applying a scaling factor of `2.0/255.0` and a bias of `-1` to each channel.
 */

TIOPixelNormalizer TIOPixelNormalizerNegativeOneToOne();

// MARK: - Core Pixel Denormalizers

/**
 * A denormalizing function that applies no denormalization to the pixel values, `nil`.
 */

TIOPixelDenormalizer _Nullable TIOPixelDenormalizerNone();

/**
 * A denormalizing function that applies a scaling factor and equal bias to each pixel channel.
 */

TIOPixelDenormalizer TIOPixelDenormalizerSingleBias(const TIOPixelNormalization& normalization);

/**
 * A denormalizing function that applies a scaling factor and different biases to each pixel channel.
 */

TIOPixelDenormalizer TIOPixelDenormalizerPerChannelBias(const TIOPixelNormalization& normalization);

// MARK: - Helpers for Constructing Standard Pixel Denormalizers

/**
 * Denormalizes pixel values from a range of `[0,1]` to `[0,255]`.
 *
 * This is equivalent to applying no channel bias a scaling factor of `255.0`.
 */

TIOPixelDenormalizer TIOPixelDenormalizerZeroToOne();

/**
 * Denormalizes pixel values from a range of `[-1,1]` to `[0,255]`.
 *
 * This is equivalent to applying a bias of `1` to each channel and a scaling factor of `255.0/2.0`.
 */

TIOPixelDenormalizer TIOPixelDenormalizerNegativeOneToOne();

// MARK: - Utilities

/**
 * Checks if two TIOPixelNormalization structs are equal.
 *
 * @param a The first pixel normalization to compare.
 * @param b The second pixel normalization to compare.
 *
 * @return BOOL `YES` if the two structs are equal, `NO` otherwise.
 */

BOOL TIOPixelNormalizationsEqual(const TIOPixelNormalization& a, const TIOPixelNormalization& b);

/**
 * Checks if two TIOPixelDenormalization structs are equal.
 *
 * @param a The first pixel denormalization to compare.
 * @param b The second pixel denormalization to compare.
 *
 * @return BOOL `YES` if the two structs are equal, `NO` otherwise.
 */

BOOL TIOPixelDenormalizationsEqual(const TIOPixelDenormalization& a, const TIOPixelDenormalization& b);

NS_ASSUME_NONNULL_END
