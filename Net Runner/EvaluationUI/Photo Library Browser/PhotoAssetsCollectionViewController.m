//
//  PhotoAssetsCollectionViewController.m
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

#import "PhotoAssetsCollectionViewController.h"

#import "PhotoAlbumPhotoCollectionViewCell.h"
#import "PhotoAlbumPhotoViewController.h"
#import "PHFetchResult+Extensions.h"

static NSString * const AlbumPhotoReuseIdentifier = @"AlbumPhotoCell";

@interface PhotoAssetsCollectionViewController() <PHPhotoLibraryChangeObserver>

/**
 * Used to populate the collection view as well as track changes to the album.
 */

@property (nonatomic) PHFetchResult<PHAsset*> *fetchResult;

@end

@implementation PhotoAssetsCollectionViewController

+ (PHFetchOptions*)fetchOptions {
    PHFetchOptions *fetchOptions = [[PHFetchOptions alloc] init];
    
    fetchOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
    fetchOptions.includeAllBurstAssets = NO;
    fetchOptions.includeHiddenAssets = NO;
    
    return fetchOptions;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Calculate collection view item size for four to a row
    
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
   
    [self.imageManager startCachingImagesForAssets:self.fetchResult.allAssets targetSize:imageSize contentMode:contentMode options:options];
    
    // Monitor album changes
    
    [PHPhotoLibrary.sharedPhotoLibrary registerChangeObserver:self];
}

- (void)dealloc {
    [PHPhotoLibrary.sharedPhotoLibrary unregisterChangeObserver:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
     if ( [segue.identifier isEqualToString:@"ShowPhoto"] ) {
        PhotoAlbumPhotoViewController *destination = (PhotoAlbumPhotoViewController*)segue.destinationViewController;
        destination.imageManager = self.imageManager;
        destination.asset = [self.fetchResult objectAtIndex:[self.collectionView.indexPathsForSelectedItems[0] item]];
     }
}

- (void)setAlbum:(PHAssetCollection *)album {
    _album = album;
    
    self.fetchResult = [PHAsset fetchAssetsInAssetCollection:album options:PhotoAssetsCollectionViewController.fetchOptions];
    self.title = album.localizedTitle;
}

// MARK: - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.fetchResult.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PhotoAlbumPhotoCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:AlbumPhotoReuseIdentifier forIndexPath:indexPath];
    
    CGFloat imageDim = (UIScreen.mainScreen.bounds.size.width / 4) - 1;
    CGFloat scale = UIScreen.mainScreen.scale;
    
    cell.imageSize = CGSizeMake(imageDim*scale, imageDim*scale);
    
    cell.imageManager = self.imageManager;
    cell.asset = [self.fetchResult objectAtIndex:indexPath.item];
    
    return cell;
}

// MARK: - Photo Library Change Notification

- (void)photoLibraryDidChange:(PHChange *)changeInfo {
    dispatch_async(dispatch_get_main_queue(), ^{
        PHObjectChangeDetails *albumChanges = [changeInfo changeDetailsForObject:self.album];
        
        if ( albumChanges == nil ) {
            return;
        }
        
        PHFetchResultChangeDetails *fetchChanges = [changeInfo changeDetailsForFetchResult:self.fetchResult];
        
        if ( fetchChanges == nil ) {
            return;
        }
        
        self.fetchResult = fetchChanges.fetchResultAfterChanges;
        
        if ( !fetchChanges.hasIncrementalChanges ) {
            [self.collectionView reloadData];
            return;
        }
        
        [self.collectionView performBatchUpdates:^{
            NSIndexSet *removed = fetchChanges.removedIndexes;
            if (removed.count) {
                [self.collectionView deleteItemsAtIndexPaths:[self indexPathsFromIndexSet:removed]];
            }
            
            NSIndexSet *inserted = fetchChanges.insertedIndexes;
            if (inserted.count) {
                [self.collectionView insertItemsAtIndexPaths:[self indexPathsFromIndexSet:inserted]];
            }
            
            NSIndexSet *changed = fetchChanges.changedIndexes;
            if (changed.count) {
                [self.collectionView reloadItemsAtIndexPaths:[self indexPathsFromIndexSet:changed]];
            }
            
            if (fetchChanges.hasMoves) {
                [fetchChanges enumerateMovesWithBlock:^(NSUInteger fromIndex, NSUInteger toIndex) {
                    NSIndexPath *fromIndexPath = [NSIndexPath indexPathForItem:fromIndex inSection:0];
                    NSIndexPath *toIndexPath = [NSIndexPath indexPathForItem:toIndex inSection:0];
                    [self.collectionView moveItemAtIndexPath:fromIndexPath toIndexPath:toIndexPath];
                }];
            }
            
        } completion:nil];
    });
}

- (NSArray<NSIndexPath*>*)indexPathsFromIndexSet:(NSIndexSet*)indexSet {
    NSMutableArray *paths = [[NSMutableArray alloc] init];

    [indexSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
        [paths addObject:[NSIndexPath indexPathForItem:idx inSection:0]];
    }];
    
    return paths;
}

@end
