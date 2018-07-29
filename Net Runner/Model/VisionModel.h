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
@property (readonly) OSType pixelFormat;

@property (readonly) ImageVolume imageVolume;

/**
 * The single interface to the model. May be called on a separate thread.
 *
 * @param pixelBuffer core video pixel buffer that will be preprocessed and passed to the model
 * @return top N dictionary of labels to confidence scores
 */

- (id<ModelOutput>)runModelOn:(CVPixelBufferRef)pixelBuffer;

/**
 * The scaled, cropped, rotatated, and pixel formatted pixel buffer that the model actually sees,
 * prior to any other image preprocessing, e.g. normalization
 */

- (CVPixelBufferRef)inputPixelBuffer;

@end

NS_ASSUME_NONNULL_END
