//
//  PhotoAlbumPhotoViewController.m
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

#import "PhotoAlbumPhotoViewController.h"

@interface PhotoAlbumPhotoViewController ()

@end

@implementation PhotoAlbumPhotoViewController

+ (PHImageRequestOptions*)imageRequestOptions {
    static PHImageRequestOptions *options = nil;
    
    if ( options != nil ) {
        return options;
    }
    
    options = [[PHImageRequestOptions alloc] init];
    
    if ( @available(iOS 13.0, *) ) {
        options.resizeMode = PHImageRequestOptionsResizeModeNone;
        options.synchronous = NO;
    } else {
        options.resizeMode = PHImageRequestOptionsResizeModeExact;
        options.synchronous = YES;
    }
    
    options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    options.networkAccessAllowed = YES;
    
    return options;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGSize targetSize = PHImageManagerMaximumSize;
    PHImageContentMode contentMode = PHImageContentModeAspectFill;
    
    if ( @available(iOS 13.0, *) ) {
        targetSize = CGSizeMake(self.asset.pixelWidth, self.asset.pixelHeight);
        contentMode = PHImageContentModeDefault;
    }
    
    [self.activityIndicator startAnimating];
    
    [self.imageManager
        requestImageForAsset:self.asset
        targetSize:targetSize
        contentMode:contentMode
        options:[PhotoAlbumPhotoViewController imageRequestOptions]
        resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            
            [self.activityIndicator stopAnimating];
            
            if ( result == nil ) {
                NSLog(@"Unable to request image for asset %@", self.asset.localIdentifier);
                return;
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                self.imageView.image = result;
            });
        }];
}

@end
