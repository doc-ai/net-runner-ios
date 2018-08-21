//
//  TIOVectorLayerDescription.h
//  TensorIO
//
//  Created by Philip Dow on 8/5/18.
//  Copyright © 2018 doc.ai. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "TIOLayerDescription.h"
#import "TIOVector.h"
#import "TIOQuantization.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * The description of a vector (array) input or output later.
 *
 * Vector inputs and outputs are always unrolled vectors, and from the tensor's perspective they are
 * just an array of bytes. The total length of a vector will be the total volume of the layer.
 * For example, if an input layer is a tensor of shape `(24,24,2)`, the length of the vector will be
 * `24x24x2 = 1152`.
 *
 * TensorFlow Lite models expect row major ordering of bytes, such that higher order dimensions are
 * traversed first. For example, a 2x4 matrix with the following values:
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

/**
 * `YES` if the layer is quantized, `NO` otherwise
 */

@property (readonly, getter=isQuantized) BOOL quantized;

/**
 * The length of the vector in terms of its number of elements.
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

/**
 * Designated initializer. Creates a vector description from the properties parsed in a model.json
 * file.
 *
 * @param length The total number of elements in this layer.
 * @param labels The indexed labels associated with the outputs of this layer. May be `nil`.
 * @param quantizer A function that transforms unquantized values to quantized input
 * @param dequantizer A function that transforms quantized output to unquantized values
 *
 * @return instancetype A read-only instance of `TIOVectorLayerDescription`
 */

- (instancetype)initWithLength:(NSUInteger)length labels:(nullable NSArray<NSString*>*)labels quantized:(BOOL)quantized quantizer:(nullable TIODataQuantizer)quantizer dequantizer:(nullable TIODataDequantizer)dequantizer NS_DESIGNATED_INITIALIZER;

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

- (NSDictionary<NSString*,NSNumber*>*)labeledValues:(TIOVector*)vector;


@end

NS_ASSUME_NONNULL_END
