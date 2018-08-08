//
//  UIImage+CVPixelBuffer.h
//  Net Runner
//
//  Created by Philip Dow on 7/6/18.
//  Copyright © 2018 doc.ai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <VideoToolbox/VideoToolbox.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (CVPixelBuffer)

/**
 * Instantiates a `UIImage` from a `CVPixelBufferRef`
 *
 * @param pixelBuffer The pixel buffer to create the image from
 *
 * @return `UIImage`
 */

- (nullable instancetype)initWithPixelBuffer:(CVPixelBufferRef)pixelBuffer;

/**
 * Instantiates a `UIImage` from a `CVPixelBufferRef`
 *
 * @param pixelBuffer The pixel buffer to create the image from
 * @param scale A scaling factor to use
 * @param orientation The orientation of the pixel buffer
 *
 * @return `UIImage`
 */

- (nullable instancetype)initWithPixelBuffer:(CVPixelBufferRef)pixelBuffer scale:(CGFloat)scale orientation:(UIImageOrientation)orientation;

/**
 * Creates a pixel buffer from the receiver via Core Graphics.
 *
 * @return A `CVPixelBufferRef` that is autoreleased and by default has the following format:
 *      Pixel Format: `kCVPixelFormatType_32ARGB`
 *      Alpha: `kCGImageAlphaNoneSkipFirst`
 *      Color Space: Device RGB
 */

- (nullable CVPixelBufferRef)pixelBuffer;

/**
 * Creates a pixel buffer from the receiver via Core Graphics.
 *
 * @param format Pixel format of the generated pixel buffer, e.g. `kCVPixelFormatType_32ARGB` or kCVPixelFormatType_32BGRA`
 * @param colorSpace Color space of the generated pixel buffer, e.g. `CGColorSpaceCreateDeviceRGB()`
 * @param alphaInfo Alpha channel settings for the generated pixel buffer, e.g. `kCGImageAlphaNoneSkipFirst`
 *
 * @return CVPixelBufferRef The generated pixel buffer, may be `NULL`.
 */

- (nullable CVPixelBufferRef)pixelBuffer:(OSType)format colorSpace:(CGColorSpaceRef)colorSpace alphaInfo:(CGImageAlphaInfo)alphaInfo;

@end

NS_ASSUME_NONNULL_END
