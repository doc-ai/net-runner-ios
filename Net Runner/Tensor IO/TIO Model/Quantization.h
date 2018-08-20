//
//  Quantization.h
//  Net Runner
//
//  Created by Philip Dow on 8/19/18.
//  Copyright © 2018 doc.ai. All rights reserved.
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

typedef struct DataQuantization {
    float scale;
    float bias;
} DataQuantization;

/**
 * A `DataQuantizer` is a function that quantizes unquantized values, converting them from
 * floating point representations to uint8_t representations.
 *
 * @param value The float_t value that will be quantized
 *
 * @return uint8_t A quantized representation of the value
 */

typedef uint8_t (^DataQuantizer)(const float_t &value);

/**
 * No quantization, i.e., `nil`.
 */

_Nullable DataQuantizer TIODataQuantizerNone();

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

typedef struct DataDequantization {
    float scale;
    float bias;
} DataDequantization;

/**
 * A `DataDequantizer` is a function that dequantizes quantized values, converting them from
 * uint8_t representations to floating point representations.
 *
 * @param value The uint8_t value that will be dequantized
 *
 * @return float_t A floating point representation of the value
 */

typedef float_t (^DataDequantizer)(const uint8_t &value);

/**
 * No dequantization, i.e., `nil`.
 */

_Nullable DataDequantizer TIODataDequantizerNone();

/**
 * Dequantizes values from a range of `[0,255]` to `[0,1]`.
 *
 * This is equivalent to applying a scaling factor of `1.0/255.0` and no bias.
 */

DataDequantizer DataDequantizerZeroToOne();

NS_ASSUME_NONNULL_END
