//
//  ModelHelpers.h
//  Net Runner
//
//  Created by Philip Dow on 7/13/18.
//  Copyright © 2018 doc.ai. All rights reserved.
//


#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

// MARK: - Quantization

typedef struct DataQuantization {
    float scale;
    float bias;
} DataQuantization;

typedef uint8_t (^DataQuantizer)(const float_t &value);

_Nullable DataQuantizer TIODataQuantizerNone();

// MARK: - Dequantization

typedef struct DataDequantization {
    float scale;
    float bias;
} DataDequantization;

typedef float_t (^DataDequantizer)(const uint8_t &value);

_Nullable DataDequantizer TIODataDequantizerNone();

/**
 * Dequantizes values from a range of `[0,255]` to `[0,1]`.
 *
 * This is equivalent to applying a scaling factor of `1.0/255.0` and no bias.
 */

DataDequantizer DataDequantizerZeroToOne();

// MARK: - Errors

/**
 * Set the `Model` laod error to `kTFModelLoadModelError` when the underlying
 * model (e.g. tflite model) cannot be loaded.
 */

extern NSError * const kTFModelLoadModelError;

/**
 * Set the `Model` load error to `kTFModelConstructInterpreterError` when the
 * tflite interpreter cannot be constructed.
 */

extern NSError * const kTFModelConstructInterpreterError;

/**
 * Set the `Model` load error to `kTFModelAllocateTensorsError` when the tflite
 * tensors cannot be created.
 */

extern NSError * const kTFModelAllocateTensorsError;

NS_ASSUME_NONNULL_END
