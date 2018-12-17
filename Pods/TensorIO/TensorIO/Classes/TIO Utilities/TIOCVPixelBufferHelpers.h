//
//  TIOCVPixelBufferHelpers.h
//  TensorIO
//
//  Created by Philip Dow on 7/3/18.
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

#ifndef TIOCVPixelBufferHelpers_h
#define TIOCVPixelBufferHelpers_h

#import <AVFoundation/AVFoundation.h>
#import <Accelerate/Accelerate.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * Rotation constants used with `TIOCVPixelBufferRotate`.
 */

typedef enum : NSUInteger  {
    Rotate0Degrees = 0,
    Rotate90Degrees = 1,
    Rotate180Degrees = 2,
    Rotate270Degrees = 3
} TIOCVPixelBufferCounterclockwiseRotation;

/**
 * Returns a copy of the pixel buffer.
 *
 * You must release the returned pixel buffer with `CVPixelBufferRelease`.
 *
 * @param pixelBuffer The pixel buffer to copy.
 *
 * @return CVPixelBufferRef A copy of the pixel buffer. Returns `NULL` if a
 * destination pixel buffer could not be created.
 */

_Nullable CVPixelBufferRef TIOCVPixelBufferCopy(CVPixelBufferRef pixelBuffer);

/**
 * Rotates the pixel buffer at 90 degree intervals in a counterclockwise direction.
 *
 * You must release the returned pixel buffer with `CVPixelBufferRelease`.
 *
 * @param pixelBuffer The pixel buffer to rotate.
 * @param rotation The amount of rotation to apply.
 *
 * @return CVPixelBufferRef A rotated copy of the pixel buffer. Returns `NULL` if a
 * destination pixel buffer could not be created or the rotation fails.
 */

_Nullable CVPixelBufferRef TIOCVPixelBufferRotate(CVPixelBufferRef pixelBuffer, TIOCVPixelBufferCounterclockwiseRotation rotation);

/**
 * Converts a pixel buffer in ARGB format to one in BGRA format.
 *
 * Caller must release the returned pixel buffer with `CVPixelBufferRelease`.
 *
 * @param pixelBuffer The ARGB formatted pixel buffer to convert.
 *
 * @return CVPixelBufferRef A copy of the pixel buffer in BGRA format. Returns `NULL` if a
 * destination pixel buffer could not be created.
 */

_Nullable CVPixelBufferRef TIOCVPixelBufferCreateBGRAFromARGB(CVPixelBufferRef pixelBuffer);

/**
 * Converts a pixel buffer in BGRA format to one in ARGB format.
 *
 * Caller must release the returned pixel buffer with `CVPixelBufferRelease`.
 *
 * @param pixelBuffer The BGRA formatted pixel buffer to convert.
 *
 * @return CVPixelBufferRef A copy of the pixel buffer in ARGB format. Returns `NULL` if a
 * destination pixel buffer could not be created.
 */

_Nullable CVPixelBufferRef TIOCVPixelBufferCreateARGBFromBGRA(CVPixelBufferRef pixelBuffer);

/**
 * Copies an ARGB or BGRA formatted pixel buffer into four separate, channelwise grayscale pixel buffers.
 *
 * Caller must release the new pixel buffers with `CVPixelBufferRelease`.
 *
 * @param pixelBuffer The pixel buffer to factor into its four channels.
 * @param channel0Buffer A pointer to a pixel buffer that will contain the contents of the first channel.
 * Set to `NULL` if any of the four channel buffers cannot be created.
 * @param channel1Buffer A pointer to a pixel buffer that will contain the contents of the second channel.
 * Set to `NULL` if any of the four channel buffers cannot be created.
 * @param channel2Buffer A pointer to a pixel buffer that will contain the contents of the third channel.
 * Set to `NULL` if any of the four channel buffers cannot be created.
 * @param channel3Buffer A pointer to a pixel buffer that will contain the contents of the fourth channel.
 * Set to `NULL` if any of the four channel buffers cannot be created.
 *
 * @return CVReturn `kCVReturnSuccess` if the operation was successful, `kCVReturnError` otherwise.
 */

CVReturn TIOCVPixelBufferCopySeparateChannels(
    CVPixelBufferRef pixelBuffer,
    CVPixelBufferRef _Nullable * _Nonnull channel0Buffer,
    CVPixelBufferRef _Nullable * _Nonnull channel1Buffer,
    CVPixelBufferRef _Nullable * _Nonnull channel2Buffer,
    CVPixelBufferRef _Nullable * _Nonnull channel3Buffer
    );

/**
 * Returns a copy of the pixel buffer scaled and center cropped to size.
 *
 * Size must have equal width and height, and the target size must be smaller
 * than the source size.
 *
 * Caller must release the returned pixel buffer with `CVPixelBufferRelease`.
 *
 * @param pixelBuffer The pixel buffer to scale and crop.
 * @param size The target size of the scale and cropped buffer.
 *
 * @return CVPixelBufferRef A copy of the pixel buffer scaled and cropped. Returns `NULL` if a
 * destination pixel buffer could not be created.
 */

_Nullable CVPixelBufferRef TIOCVPixelBufferResizeToSquare(CVPixelBufferRef pixelBuffer, CGSize size);

NS_ASSUME_NONNULL_END

#endif /* CVPixelBuffer_Utilities_h */
