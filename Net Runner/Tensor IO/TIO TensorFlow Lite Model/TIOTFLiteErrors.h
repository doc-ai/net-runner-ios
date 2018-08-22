//
//  TIOTFLiteErrors.h
//  TensorIO
//
//  Created by Philip Dow on 7/13/18.
//  Copyright © 2018 doc.ai. All rights reserved.
//


#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * Set the `TIOModel` laod error to `kTIOTFLiteModelLoadModelError` when the underlying
 * model (e.g. tflite model) cannot be loaded.
 */

extern NSError * const kTIOTFLiteModelLoadModelError;

/**
 * Set the `TIOModel` load error to `kTIOTFLiteModelConstructInterpreterError` when the
 * tflite interpreter cannot be constructed.
 */

extern NSError * const kTIOTFLiteModelConstructInterpreterError;

/**
 * Set the `TIOModel` load error to `kTIOTFLiteModelAllocateTensorsError` when the tflite
 * tensors cannot be created.
 */

extern NSError * const kTIOTFLiteModelAllocateTensorsError;

NS_ASSUME_NONNULL_END
