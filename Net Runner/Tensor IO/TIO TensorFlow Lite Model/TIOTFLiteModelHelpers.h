//
//  TIOTFLiteModelHelpers.hpp
//  Net Runner Parser
//
//  Created by Philip Dow on 8/7/18.
//  Copyright © 2018 doc.ai. All rights reserved.
//
//  TODO: Move parsing to ModelHelpers or even to a separate class

#import <Foundation/Foundation.h>

#include <vector>
#include <iostream>
#include <fstream>

#import "TIOData.h"
#import "TIODataInterface.h"
#import "Quantization.h"

NS_ASSUME_NONNULL_BEGIN

@class ModelBundle;
@class TIODataInterface;

// MARK: - Parsing

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

TIODataInterface * _Nullable TIOTFLiteModelParseTIOVectorDescription(NSDictionary *dict, BOOL isInput, BOOL quantized, ModelBundle *bundle);

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

_Nullable DataQuantizer TIODataQuantizerForDict(NSDictionary *dict);

/**
 * Parses the `dequantization` key of an output description and returns an associated data quantizer
 */

_Nullable DataDequantizer TIODataDequantizerForDict(NSDictionary *dict);

// MARK: - Assets

/**
 * Reads the labels associated with a TIOVector feature.
 */

void LoadLabels(NSString* labels_path, std::vector<std::string>* label_strings);

NS_ASSUME_NONNULL_END
