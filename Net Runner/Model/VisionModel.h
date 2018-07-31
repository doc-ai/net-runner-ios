//
//  VisionModel.h
//  Net Runner
//
//  Created by Philip Dow on 7/11/18.
//  Copyright © 2018 doc.ai. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CVPixelBufferHelpers.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * Describes how pixel values in the range of `[0,255]` will be normalized for
 * non-quantized, float32 models.
 *
 * Pixels will be typically normalized to values in the range `[0,1]` or `[-1,+1]`,
 * although separate biases may be applied to each of the RGB channels.
 */

typedef struct PixelNormalization {
    float scale;
    float redBias;
    float greenBias;
    float blueBias;
} PixelNormalization;

@protocol Model;
@protocol ModelOutput;

/**
 * A `VisionModel` conforms to the `Model` protocol and is specifically for performing computer vision inference.
 */

@protocol VisionModel <Model, NSObject>

/**
 * The normalization used by the model. See the discussion for `PixelNormalization`.
 */

@property (readonly) PixelNormalization normalization;

/**
 * A function that actally applies the normalization required by the model.
 */

@property (readonly) PixelNormalizer normalizer;

/**
 * The shape of the image input.
 *
 * Computer vision models often take inputs with `[128,128,3]`, `[224,224,3]` or `[229,229,3]`
 *  width, height, and channels respectively.
 */

@property (readonly) ImageVolume imageVolume;

/**
 * The pixel format require by the model, typically `RGB` or `BGR`, corresponding to
 * `kCVPixelFormatType_32BGRA` or `kCVPixelFormatType_32ARGB` with the alpha channel
 * ignored.
 */

@property (readonly) OSType pixelFormat;

/**
 * The single interface to the model. May be called on a separate thread.
 *
 * Typically you will use one of the `Evaluator` conforming classes to handle input transformation and model execution.
 * See, for example, `CVPixelBufferEvaluator`.
 *
 * @param pixelBuffer Core video pixel buffer that will be normalized and passed to the model.
 * The pixelBuffer must already be in the size and format expected by the model, which can
 * be accomplished using the `VisionPipeline`.
 *
 * @return `ModelOutput` wrapper to the underlying data
 */

- (id<ModelOutput>)runModelOn:(CVPixelBufferRef)pixelBuffer;

/**
 * The scaled, cropped, rotatated, and pixel formatted pixel buffer that the model actually sees,
 * prior to the last step of image preprocessing, e.g. normalization.
 *
 * You may use this representation of the input to visually inspect and debug what the model sees.
 */

- (CVPixelBufferRef)inputPixelBuffer;

@end

NS_ASSUME_NONNULL_END
