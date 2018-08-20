//
//  PixelBufferNormalization.h
//  Net Runner
//
//  Created by Philip Dow on 8/19/18.
//  Copyright © 2018 doc.ai. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * Describes how pixel values in the range of `[0,255]` will be normalized for
 * non-quantized, float32 models.
 *
 * Pixels will typically normalized to values in the range `[0,1]` or `[-1,+1]`,
 * although separate biases may be applied to each of the RGB channels.
 */

typedef struct PixelNormalization {
    float scale;
    float redBias;
    float greenBias;
    float blueBias;
} PixelNormalization;

/**
 * Describes a denormalization, or how pixel values in some arbitrary range will be
 * denormalized back to pixe values in the range of `[0,255]`
 *
 * Pixels will typically be denormalized from values in the range `[0,1]` or `[-1,+1]`,
 * although separate denormaliation biases may be required for each of the RGB channels.
 */

typedef PixelNormalization PixelDenormalization;

/**
 * A `PixelNormalizer` is a function that transforms a pixel value in the range `[0,255]`
 * to some other range, where the transformation may be channel dependent.
 *
 * The normalizer will typically be constructed with the help of a `PixelNormalization`
 * struct or using one of the core or standard normalizers provided.
 *
 * @param value The single byte pixel value being transformed
 * @param channel The RGB channel of the pixel value being transformed
 *
 * @return float_t The transformed value
 */

typedef float_t (^PixelNormalizer)(const uint8_t &value, const uint8_t &channel);

/**
 * A `PixelDenormalizer` is a function that transforms a normalized pixel value, typically in the
 * range `[0,1]` or `[-1,1]` back to a pixel value in the range `[0,255]`, where the denormalization
 * may be channel dependent.
 *
 * The denormalizer will typically be constructed with the help of a `PixelDenormalization`
 * struct or using one of the core or standard denormalizers provided.
 *
 * @param value The four byte normalized pixel value being transformed
 * @param channel The RGB channel of the pixel value being transformed
 *
 * @return uint8_t The denormalized value
 */

typedef uint8_t (^PixelDenormalizer)(const float_t &value, const uint8_t &channel);

/**
 * An invalid pixel normalization, used when there is an error parsing the normalization settings.
 */

extern const PixelNormalization kPixelNormalizationInvalid;

/**
 * No pixel normalization, so a scale of 1 and no bias.
 */

extern const PixelNormalization kPixelNormalizationNone;

/**
 * Pixel normalization from 0 to 1.
 *
 * A scale of 1.0/255.0 and no bias
 */

extern const PixelNormalization kPixelNormalizationZeroToOne;

/**
 * Pixel normalization from -1 to 1.
 *
 * A scale of 2.0/255.0 and a bias of -1 to each channel.
 */

extern const PixelNormalization kPixelNormalizationNegativeOneToOne;

/**
 * An invalid pixel denormalization, used when there is an error parsing the denormalization settings.
 */

extern const PixelDenormalization kPixelDenormalizationInvalid;

/**
 * No pixel denormalization, so a scale of 1 and no bias.
 */

extern const PixelDenormalization kPixelDenormalizationNone;

/**
 * Pixel denormalization from a range of values 0 to 1.
 *
 * A scale of 255.0 and no bias
 */

extern const PixelDenormalization kPixelDenormalizationZeroToOne;

/**
 * Pixel denormalization from a range of values  -1 to 1.
 *
 * A scale of 255.0/2.0 and a bias of +1 to each channel.
 */

extern const PixelDenormalization kPixelDenormalizationNegativeOneToOne;

// MARK: - Core Pixel Normalizers

/**
 * A normalizing function that applies no normalization to the pixel values, `nil`.
 */

PixelNormalizer _Nullable PixelNormalizerNone();

/**
 * A normalizing function that applies a scaling factor and equal bias to each pixel channel.
 */

PixelNormalizer PixelNormalizerSingleBias(const PixelNormalization& normalization);

/**
 * A normalizing function that applies a scaling factor and different biases to each pixel channel.
 */

PixelNormalizer PixelNormalizerPerChannelBias(const PixelNormalization& normalization);

// MARK: - Helpers for Constructing Standard Pixel Normalizers

/**
 * Normalizes pixel values from a range of `[0,255]` to `[0,1]`.
 *
 * This is equivalent to applying a scaling factor of `1.0/255.0` and no channel bias.
 */

PixelNormalizer PixelNormalizerZeroToOne();

/**
 * Normalizes pixel values from a range of `[0,255]` to `[-1,1]`.
 *
 * This is equivalent to applying a scaling factor of `2.0/255.0` and a bias of `-1` to each channel.
 */

PixelNormalizer PixelNormalizerNegativeOneToOne();

// MARK: - Core Pixel Denormalizers

/**
 * A denormalizing function that applies no denormalization to the pixel values, `nil`.
 */

PixelDenormalizer _Nullable PixelDenormalizerNone();

/**
 * A denormalizing function that applies a scaling factor and equal bias to each pixel channel.
 */

PixelDenormalizer PixelDenormalizerSingleBias(const PixelNormalization& normalization);

/**
 * A denormalizing function that applies a scaling factor and different biases to each pixel channel.
 */

PixelDenormalizer PixelDenormalizerPerChannelBias(const PixelNormalization& normalization);

// MARK: - Helpers for Constructing Standard Pixel Denormalizers

/**
 * Denormalizes pixel values from a range of `[0,1]` to `[0,255]`.
 *
 * This is equivalent to applying no channel bias a scaling factor of `255.0`.
 */

PixelDenormalizer PixelDenormalizerZeroToOne();

/**
 * Normalizes pixel values from a range of `[-1,1]` to `[0,255]`.
 *
 * This is equivalent to applying a bias of `1` to each channel and a scaling factor of `255.0/2.0`.
 */

PixelDenormalizer PixelDenormalizerNegativeOneToOne();

// MARK: - Utilities

/**
 * Checks if two PixelNormalization structs are equal
 * @param a The first pixel normalization to compare.
 * @param b The second pixel normalization to compare,
 *
 * @return BOOL 'YES' if the two structs are equal, 'NO' otherwise.
 */

BOOL PixelNormalizationsEqual(const PixelNormalization& a, const PixelNormalization& b);

/**
 * Checks if two PixelDenormalization structs are equal
 * @param a The first pixel denormalization to compare.
 * @param b The second pixel denormalization to compare,
 *
 * @return BOOL 'YES' if the two structs are equal, 'NO' otherwise.
 */

BOOL PixelDenormalizationsEqual(const PixelDenormalization& a, const PixelDenormalization& b);

NS_ASSUME_NONNULL_END
