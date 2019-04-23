//
//  TIOPixelBufferLayerDescription.h
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
#import <AVFoundation/AVFoundation.h>

#import "TIOLayerDescription.h"
#import "TIOVisionModelHelpers.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * The description of a pixel buffer input or output layer.
 */

@interface TIOPixelBufferLayerDescription : NSObject <TIOLayerDescription>

/**
 * `YES` is the layer is quantized, `NO` otherwise
 */

@property (readonly, getter=isQuantized) BOOL quantized;

/**
 * `YES` if this tensor includes a dimension for the batch, no otherwise. A
 * workaround until a more permanent solution is implemented. See issue #41
 */

@property (readonly, getter=isBatched) BOOL batched __attribute__((deprecated));

/**
 * The pixel format of the image data, must be kCVPixelFormatType_32BGRA or kCVPixelFormatType_32BGRA
 */

@property (readonly) OSType pixelFormat;

/**
 * The shape of the pixel data, including width, height, and channels
 */

@property (readonly) TIOImageVolume shape;

/**
 * A function that normalizes pixel values from a uint8_t range of `[0,255]` to some other
 * floating point range, may be `nil`.
 */

@property (nullable, readonly) TIOPixelNormalizer normalizer;

/**
 * A function that denormalizes pixel values from a floating point range back to uint8_t values
 * in the range `[0,255]`, may be nil.
 */

@property (nullable, readonly) TIOPixelDenormalizer denormalizer ;

/**
 * Designated initializer. Creates a pixel buffer description from the properties parsed in a
 * model.json file.
 *
 * @param pixelFormat The expected format of the pixels
 * @param shape The shape of the image volume
 * @param batched `YES` if this tensor has a dimension for the batch size
 * @param normalizer A function which normalizes the pixel values for an input layer, may be `nil`.
 * @param denormalizer A function which denormalizes pixel values for an output layer, may be `nil`
 * @param quantized `YES` if this layer expectes quantized values, `NO` otherwise
 *
 * @return instancetype A read-only instance of `TIOPixelBufferLayerDescription`
 */

- (instancetype)initWithPixelFormat:(OSType)pixelFormat shape:(TIOImageVolume)shape batched:(BOOL)batched normalizer:(nullable TIOPixelNormalizer)normalizer denormalizer:(nullable TIOPixelDenormalizer)denormalizer quantized:(BOOL)quantized NS_DESIGNATED_INITIALIZER;

/**
 * Use the designated initializer.
 */

- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
