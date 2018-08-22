//
//  UIImage+TIOCVPixelBufferExtensions.h
//  TensorIO
//
//  Created by Philip Dow on 7/6/18.
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

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <VideoToolbox/VideoToolbox.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (CVPixelBuffer)

/**
 * Instantiates an image from a pixel buffer, assuming a scaling factor of 1.0 and an orientation
 * of UIImageOrientationUp
 *
 * @param pixelBuffer The source pixel buffer
 *
 * @return UIImage The resulting image
 */

- (nullable instancetype)initWithPixelBuffer:(CVPixelBufferRef)pixelBuffer;

/**
 * Instantiates an image from a pixel buffer
 *
 * @param pixelBuffer The source pixel buffer
 * @param scale The image scale
 * @param orientation The resulting image's orientation
 *
 * @return UIImage The resulting image
 */
- (nullable instancetype)initWithPixelBuffer:(CVPixelBufferRef)pixelBuffer scale:(CGFloat)scale orientation:(UIImageOrientation)orientation;

/**
 * Creates a pixel buffer from the receiver via Core Graphics.
 *
 * The pixel buffer will have the following format:
 *
 * - Pixel Format: `kCVPixelFormatType_32ARGB`
 *
 * - Alpha: `kCGImageAlphaNoneSkipFirst`
 *
 * - Color Space: Device RGB
 *
 * @return `CVPixelBufferRef` Autoreleased
 *
 */

- (nullable CVPixelBufferRef)pixelBuffer;

/**
 * Creates a pixel buffer from the receiver via Core Graphics.
 *
 * @param format The pixel format of the resulting pixel buffer
 * @param colorSpace The color space of the resulting pixel buffer
 * @param alphaInfo Alpha channel info for the resulting pixel buffer
 *
 * @return An autoreleased `CVPixelBufferRef`
 */

- (nullable CVPixelBufferRef)pixelBuffer:(OSType)format colorSpace:(CGColorSpaceRef)colorSpace alphaInfo:(CGImageAlphaInfo)alphaInfo;

@end

NS_ASSUME_NONNULL_END
