//
//  TIOQuantization.h
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

// MARK: - Quantization

/**
 * Describes how floating point data will be quantized to uint8_t data
 *
 * @field scale A scaling value
 * @field bias A bias term added after the scale is applied
 *
 * Data is quantized according to the following equation:
 * @code
 * quantized_value = value * scale + bias
 * @endcode
 */

typedef struct TIODataQuantization {
    float scale;
    float bias;
} TIODataQuantization;

/**
 * A `TIODataQuantizer` is a function that quantizes unquantized values, converting them from
 * floating point representations to uint8_t representations.
 *
 * @param value The float_t value that will be quantized
 *
 * @return uint8_t A quantized representation of the value
 */

typedef uint8_t (^TIODataQuantizer)(const float_t &value);

/**
 * No quantization, i.e., `nil`.
 */

_Nullable TIODataQuantizer TIODataQuantizerNone();

// MARK: - Dequantization

/**
 * Describes how uint8_t data will be dequantized back into a floating point representation
 *
 * @field scale A scaling value
 * @field bias A bias term added after the scale is applied
 *
 * Data is dequantized according to the following equation:
 * @code
 * dequantized_value = value * scale + bias
 * @endcode
 */

typedef struct TIODataDequantization {
    float scale;
    float bias;
} TIODataDequantization;

/**
 * A `TIODataDequantizer` is a function that dequantizes quantized values, converting them from
 * uint8_t representations to floating point representations.
 *
 * @param value The uint8_t value that will be dequantized
 *
 * @return float_t A floating point representation of the value
 */

typedef float_t (^TIODataDequantizer)(const uint8_t &value);

/**
 * No dequantization, i.e., `nil`.
 */

_Nullable TIODataDequantizer TIODataDequantizerNone();

/**
 * Dequantizes values from a range of `[0,255]` to `[0,1]`.
 *
 * This is equivalent to applying a scaling factor of `1.0/255.0` and no bias.
 */

TIODataDequantizer TIODataDequantizerZeroToOne();

NS_ASSUME_NONNULL_END
