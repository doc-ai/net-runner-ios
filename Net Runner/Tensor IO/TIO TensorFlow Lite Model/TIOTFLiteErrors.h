//
//  TIOTFLiteErrors.h
//  Net Runner
//
//  Created by Philip Dow on 7/13/18.
//  Copyright © 2018 doc.ai. All rights reserved.
//


#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

// MARK: - Errors

/**
 * Set the `TIOModel` laod error to `kTFLiteModelLoadModelError` when the underlying
 * model (e.g. tflite model) cannot be loaded.
 */

extern NSError * const kTFLiteModelLoadModelError;

/**
 * Set the `TIOModel` load error to `kTFLiteModelConstructInterpreterError` when the
 * tflite interpreter cannot be constructed.
 */

extern NSError * const kTFLiteModelConstructInterpreterError;

/**
 * Set the `TIOModel` load error to `kTFLiteModelAllocateTensorsError` when the tflite
 * tensors cannot be created.
 */

extern NSError * const kTFLiteModelAllocateTensorsError;

NS_ASSUME_NONNULL_END
