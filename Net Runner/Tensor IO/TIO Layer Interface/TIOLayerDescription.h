//
//  TIOLayerInterface.h
//  TensorIO
//
//  Created by Philip Dow on 8/5/18.
//  Copyright © 2018 doc.ai. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * Describes an input or output layer. Used internally by a model when parsing its description.
 *
 * A layer description encapsulates information about an input or output tensor that is needed
 * to prepare obj-c data and copy bytes into and out of it. For example, a vector layer description
 * for an input tensor describes any transformations the submitted data must undergo before the
 * underlying bytes are copied to the tensor, e.g. quantization and normalization, as well as the
 * shape of the expected input, which determines how many bytes are copied into the tensor.
 */

@protocol TIOLayerDescription <NSObject>

/**
 * `YES` if this data is quantized (bytes of type uint8_t), `NO` if not (bytes of type float_t)
 */

@property (readonly, getter=isQuantized) BOOL quantized;

@end

NS_ASSUME_NONNULL_END
