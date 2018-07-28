//
//  PhotoAlbumPhotoCollectionViewCell.h
//  tflite_camera_example
//
//  Created by Philip Dow on 7/24/18.
//  Copyright © 2018 doc.ai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

NS_ASSUME_NONNULL_BEGIN

@interface PhotoAlbumPhotoCollectionViewCell : UICollectionViewCell

// Protected

- (void)sharedInit;

/**
 * Set the desired imageSize before setting the asset
 */

@property (nonatomic) PHCachingImageManager *imageManager;
@property (nonatomic) CGSize imageSize;
@property (nonatomic) PHAsset *asset;

@end

NS_ASSUME_NONNULL_END
