//
//  PhotoAlbumPhotoCollectionViewCell.m
//  tflite_camera_example
//
//  Created by Philip Dow on 7/24/18.
//  Copyright © 2018 doc.ai. All rights reserved.
//

#import "PhotoAlbumPhotoCollectionViewCell.h"

@interface PhotoAlbumPhotoCollectionViewCell ()

@property PHImageRequestID currentRequest;
@property UIImageView *imageView;

@end

@implementation PhotoAlbumPhotoCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self sharedInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self sharedInit];
    }
    return self;
}

- (void)sharedInit {
    _imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    _imageView.contentMode = UIViewContentModeScaleAspectFill;
    _imageSize = CGSizeMake(64, 64);
    
    [self.contentView addSubview:_imageView];
}

- (void)layoutSubviews {
    self.imageView.frame = self.bounds;
}

- (void)setAsset:(PHAsset *)asset {
    _asset = asset;
    
    [self loadAsset];
}

- (void)loadAsset {
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    options.resizeMode = PHImageRequestOptionsResizeModeExact;

    [self.imageManager cancelImageRequest:self.currentRequest];

    self.currentRequest =
    [self.imageManager
        requestImageForAsset:self.asset
        targetSize:self.imageSize
        contentMode:PHImageContentModeAspectFill
        options:options
        resultHandler:^(UIImage *result, NSDictionary *info) {
    
        dispatch_async(dispatch_get_main_queue(), ^{
            self.imageView.image = result;
        });
    }];
}

- (void)prepareForReuse {
    [self.imageManager cancelImageRequest:self.currentRequest];
}

@end
