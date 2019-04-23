//
//  NSArray+TIOTFLiteData.h
//  TensorIO
//
//  Created by Philip Dow on 8/3/18.
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

#import "TIOLayerDescription.h"
#import "TIOTFLiteData.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * An array of numbers, also typed as a `TIOVector`, is able to provide bytes to
 * or capture bytes from a TFLite tensor.
 */

@interface NSArray (TIOTFLiteData) <TIOTFLiteData>

/**
 * Initializes an `NSArray` object with bytes from a TFLite tensor.
 *
 * Bytes are copied according to the following rules, with information about quantization taken
 * from the description:
 *
 * - If the layer is unquantized, the tensor's bytes are copied directly into numeric values and
 *   added to the resulting array (the bytes are implicitly interpreted as `float_t` values)
 *
 * - If the layer is quantized and no dequantizer block is provided, the tensor's bytes are copied
 *   directly into numeric values and added to the resulting array (the bytes are implicitly
 *   interpreted as `uint8_t` values)
 *
 * - If the layer is quantized and a dequantizer block is provided, the tensor's bytes are
 *   interpreted as `uint8_t` values, passed to the dequantizer block, and the resulting `float_t`
 *   bytes are copied into numeric values and added to the resulting array
 *
 * @param bytes The output buffer to read from.
 * @param description A description of the data this buffer produces.
 *
 * @return instancetype An instance of `NSData`.
 */

- (nullable instancetype)initWithBytes:(const void *)bytes description:(id<TIOLayerDescription>)description;

/**
 * Request to fill a TFLite tensor with bytes.
 *
 * Bytes are copied according to the following rules, with information about quantization taken
 * from the description:
 *
 * - If the layer is unquantized, the bytes of the array's numeric entries are copied directly to
 *   the buffer (and implicitly interpreted as `float_t` values)
 *
 * - If the layer is quantized and no quantizer block is provided, the bytes of the array's numeric
 *   entries are copied directly to the buffer (and implicitly interpreted as `uint8_t` values)
 *
 * - If the layer is quantized and a quantizer block is provided, the the bytes of the array's
 *   numeric entries are interpreted as `float_t` values, passed to the quantizer block, and the
 *   `uint8_t` values returned from it are copied to the buffer
 *
 * @param buffer The input buffer to copy bytes to.
 * @param description A description of the data this buffer expects.
 */

- (void)getBytes:(void *)buffer description:(id<TIOLayerDescription>)description;

@end

NS_ASSUME_NONNULL_END
