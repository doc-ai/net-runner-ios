//
//  AlbumPhotoEvaluator.h
//  tflite_camera_example
//
//  Created by Philip Dow on 7/18/18.
//  Copyright © 2018 doc.ai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>

#import "Evaluator.h"
#import "VisionModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface AlbumPhotoEvaluator : NSObject <Evaluator>

@property (readonly) NSDictionary *results;

@property (readonly) id<VisionModel> model;
@property (readonly) PHAsset *photo;
@property (readonly) PHAssetCollection *album;
@property (readonly) PHCachingImageManager *imageManager;

- (instancetype)initWithModel:(id<VisionModel>)model photo:(PHAsset*)photo album:(PHAssetCollection*)album cachingManager:(PHCachingImageManager*)imageManager;

- (void)evaluateWithCompletionHandler:(nullable EvaluatorCompletionBlock)completionHandler;

@end

NS_ASSUME_NONNULL_END
