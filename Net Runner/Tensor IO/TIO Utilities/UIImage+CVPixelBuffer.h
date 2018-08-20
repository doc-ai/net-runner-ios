//
//  UIImage+CVPixelBuffer.h
//  TensorIO
//
//  Created by Philip Dow on 7/6/18.
//  Copyright © 2018 doc.ai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <VideoToolbox/VideoToolbox.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (CVPixelBuffer)

- (nullable instancetype) initWithPixelBuffer:(CVPixelBufferRef)pixelBuffer;
- (nullable instancetype) initWithPixelBuffer:(CVPixelBufferRef)pixelBuffer scale:(CGFloat)scale orientation:(UIImageOrientation)orientation;

/**
 * Creates a pixel buffer from the receiver via Core Graphics
 *
 * @return A `CVPixelBufferRef` that is autoreleased and by default has the following format:
 *      Pixel Format: `kCVPixelFormatType_32ARGB`
 *      Alpha: `kCGImageAlphaNoneSkipFirst`
 *      Color Space: Device RGB
 */

- (nullable CVPixelBufferRef) pixelBuffer;
- (nullable CVPixelBufferRef) pixelBuffer:(OSType)format colorSpace:(CGColorSpaceRef)colorSpace alphaInfo:(CGImageAlphaInfo)alphaInfo;

@end

NS_ASSUME_NONNULL_END
