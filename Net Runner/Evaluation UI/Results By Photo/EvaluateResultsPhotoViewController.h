//
//  EvaluateResultsPhotoViewController.h
//  Net Runner
//
//  Created by Philip Dow on 7/25/18.
//  Copyright © 2018 doc.ai. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "PhotoAlbumPhotoViewController.h"

NS_ASSUME_NONNULL_BEGIN

@class ImageInputPreviewView;
@class ResultInfoView;
@class ModelBundle;

@interface EvaluateResultsPhotoViewController : UIViewController

@property (weak) IBOutlet ImageInputPreviewView *imageInputPreviewView;
@property (weak) IBOutlet ResultInfoView *resultInfoView;
@property (weak) IBOutlet UIImageView *imageView;

@property ModelBundle *modelBundle;
@property NSDictionary *results;

@property (nonatomic) PHCachingImageManager *imageManager;
@property (nonatomic) PHAssetCollection *album;
@property (nonatomic) PHAsset *asset;

@end

NS_ASSUME_NONNULL_END
