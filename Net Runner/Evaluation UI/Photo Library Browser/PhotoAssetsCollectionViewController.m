//
//  PhotoAssetsCollectionViewController.m
//  tflite_camera_example
//
//  Created by Philip Dow on 7/24/18.
//  Copyright © 2018 doc.ai. All rights reserved.
//

#import "PhotoAssetsCollectionViewController.h"

#import "PhotoAlbumPhotoCollectionViewCell.h"
#import "PhotoAlbumPhotoViewController.h"

@interface PhotoAssetsCollectionViewController ()

// @property PHFetchResult<PHAsset*> *fetchResult;

@end

@implementation PhotoAssetsCollectionViewController

static NSString * const kAlbumPhotoReuseIdentifier = @"AlbumPhotoCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    
    CGFloat imageDim = (UIScreen.mainScreen.bounds.size.width / 4) - 1;
    CGFloat scale = UIScreen.mainScreen.scale;
    
    CGSize itemSize = CGSizeMake(imageDim, imageDim);
    CGSize imageSize = CGSizeMake(imageDim*scale, imageDim*scale);
    
    ((UICollectionViewFlowLayout*)(self.collectionView.collectionViewLayout)).itemSize = itemSize;
    
    // Begin loading assets
    
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    options.resizeMode = PHImageRequestOptionsResizeModeExact;
    options.synchronous = YES;
    
    PHImageContentMode contentMode = PHImageContentModeDefault;
   
    [self.imageManager startCachingImagesForAssets:self.assets targetSize:imageSize contentMode:contentMode options:options];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
     if ( [segue.identifier isEqualToString:@"ShowPhoto"] ) {
        PhotoAlbumPhotoViewController *destination = (PhotoAlbumPhotoViewController*)segue.destinationViewController;
        destination.imageManager = self.imageManager;
        destination.asset = [self.assets objectAtIndex:[self.collectionView.indexPathsForSelectedItems[0] item]];
     }
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.assets.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PhotoAlbumPhotoCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kAlbumPhotoReuseIdentifier forIndexPath:indexPath];
    
    CGFloat imageDim = (UIScreen.mainScreen.bounds.size.width / 4) - 1;
    CGFloat scale = UIScreen.mainScreen.scale;
    
    cell.imageSize = CGSizeMake(imageDim*scale, imageDim*scale);
    
    cell.imageManager = self.imageManager;
    cell.asset = [self.assets objectAtIndex:indexPath.item];
    
    return cell;
}

@end
