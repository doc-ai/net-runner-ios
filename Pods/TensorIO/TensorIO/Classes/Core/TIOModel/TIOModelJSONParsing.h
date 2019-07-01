//
//  TIOModelJSONParsing.h
//  TensorIO
//
//  Created by Philip Dow on 8/20/18.
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

#import "TIOData.h"
#import "TIOLayerInterface.h"
#import "TIOQuantization.h"
#import "TIOVisionModelHelpers.h"
#import "TIODataTypes.h"

@class TIOModelBundle;
@class TIOLayerInterface;

NS_ASSUME_NONNULL_BEGIN

/**
 * Parses the JSON description of a vector input or output.
 *
 * Handles a vector, matrix, or other multidimensional array (tensor), described as a
 * one dimensional unrolled vector with an optional labels entry.
 *
 * @param dict The JSON description in `NSDictionary` format.
 * @param isInput `YES` if this is an input layer, `NO` if it is an output layer.
 * @param quantized `YES` if the layer expects or returns quantized bytes, `NO` otherwise.
 * @param bundle `The ModelBundel` that is being parsed, needed to derive a path to the labels file.
 *
 * @return TIOLayerInterface An interface that describes this pixel buffer input or output.
 */

TIOLayerInterface * _Nullable TIOModelParseTIOVectorDescription(NSDictionary *dict, BOOL isInput, BOOL quantized, TIOModelBundle *bundle);

/**
 * Parses the JSON description of a pixel buffer input or output.
 *
 * Pixel buffers are handled as their own case instead of as a three-dimensional volume because
 * of byte alignment and pixel format conversion requirements.
 *
 * @param dict The JSON description in `NSDictionary` format.
 * @param isInput `YES` if this is an input layer, `NO` if it is an output layer.
 * @param quantized `YES` if the layer expects or returns quantized bytes, `NO` otherwise.
 *
 * @return TIOLayerInterface An interface that describes this pixel buffer input or output.
 */

TIOLayerInterface * _Nullable TIOModelParseTIOPixelBufferDescription(NSDictionary *dict, BOOL isInput, BOOL quantized);

/**
 * Parses the `quantization` key of an input description and returns an associated data quantizer.
 */

_Nullable TIODataQuantizer TIODataQuantizerForDict(NSDictionary * _Nullable dict, NSError **error);

/**
 * Parses the `dequantization` key of an output description and returns an associated data dequantizer.
 */

_Nullable TIODataDequantizer TIODataDequantizerForDict(NSDictionary * _Nullable dict, NSError **error);

/**
 * Converts an array of shape values to an `TIOImageVolume`.
 */

TIOImageVolume TIOImageVolumeForShape(NSArray<NSNumber*> *_Nullable shape);

/**
 * Converts a pixel format string such as `"RGB"` or `"BGR"` to a Core Video pixel format type.
 */

OSType TIOPixelFormatForString(NSString * _Nullable formatString);

/**
 * Returns the TIOPixelNormalizer given an input dictionary.
 */

TIOPixelNormalizer _Nullable TIOPixelNormalizerForDictionary(NSDictionary * _Nullable input, NSError **error);

/**
 * Returns the denormalizer for a given input dictionary.
 */

TIOPixelDenormalizer _Nullable TIOPixelDenormalizerForDictionary(NSDictionary * _Nullable input, NSError **error);

/**
 * Returns the data type for a given dtype string.
 */

TIODataType TIODataTypeForString(NSString * _Nullable string);

// MARK: - Pixel Format

/**
 * No pixel format, used to represent an error reading the pixel format from the model.json file.
 */

extern const OSType TIOPixelFormatTypeInvalid;

NS_ASSUME_NONNULL_END
