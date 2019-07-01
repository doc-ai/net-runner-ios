//
//  TIOLayerInterface.h
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

/**
 * The shape of the underlying tensor, which may include a `-1` along the first or last axis
 * to indicate the batch dimension.
 */

@property (readonly) NSArray<NSNumber*> *shape;

/**
 * `YES` if this tensor includes a dimension for the batch, `NO` otherwise.
 */

@property (readonly, getter=isBatched) BOOL batched;

@end

NS_ASSUME_NONNULL_END
