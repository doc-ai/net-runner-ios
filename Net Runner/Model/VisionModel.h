//
//  VisionModel.h
//  tflite_camera_example
//
//  Created by Philip Dow on 7/11/18.
//  Copyright © 2018 doc.ai. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CVPixelBufferHelpers.h"

NS_ASSUME_NONNULL_BEGIN

typedef struct PixelNormalization {
    float scale;
    float redBias;
    float greenBias;
    float blueBias;
} PixelNormalization;

@protocol Model;
@protocol ModelOutput;

@protocol VisionModel <Model, NSObject>

@property (readonly) PixelNormalization normalization;
@property (readonly) PixelNormalizer normalizer;
@property (readonly) ImageVolume imageVolume;
@property (readonly) OSType pixelFormat;

/**
 * The single interface to the model. May be called on a separate thread.
 *
 * @param pixelBuffer core video pixel buffer that will be normalized and passed to the model.
 * The pixelBuffer must already be in the size and format expected by the model, which can
 * be accomplished using the `VisionPipeline`.
 *
 * @return `ModelOutput` wrapper to the underlying data
 */

- (id<ModelOutput>)runModelOn:(CVPixelBufferRef)pixelBuffer;

/**
 * The scaled, cropped, rotatated, and pixel formatted pixel buffer that the model actually sees,
 * prior to any other image preprocessing, e.g. normalization. You may use this representation of
 * the input to visually inspect and debug what the model sees.
 */

- (CVPixelBufferRef)inputPixelBuffer;

@end

NS_ASSUME_NONNULL_END
