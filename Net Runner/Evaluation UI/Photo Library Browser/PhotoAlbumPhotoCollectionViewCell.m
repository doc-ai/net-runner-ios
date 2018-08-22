//
//  PhotoAlbumPhotoCollectionViewCell.m
//  Net Runner
//
//  Created by Philip Dow on 7/24/18.
//  Copyright © 2018 doc.ai (http://doc.ai)
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
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
