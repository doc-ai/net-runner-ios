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

@protocol VisionModel;

/**
 * The `VisionPipeline` is responsible for scaling and croping, rotating, and converting the provided pixel buffer
 * to and ARGB or BGRA pixel format, using properties specified by the model.
 */

@interface VisionPipeline : NSObject

/**
 * The `VisionModel` object which will ultimately receive the pixel buffer provided in the transform method.
 *
 * Properties such as shape and pixel format are taken from the model and used to apply the required transformations.
 */

@property (readonly) id<VisionModel> model;

/**
 * Designated initializer.
 *
 * @param model The `VisionModel` whose properties will be used to apply the transformations needed to convert
 * a pixel buffer to a format that can be accepted by the model.
 */

- (instancetype)initWithVisionModel:(id<VisionModel>)model NS_DESIGNATED_INITIALIZER;

/**
 * Use the designated initializer.
 */

- (instancetype)init NS_UNAVAILABLE;

/**
 * Transform a pixel buffer into the format required by the `VisionModel`.
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
