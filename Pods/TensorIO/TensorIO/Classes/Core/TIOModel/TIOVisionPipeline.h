//
//  TIOVisionPipeline.h
//  TensorIO
//
//  Created by Philip Dow on 7/11/18.
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

NS_ASSUME_NONNULL_BEGIN

@class TIOPixelBufferLayerDescription;

/**
 * The `TIOVisionPipeline` is responsible for scaling and croping, rotating, and converting the provided pixel buffer
 * to an ARGB or BGRA pixel format, using properties specified by the model.
 */

@interface TIOVisionPipeline : NSObject

/**
 * A description of the pixel input expected by the model.
 */

@property (readonly) TIOPixelBufferLayerDescription *pixelBufferDescription;

/**
 * Designated initializer.
 *
 * @param pixelBufferDescription A description of the input layer that specifies the transformations
 * needed to convert a pixel buffer to a format that can be accepted by the model.
 */

- (instancetype)initWithTIOPixelBufferDescription:(TIOPixelBufferLayerDescription *)pixelBufferDescription;

/**
 * Use the designated initializer.
 */

- (instancetype)init NS_UNAVAILABLE;

/**
 * Transform a pixel buffer into the format required by the `TIOPixelBufferLayerDescription`.
 *
 * A single TIOVisionPipeline may be used to transform multiple pixel buffers for the same model.
 *
 * @param pixelBuffer The `CVPixelBufferRef` that will be transformed.
 * @param orientation The orientation of the pixel buffer.
 *
 * @return An autoreleased `CVPixelBufferRef` that is suitable for use as input to the model.
 */

- (nullable CVPixelBufferRef)transform:(CVPixelBufferRef)pixelBuffer orientation:(CGImagePropertyOrientation)orientation;

@end

NS_ASSUME_NONNULL_END
