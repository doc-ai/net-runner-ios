//
//  ImageNetClassificationModel.h
//  Net Runner
//
//  Created by Philip Dow on 7/5/18.
//  Copyright © 2018 doc.ai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

#import "Model.h"
#import "CVPixelBufferHelpers.h"

NS_ASSUME_NONNULL_BEGIN

@class ModelBundle;

/**
 * A model suitable for use in ImageNet classification problems.
 *
 * This single class may be used for multiple kinds of models, including MobileNet, Inception, and ResNet models,
 * both quantized and unquantized, as long as they are performing classification inference on an image input.
 *
 * The model accepts a `CVPixelBufferRef` as input and outputs a dictionary of classifications mapped to their
 * probabilities, wrapped in an instance of `ImageNetClassificationModelOutput`.
 */

@interface ImageNetClassificationModel : NSObject <Model>

// Model Protocol Properties

@property (readonly) ModelBundle *bundle;
@property (readonly) ModelOptions *options;

@property (readonly) NSString* identifier;
@property (readonly) NSString* name;
@property (readonly) NSString* details;
@property (readonly) NSString* author;
@property (readonly) NSString* license;
@property (readonly) BOOL quantized;
@property (readonly) NSString *type;
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

- (NSDictionary*)runModelOn:(CVPixelBufferRef)pixelBuffer;
- (CVPixelBufferRef)inputPixelBuffer;

@end

NS_ASSUME_NONNULL_END
