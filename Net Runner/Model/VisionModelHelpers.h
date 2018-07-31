//
//  VisionModelHelpers.h
//  Net Runner
//
//  Created by Philip Dow on 7/12/18.
//  Copyright © 2018 doc.ai. All rights reserved.
//

#ifndef VisionModelHelpers_h
#define VisionModelHelpers_h

#import "Model.h"
#import "VisionModel.h"
#import "CVPixelBufferHelpers.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * No pixel normalization, so a scale of 1 and no bias.
 */

extern const PixelNormalization kNoNormalization;

/**
 * No image volume, used to represent an error reading the image volume from the model.json file.
 */

extern const ImageVolume kNoImageVolume;

/**
 * No pixel format, used to represent an error reading the pixel format from the model.json file.
 */

extern const OSType PixelFormatTypeNone;

// MARK: - Core Pixel Normalizers

/**
 * A function that applies no normalization to the pixel values, `nil`.
 */

PixelNormalizer PixelNormalizerNone();

/**
 * A function that applies a scaling factor and equal bias to each pixel channel.
 */

PixelNormalizer PixelNormalizerSingleBias(const PixelNormalization& normalization);

/**
 * A function that applies a scaling factor and different biases to each pixel channel.
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

// MARK: - Initialization Helpers

/**
 * Converts an array of shape values to an `ImageVolume`.
 */

ImageVolume ImageVolumeForShape(NSArray<NSNumber*> *shape);

/**
 * Converts a pixel format string such as `"RGB"` or `"BGR"` to a Core Video pixel format type.
 */

OSType PixelFormatForString(NSString* formatString);

/**
 * Returns the PixelNormalization given an input dictionary.
 */

PixelNormalization PixelNormalizationForInput(NSDictionary *input);

/**
 * Returns the PixelNormalizer given an input dictionary.
 */

PixelNormalizer PixelNormalizerForInput(NSDictionary *input);

// MARK: - Utilities

/**
 * Returns `YES` if two image volumes are equal, `NO` otherwise.
 */

BOOL ImageVolumesEqual(const ImageVolume& a, const ImageVolume& b);

NS_ASSUME_NONNULL_END

#endif /* VisionModelHelpers_h */
