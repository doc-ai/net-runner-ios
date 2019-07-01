//
//  TIOVectorLayerDescription.h
//  TensorIO
//
//  Created by Philip Dow on 8/5/18.
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
#import "TIOVector.h"
#import "TIOQuantization.h"
#import "TIODataTypes.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * The description of a vector (array) input or output later.
 *
 * Vector inputs and outputs are always unrolled vectors, and from the tensor's perspective they are
 * just an array of bytes. The total length of a vector will be the total volume of the layer.
 * For example, if an input layer is a tensor of shape `(24,24,2)`, the length of the vector will be
 * `24x24x2 = 1152`.
 *
 * TensorFlow and TensorFlow Lite models expect row major ordering of bytes,
 * such that higher order dimensions are traversed first. For example, a 2x4 matrix
 * with the following values:
 *
 * @code
 * [[1 2 3 4]
 *  [5 6 7 8]]
 * @endcode
 *
 * should be unrolled and provided to the model as:
 *
 * @code
 * [1 2 3 4 5 6 7 8]
 * @endcode
 *
 * i.e, start with the row and traverse the columns before moving to the next row.
 *
 * Because output layers are also exposed as an array of bytes, a `TIOTFLiteModel` will always return
 * a vector in one dimension. If is up to you to reshape it if required.
 *
 * @warning
 * A `TIOVectorLayerDescription`'s length is different than the byte length of a `TIOData` object.
 * For example a quantized `TIOVector` (uint8_t) of length 4 will occupy 4 bytes of memory but an
 * unquantized `TIOVector` (float_t) of length 4 will occupy 16 bytes of memory.
 */

@interface TIOVectorLayerDescription : NSObject <TIOLayerDescription>

// MARK: - TIOLayerDescription Properties

/**
 * `YES` if the layer is quantized, `NO` otherwise
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

// MARK: - TIOVectorLayerDescription Properties

/**
 * The layer's data type
 *
 * @warning
 * There are complex interactions between backends, data types, and quantization
 * that will be addressed and validated in later releases.
 */

@property (readonly) TIODataType dtype;

/**
 * The length of the vector in terms of its total number of elements. Calculated
 * as the product of the dimenions in `shape`. A dimension of -1 which acts as
 * placeholder for a batch size will be interpreted as a 1.
 */

@property (readonly) NSUInteger length;

/**
 * Indexed labels corresponding to the indexed output of a layer. May be `nil`.
 *
 * Labeling the output of a model is such a common operation that support for it is included
 * by default.
 */

@property (nullable,readonly,copy) NSArray<NSString*> *labels;

/**
 * `YES` if there are labels associated with this layer, `NO` otherwise.
 */

@property (readonly,getter=isLabeled) BOOL labeled;

/**
 * A function that converts a vector from unquantized values to quantized values
 */

@property (nullable, readonly) TIODataQuantizer quantizer;

/**
 * A function that converts a vector from quantized values to unquantized values
 */

@property (nullable, readonly) TIODataDequantizer dequantizer;

// MARK: - Init

/**
 * Designated initializer. Creates a vector description from the properties parsed in a model.json
 * file.
 *
 * @param shape The shape of the underlying tensor
 * @param batched `YES` if the underlying tensor supports batching
 * @param dtype The type of data this layer expects or produces
 * @param labels The indexed labels associated with the outputs of this layer. May be `nil`.
 * @param quantized `YES` if the underlying model is quantized, `NO` otherwise
 * @param quantizer A function that transforms unquantized values to quantized input
 * @param dequantizer A function that transforms quantized output to unquantized values
 *
 * @return instancetype A read-only instance of `TIOVectorLayerDescription`
 */

- (instancetype)initWithShape:(NSArray<NSNumber*>*)shape
    batched:(BOOL)batched
    dtype:(TIODataType)dtype
    labels:(nullable NSArray<NSString*>*)labels
    quantized:(BOOL)quantized
    quantizer:(nullable TIODataQuantizer)quantizer
    dequantizer:(nullable TIODataDequantizer)dequantizer
    NS_DESIGNATED_INITIALIZER;

/**
 * Use the designated initializer.
 */

- (instancetype)init NS_UNAVAILABLE;

/**
 * Given the output vector of a tensor, returns labeled outputs using `labels`.
 *
 * @param vector A `TIOVector` of values.
 *
 * @return NSDictionary The labeled values, where the dictionary keys are the labels and the
 * dictionary values are the associated vector values.
 *
 * `labels` must not be `nil`.
 */

- (NSDictionary<NSString*,NSNumber*>*)labeledValues:(TIOVector *)vector;


@end

NS_ASSUME_NONNULL_END
