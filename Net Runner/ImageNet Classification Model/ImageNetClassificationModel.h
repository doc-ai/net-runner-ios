//
//  ImageNetClassificationModel.h
//  tflite_camera_example
//
//  Created by Philip Dow on 7/5/18.
//  Copyright © 2018 doc.ai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

#import "Model.h"
#import "VisionModel.h"
#import "CVPixelBufferHelpers.h"

NS_ASSUME_NONNULL_BEGIN

@class ImageNetClassificationModelOutput;
@class ModelBundle;

@interface ImageNetClassificationModel : NSObject <VisionModel>

// Model Protocol Properties

@property (readonly) ModelBundle *bundle;
@property (readonly) ModelOptions *options;

@property (readonly) NSString* identifier;
@property (readonly) NSString* name;
@property (readonly) NSString* details;
@property (readonly) NSString* author;
@property (readonly) NSString* license;
@property (readonly) BOOL quantized;
@property (readonly) ModelWeightSize weightSize;
@property (readonly) BOOL loaded;

// Vision Model Protocol Properties

@property (readonly) PixelNormalization normalization;
@property (readonly) PixelNormalizer normalizer;
@property (readonly) ImageVolume imageVolume;
@property (readonly) OSType pixelFormat;

// Model Protocol Methods

- (nullable instancetype)initWithBundle:(ModelBundle*)bundle;

- (BOOL)load:(NSError**)error;
- (void)unload;

// Vision Model Protocol Methods

- (ImageNetClassificationModelOutput*)runModelOn:(CVPixelBufferRef)pixelBuffer;
- (CVPixelBufferRef)inputPixelBuffer;

@end

NS_ASSUME_NONNULL_END
