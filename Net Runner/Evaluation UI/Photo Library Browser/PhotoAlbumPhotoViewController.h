//
//  PhotoAlbumPhotoViewController.h
//  tflite_camera_example
//
//  Created by Philip Dow on 7/24/18.
//  Copyright © 2018 doc.ai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

NS_ASSUME_NONNULL_BEGIN

@interface PhotoAlbumPhotoViewController : UIViewController

@property (weak) IBOutlet UIImageView *imageView;

@property (nonatomic) PHCachingImageManager *imageManager;
@property (nonatomic) PHAsset *asset;

@end

NS_ASSUME_NONNULL_END
