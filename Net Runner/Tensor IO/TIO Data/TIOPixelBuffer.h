//
//  TIOPixelBuffer.h
//  Net Runner Parser
//
//  Created by Philip Dow on 8/3/18.
//  Copyright © 2018 doc.ai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

#import "TIODataDescription.h"
#import "TIOData.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * Wraps a `CVPixelBuffer` so that it can act as a data provider and recipient for a model.
 */

@interface TIOPixelBuffer : NSObject <TIOData>

/**
 * The underlying pixel buffer
 *
 * For an input layer this is the pixel buffer prior to any transformations, such as scaling,
 * cropping, and pixel format trasnformation. For an output layer, this is a pixel buffer
 * whose bytes have been supplied directly by the tensor, with an alpha channel added.
 */

@property (readonly) CVPixelBufferRef pixelBuffer;

/**
 * The pixel buffer as an input tensor sees it, with scaling, cropping, and pixel formatting applied,
 * but prior to any normaliation or removal of the alpha channel. `NULL` for an output.
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
 * to the tensor with no intermediate transformations.
 */

- (instancetype)initWithPixelBuffer:(CVPixelBufferRef)pixelBuffer orientation:(CGImagePropertyOrientation)orientation NS_DESIGNATED_INITIALIZER;

/**
 * Use the designated initializer
 */

- (instancetype)init NS_UNAVAILABLE;

- (nullable instancetype)initWithBytes:(const void *)bytes length:(NSUInteger)length description:(id<TIODataDescription>)description;
- (void)getBytes:(void *)buffer length:(NSUInteger)length description:(id<TIODataDescription>)description;

@end

NS_ASSUME_NONNULL_END
