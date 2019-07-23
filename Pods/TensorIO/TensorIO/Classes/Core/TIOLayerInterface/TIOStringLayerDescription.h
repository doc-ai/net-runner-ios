//
//  TIOStringLayerDescription.h
//  TensorIO
//
//  Created by Phil Dow on 7/3/19.
//  Copyright © 2019 doc.ai (http://doc.ai)
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
#import "TIODataTypes.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * The description of a string (raw bytes) input or output layer.
 *
 * String inputs and outputs capture the raw bytes passed to a tensor or
 * extracted from one. Both TensorFlow and Caffe call this data type a "string",
 * although here it will be captured in an NSData object wrapping the underlying
 * bytes.
 *
 * No quantization or dequantization is applied to raw bytes. They are copied
 * directly to the underling tensor.
 */

@interface TIOStringLayerDescription : NSObject <TIOLayerDescription>

// MARK: - TIOLayerDescription Properties

/**
 * `YES` if this data is quantized (bytes of type uint8_t), `NO` if not (bytes of type float_t)
 */

@property (readonly, getter=isQuantized) BOOL quantized;

/**
 * The shape of the underlying tensor, which may include a `-1` along the first or last axis
 * to indicate the batch dimension.
 */

@property (readonly) NSArray<NSNumber*> *shape;

/**
 * `YES` if this tensor includes a dimension for the batch, `NO` otherwise.
 */

@property (readonly, getter=isBatched) BOOL batched;

// MARK: - TIOStringLayerDescription Properties

/**
 * The layer's data type
 *
 * @warning
 * There are complex interactions between backends, data types, and quantization
 * that will be addressed and validated in later releases.
 */

@property (readonly) TIODataType dtype;

/**
 * The length of the string in terms of its total number of elements. Calculated
 * as the product of the dimensions in `shape`. A dimension of -1 which acts as
 * placeholder for a batch size will be interpreted as a 1.
 *
 * To get the actual byte length you must multiply this value by the number of
 * bytes required for the `dtype`.
 */

@property (readonly) NSUInteger length;

// MARK: - Init

/**
 * Designated initializer. Creates a vector description from the properties parsed in a model.json
 * file.
 *
 * @param shape The shape of the underlying tensor
 * @param batched `YES` if the underlying tensor supports batching
 * @param dtype The type of data this layer expects or produces
 *
 * @return instancetype A read-only instance of `TIOStringLayerDescription`
 */

- (instancetype)initWithShape:(NSArray<NSNumber*>*)shape batched:(BOOL)batched dtype:(TIODataType)dtype NS_DESIGNATED_INITIALIZER;

/**
 * Use the designated initializer.
 */

- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
