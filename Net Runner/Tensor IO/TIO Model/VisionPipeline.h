//
//  VisionPipeline.h
//  Net Runner
//
//  Created by Philip Dow on 7/11/18.
//  Copyright © 2018 doc.ai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@class TIOPixelBufferDescription;

/**
 * The `VisionPipeline` is responsible for scaling and croping, rotating, and converting the provided pixel buffer
 * to an ARGB or BGRA pixel format, using properties specified by the model.
 */

@interface VisionPipeline : NSObject

/**
 * A description of the pixel input expected by the model
 */

@property (readonly) TIOPixelBufferDescription *pixelBufferDescription;

/**
 * Designated initializer.
 *
 * @param pixelBufferDescription A description of the input layer that specifies the transformations
 * needed to convert a pixel buffer to a format that can be accepted by the model.
 */

- (instancetype)initWithTIOPixelBufferDescription:(TIOPixelBufferDescription*)pixelBufferDescription;

/**
 * Use the designated initializer.
 */

- (instancetype)init NS_UNAVAILABLE;

/**
 * Transform a pixel buffer into the format required by the `TIOPixelBufferDescription`.
 *
 * A single VisionPipeline may be used to transform multiple pixel buffers for the same model.
 *
 * @param pixelBuffer The `CVPixelBufferRef` that will be transformed.
 * @param orientation The orientation of the pixel buffer.
 *
 * @return A `CVPixelBufferRef` that is suitable for use as input to the model.
 */

- (nullable CVPixelBufferRef)transform:(CVPixelBufferRef)pixelBuffer orientation:(CGImagePropertyOrientation)orientation;

@end

NS_ASSUME_NONNULL_END
