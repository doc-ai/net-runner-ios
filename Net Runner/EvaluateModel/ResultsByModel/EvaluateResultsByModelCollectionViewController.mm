//
//  EvaluateResultsByModelCollectionViewController.m
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

#import "EvaluateResultsByModelCollectionViewController.h"

#import "PhotoAlbumPhotoCollectionViewCell.h"
#import "EvaluateResultsPhotoCollectionViewCell.h"
#import "EvaluateResultsHeaderCollectionReusableView.h"
#import "EvaluateResultsPhotoViewController.h"
#import "PhotoAlbumPhotoViewController.h"
#import "PHFetchResult+Extensions.h"
#import "EvaluatorConstants.h"

@import TensorIO;

@interface EvaluateResultsByModelCollectionViewController ()

// album fetch results: used for sections
@property PHFetchResult<PHAssetCollection*> *albums;

// asset collection to assets in that collection: album to to photos: used for items in section
@property NSDictionary<PHAssetCollection*, PHFetchResult<PHAsset*>*> *photos;

// photo id to results for that photo
@property NSDictionary<NSString*, NSDictionary*> *evaluations;

// convenience array for pre-fetching assets
@property NSSet<PHAsset*> *allAssets;

@end

@implementation EvaluateResultsByModelCollectionViewController

static NSString * const kAlbumPhotoReuseIdentifier = @"AlbumPhotoCell";
static NSString * const kHeaderReuseIdentifier = @"HeaderView";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGFloat imageDim = (UIScreen.mainScreen.bounds.size.width / 2) - 1;
    CGFloat scale = UIScreen.mainScreen.scale;
    
    CGSize itemSize = CGSizeMake(imageDim, imageDim);
    CGSize imageSize = CGSizeMake(imageDim*scale, imageDim*scale);
    
    ((UICollectionViewFlowLayout*)(self.collectionView.collectionViewLayout)).itemSize = itemSize;
    
    // Begin loading assets
    
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    options.resizeMode = PHImageRequestOptionsResizeModeExact;
    options.synchronous = YES;
    
    PHImageContentMode contentMode = PHImageContentModeDefault;
   
    [self.imageManager startCachingImagesForAssets:self.allAssets.allObjects targetSize:imageSize contentMode:contentMode options:options];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ( [segue.identifier isEqualToString:@"ShowPhoto"] ) {
        EvaluateResultsPhotoViewController *destination = (EvaluateResultsPhotoViewController*)segue.destinationViewController;
        NSIndexPath *indexPath = self.collectionView.indexPathsForSelectedItems[0];
        PHAssetCollection *album = self.albums[indexPath.section];
        PHAsset *photo = self.photos[album][indexPath.row];
        
        destination.results = self.evaluations[photo.localIdentifier];
        destination.modelBundle = self.modelBundle;
        destination.imageManager = self.imageManager;
        destination.album = album;
        destination.asset = photo;
    }
}

/**
 * Group the results by album so that we can present them that way in the collection view.
 * Each grouping will have multiple entries for a single photo, specifically the number of iterations,
 * so group the entries by photo and map that array of array of photos to an array of photos.
 *
 * At this point we have locally unique identifiers for both the albums and the photos, so
 * map those to actual assets by way of a fetch.
 *
 * Also set up a convenienece mapping from photo id to evaluation which will be displayed by the cell.
 */

- (void)setResults:(NSArray *)results {
    _results = results;
    
    // Group by album and photo and map to unique photo id
    
    NSDictionary *byAlbum = [_results groupBy:kEvaluatorResultsKeyAlbum];
    NSMutableDictionary *byAlbumReduced = [[NSMutableDictionary alloc] init];
    
    for ( NSString *album in byAlbum ) {
        byAlbumReduced[album] = [[[byAlbum[album] groupBy:kEvaluatorResultsKeyImage] allValues]
            map:^id _Nonnull(NSArray * _Nonnull obj) {
                return obj.firstObject;
            }];
    }
    
    // Fetch collections and assets for album and photo ids
    
    NSMutableDictionary *photos = [NSMutableDictionary dictionary];
    NSMutableSet<PHAsset*> *allAssets = [NSMutableSet set];
    
    PHFetchResult<PHAssetCollection*> *albums = [PHAssetCollection fetchAssetCollectionsWithLocalIdentifiers:byAlbumReduced.allKeys options:nil];
    
    for ( PHAssetCollection *album in albums ) {
        NSArray *photoIds = [byAlbumReduced[album.localIdentifier] map:^id _Nonnull(NSDictionary *  _Nonnull obj) {
            return obj[kEvaluatorResultsKeyImage];
        }];
        PHFetchResult<PHAsset*> *fetch = [PHAsset fetchAssetsWithLocalIdentifiers:photoIds options:nil];;
        
        photos[album] = fetch;
        [allAssets addObjectsFromArray:fetch.allAssets];
    }
    
    // Map all photo ids to photo evalutions
    
    // Note that we are not aggregating latency or inference and are assuming that the same
    // photo across multiple albums has produced the same inference
    
    NSMutableDictionary<NSString*, NSDictionary*> *evaluations = [NSMutableDictionary dictionary];
    
    for ( NSString *album in byAlbumReduced ) {
        NSArray *photos = byAlbumReduced[album];
        for ( NSDictionary *photo in photos ) {
            evaluations[photo[kEvaluatorResultsKeyImage]] = photo;
        }
    }
    
    _evaluations = evaluations;
    _allAssets = allAssets;
    _albums = albums;
    _photos = photos;
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return self.albums.count;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.photos[[self.albums objectAtIndex:section]] count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    EvaluateResultsPhotoCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kAlbumPhotoReuseIdentifier forIndexPath:indexPath];
    PHAssetCollection *album = self.albums[indexPath.section];
    PHAsset *photo = self.photos[album][indexPath.item];
    
    CGFloat imageDim = (UIScreen.mainScreen.bounds.size.width / 2) - 1;
    CGFloat scale = UIScreen.mainScreen.scale;
    
    cell.imageSize = CGSizeMake(imageDim*scale, imageDim*scale);
    
    cell.imageManager = self.imageManager;
    cell.evaluation = self.evaluations[photo.localIdentifier];
    cell.asset = photo;
    
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    EvaluateResultsHeaderCollectionReusableView *view = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:kHeaderReuseIdentifier forIndexPath:indexPath];
    
    if ( indexPath.section == 0 ) {
        view.modelTitleLabel.text = self.modelBundle.name;
        view.modelTitleLabel.hidden = NO;
    } else {
        view.modelTitleLabel.hidden = YES;
    }
    
    view.albumTitleLabel.text = self.albums[indexPath.section].localizedTitle;
    
    return view;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    switch ( section ) {
    case 0: return CGSizeMake(collectionView.frame.size.width, 96);
    default: return CGSizeMake(collectionView.frame.size.width, 64);
    }
}

@end
