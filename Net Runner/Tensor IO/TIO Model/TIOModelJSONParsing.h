//
//  TIOModelJSONParsing.h
//  TensorIO
//
//  Created by Philip Dow on 8/20/18.
//  Copyright © 2018 doc.ai. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "TIOData.h"
#import "TIODataInterface.h"
#import "TIOQuantization.h"
#import "TIOVisionModelHelpers.h"

@class TIOModelBundle;
@class TIODataInterface;

NS_ASSUME_NONNULL_BEGIN

/**
 * Parses the JSON description of a vector input or output.
 *
 * Handles a vector, matrix, or other multidimensional array (tensor), described as a
 * one dimensional unrolled vector with an optional labels entry.
 *
 * @param dict The JSON description in `NSDictionary` format
 * @param isInput `YES` if this is an input layer, `NO` if it is an output layer
 * @param quantized `YES` if the layer expects or returns quantized bytes, `NO` otherwise
 * @param bundle `The ModelBundel` that is being parsed, needed to derive a path to the labels file
 *
 * @return TIODataInterface An interface that describes this pixel buffer input or output
 */

TIODataInterface * _Nullable TIOTFLiteModelParseTIOVectorDescription(NSDictionary *dict, BOOL isInput, BOOL quantized, TIOModelBundle *bundle);

/**
 * Parses the JSON description of a pixel buffer input or output.
 *
 * Pixel buffers are handled as their own case instead of as a three-dimensional volume because
 * of byte alignment and pixel format conversion requirements.
 *
 * @param dict The JSON description in `NSDictionary` format
 * @param isInput `YES` if this is an input layer, `NO` if it is an output layer
 * @param quantized `YES` if the layer expects or returns quantized bytes, `NO` otherwise
 *
 * @return TIODataInterface An interface that describes this pixel buffer input or output
 */

TIODataInterface * _Nullable TIOTFLiteModelParseTIOPixelBufferDescription(NSDictionary *dict, BOOL isInput, BOOL quantized);

/**
 * Parses the `quantization` key of an input description and returns an associated data quantizer
 */

_Nullable TIODataQuantizer TIODataQuantizerForDict(NSDictionary *dict);

/**
 * Parses the `dequantization` key of an output description and returns an associated data quantizer
 */

_Nullable TIODataDequantizer TIODataDequantizerForDict(NSDictionary *dict);

/**
 * Converts an array of shape values to an `TIOImageVolume`.
 */

TIOImageVolume TIOImageVolumeForShape(NSArray<NSNumber*> *shape);

/**
 * Converts a pixel format string such as `"RGB"` or `"BGR"` to a Core Video pixel format type.
 */

OSType PixelFormatForString(NSString* formatString);

/**
 * Returns the TIOPixelNormalization given an input dictionary.
 */

TIOPixelNormalization TIOPixelNormalizationForDictionary(NSDictionary *input);

/**
 * Returns the TIOPixelNormalizer given an input dictionary.
 */

TIOPixelNormalizer _Nullable TIOPixelNormalizerForDictionary(NSDictionary *input);

/**
 * Returns the denormalizing TIOPixelNormalization given an input dictionary
 */

TIOPixelDenormalization TIOPixelDenormalizationForDictionary(NSDictionary *input);

/**
 * Returns the denormalizer for a given input dictionary
 */

TIOPixelDenormalizer _Nullable TIOPixelDenormalizerForDictionary(NSDictionary *input);

// MARK: - Pixel Format

/**
 * No pixel format, used to represent an error reading the pixel format from the model.json file.
 */

extern const OSType TIOPixelFormatTypeInvalid;

NS_ASSUME_NONNULL_END
