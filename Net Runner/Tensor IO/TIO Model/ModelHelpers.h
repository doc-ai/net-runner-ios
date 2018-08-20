//
//  ModelHelpers.h
//  Net Runner
//
//  Created by Philip Dow on 7/13/18.
//  Copyright © 2018 doc.ai. All rights reserved.
//


#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

// MARK: - Errors

/**
 * Set the `TIOModel` laod error to `kTFModelLoadModelError` when the underlying
 * model (e.g. tflite model) cannot be loaded.
 */

extern NSError * const kTFModelLoadModelError;

/**
 * Set the `TIOModel` load error to `kTFModelConstructInterpreterError` when the
 * tflite interpreter cannot be constructed.
 */

extern NSError * const kTFModelConstructInterpreterError;

/**
 * Set the `TIOModel` load error to `kTFModelAllocateTensorsError` when the tflite
 * tensors cannot be created.
 */

extern NSError * const kTFModelAllocateTensorsError;

NS_ASSUME_NONNULL_END
