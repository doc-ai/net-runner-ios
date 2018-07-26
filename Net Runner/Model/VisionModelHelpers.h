//
//  VisionModelHelpers.h
//  tflite_camera_example
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

extern const PixelNormalization kNoNormalization;
extern const ImageVolume kNoImageVolume;
extern const OSType OSTypeNone;

// Core Pixel Normalizers

PixelNormalizer PixelNormalizerNone();
PixelNormalizer PixelNormalizerSingleBias(PixelNormalization normalization);
PixelNormalizer PixelNormalizerPerChannelBias(PixelNormalization normalization);

// Helpers for Constructing Standard Pixel Normalizers

PixelNormalizer PixelNormalizerZeroToOne();
PixelNormalizer PixelNormalizerNegativeOneToOne();

// Initialization

ImageVolume ImageVolumeForShape(NSArray<NSNumber*> *shape);
OSType PixelFormatForString(NSString* formatString);

PixelNormalization PixelNormalizationForInput(NSDictionary *input);
PixelNormalizer PixelNormalizerForInput(NSDictionary *input);

// Utilities

BOOL ImageVolumesEqual(ImageVolume a, ImageVolume b);

NS_ASSUME_NONNULL_END

#endif /* VisionModelHelpers_h */
