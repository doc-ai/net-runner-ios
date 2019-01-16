//
//  EvaluatePhotoAlbumTableViewCell.m
//  Net Runner
//
//  Created by Philip Dow on 7/17/18.
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
    fetchOptions.includeAllBurstAssets = NO;
    fetchOptions.includeHiddenAssets = NO;
    
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
            self.albumImageView.image = (result == nil)
                ? [UIImage imageNamed:@"album-placeholder.png"]
                : result;
        });
    
    }];
}

- (IBAction)selectedSwitchAction:(UISwitch*)sender {
    [self.actionTarget didSwitchAlbum:self.album toSelected:sender.on];
}

@end
