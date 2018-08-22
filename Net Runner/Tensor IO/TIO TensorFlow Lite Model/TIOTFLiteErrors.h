//
//  TIOTFLiteErrors.h
//  TensorIO
//
//  Created by Philip Dow on 7/13/18.
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
