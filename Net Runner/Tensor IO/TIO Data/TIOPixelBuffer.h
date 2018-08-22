//
//  TIOPixelBuffer.h
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
#import <AVFoundation/AVFoundation.h>

#import "TIOLayerDescription.h"
#import "TIOData.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * Wraps a `CVPixelBuffer` so that it can provide data to and receive data from a tensor.
 */

@interface TIOPixelBuffer : NSObject <TIOData>

/**
 * The underlying pixel buffer
 *
 * For an input layer this is the pixel buffer prior to any transformations, such as scaling,
 * cropping, and pixel format transoformation. For an output layer, this is a pixel buffer
 * whose bytes have been supplied by the tensor, with any denormalization applied and an alpha
 * channel added.
 */

@property (readonly) CVPixelBufferRef pixelBuffer;

/**
 * The pixel buffer as an input tensor sees it, with scaling, cropping, and pixel formatting applied,
 * but prior to any normalization or removal of the alpha channel. `NULL` for an output.
 */

@property (readonly) CVPixelBufferRef transformedPixelBuffer;

/**
 * The orientation of the underlying pixel buffer
 *
 * Pixel buffers being streamed from an `AVCaptureDevice` have an orientation of `kCGImagePropertyOrientationRight`,
 * and like any pixel buffer whose orientation is not `kCGImagePropertyOrientationUp`, must be
 * transformed before being sent to a model.
 */

@property (readonly) CGImagePropertyOrientation orientation;

/**
 * Wraps a pixel buffer with a known orientation so that its bytes may be passed to a tensor.
 *
 * An input pixel buffer will be transformed to match the size and format expected by the tensor.
 * If the pixel buffer is already in the expected size and format its bytes will be supplied directly
 * to the tensor with no intermediate transformations, except for normalization and removal of the
 * alpha channel, as needed.
 */

- (instancetype)initWithPixelBuffer:(CVPixelBufferRef)pixelBuffer orientation:(CGImagePropertyOrientation)orientation NS_DESIGNATED_INITIALIZER;

/**
 * Use the designated initializer
 */

- (instancetype)init NS_UNAVAILABLE;

/**
 * Initializes `TIOPixelBuffer` with bytes from a tensor.
 *
 * @param bytes The output buffer to read from.
 * @param length The length of the buffer.
 * @param description A description of the data this buffer produces.
 *
 * @return instancetype An instance of `TIOPixelBuffer`
 */

- (nullable instancetype)initWithBytes:(const void *)bytes length:(NSUInteger)length description:(id<TIOLayerDescription>)description;

/**
 * Request to fill a tensor with bytes.
 *
 * @param buffer The input buffer to copy bytes to.
 * @param length The length of the input buffer.
 * @param description A description of the data this buffer expects.
 */

- (void)getBytes:(void *)buffer length:(NSUInteger)length description:(id<TIOLayerDescription>)description;

@end

NS_ASSUME_NONNULL_END
