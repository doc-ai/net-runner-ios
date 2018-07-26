//
//  EvaluatePhotoAlbumTableViewCell.m
//  tflite_camera_example
//
//  Created by Philip Dow on 7/17/18.
//  Copyright © 2018 doc.ai. All rights reserved.
//

#import "EvaluatePhotoAlbumTableViewCell.h"

@interface EvaluatePhotoAlbumTableViewCell()

@property PHImageRequestID currentRequest;

@end

@implementation EvaluatePhotoAlbumTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self.selectedSwitch addTarget:self action:@selector(selectedSwitchAction:) forControlEvents:UIControlEventValueChanged];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)setAlbum:(PHAssetCollection *)album {
    if ( _album != album ) {
        [self displayAlbum:album];
    }

    _album = album;
}

- (void)displayAlbum:(PHAssetCollection *)album {
    self.titleLabel.text = album.localizedTitle;
    
    // Fetch first image for album preview
    
    PHFetchOptions *fetchOptions = [[PHFetchOptions alloc] init];
    fetchOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
    
    PHFetchResult *fetchResult = [PHAsset fetchKeyAssetsInAssetCollection:album options:fetchOptions];
    PHAsset *asset = [fetchResult firstObject];
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    options.resizeMode = PHImageRequestOptionsResizeModeExact;

    CGFloat scale = UIScreen.mainScreen.scale;
    CGFloat dimension = 64.0f;
    CGSize size = CGSizeMake(dimension*scale, dimension*scale);

    [[PHImageManager defaultManager] cancelImageRequest:self.currentRequest];

    self.currentRequest =
    [[PHImageManager defaultManager]
        requestImageForAsset:asset
        targetSize:size
        contentMode:PHImageContentModeAspectFill
        options:options
        resultHandler:^(UIImage *result, NSDictionary *info) {
    
        dispatch_async(dispatch_get_main_queue(), ^{
            self.albumImageView.image = result;
        });
    }];
}

- (IBAction)selectedSwitchAction:(UISwitch*)sender {
    [self.actionTarget didSwitchAlbum:self.album toSelected:sender.on];
}

@end
