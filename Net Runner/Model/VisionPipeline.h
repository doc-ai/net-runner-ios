//
//  VisionPipeline.h
//  tflite_camera_example
//
//  Created by Philip Dow on 7/11/18.
//  Copyright © 2018 doc.ai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol VisionModel;

@interface VisionPipeline : NSObject

- (instancetype) initWithVisionModel:(id<VisionModel>)model;

/*
 * Scales and crops, rotates, and converts the provided pixel buffer to ARGB or BGRA,
 * using properties specified by the model.
 */

- (nullable CVPixelBufferRef) transform:(CVPixelBufferRef)pixelBuffer orientation:(CGImagePropertyOrientation)orientation;

@end

NS_ASSUME_NONNULL_END
