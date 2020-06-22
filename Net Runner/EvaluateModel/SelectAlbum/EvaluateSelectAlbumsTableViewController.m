//
//  EvaluateSelectAlbumsTableViewController.m
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

#import "EvaluateSelectAlbumsTableViewController.h"

#import "EvaluateConfirmTableViewController.h"
#import "EvaluatePhotoAlbumTableViewCell.h"
#import "PhotoAssetsCollectionViewController.h"

// TODO: mixing the evaluating and labeling ui, refactor or change this somewhere
#import "LabelPhotoAssetsCollectionViewController.h"
#import "TIOModelBundle.h"

@import SVProgressHUD;

static NSString * const kAlbumCellIdentifier = @"AlbumCell";

@interface EvaluateSelectAlbumsTableViewController () <EvaluatePhotoAlbumTableViewCellActionTarget, PHPhotoLibraryChangeObserver>

@property PHFetchResult<PHAssetCollection *> *albums;
@property (nonatomic) NSSet<PHAssetCollection *> *selectedAlbums;
@property PHCachingImageManager *imageManager;

// Nullable because we are overloading this class to support album selection in labeling
@property (nullable, readonly) UIBarButtonItem *nextButton;

@end

// MARK: -

@implementation EvaluateSelectAlbumsTableViewController

- (void)dealloc {
    [PHPhotoLibrary.sharedPhotoLibrary unregisterChangeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.selectedAlbums = [[NSSet alloc] init];
    self.imageManager = [[PHCachingImageManager alloc] init];
    
    if ( PHPhotoLibrary.authorizationStatus != PHAuthorizationStatusAuthorized ) {
        [self requestPhotoLibraryAccess];
    } else {
        [self fetchAlbums];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ( [segue.identifier isEqualToString:@"EvaluateSegue"] ) {
        EvaluateConfirmTableViewController *destination = (EvaluateConfirmTableViewController*)segue.destinationViewController;
        
        destination.data = @{
            @"bundles": self.data[@"bundles"],
            @"albums": self.selectedAlbums.allObjects,
            @"image-manager": self.imageManager
        };
        
    } else if ( [segue.identifier isEqualToString:@"AlbumDetailsSegue"] ) {
        PhotoAssetsCollectionViewController *destination = (PhotoAssetsCollectionViewController*)segue.destinationViewController;
        PHAssetCollection *album = self.albums[[self.tableView.indexPathForSelectedRow row]];
        
        destination.imageManager = self.imageManager;
        destination.album = album;
        
    } else if ( [segue.identifier isEqualToString:@"LabelAlbumDetailsSegue"] ) {
        LabelPhotoAssetsCollectionViewController *destination = (LabelPhotoAssetsCollectionViewController*)segue.destinationViewController;
        PHAssetCollection *album = self.albums[[self.tableView.indexPathForSelectedRow row]];
        
        destination.imageManager = self.imageManager;
        destination.album = album;
        
        // Labeling specific: refactor?
        destination.modelBundle = self.data[@"bundles"][0];
    }
}

- (void)setSelectedAlbums:(NSSet<PHAssetCollection *> *)selectedAlbums {
    _selectedAlbums = selectedAlbums;
    
    self.nextButton.enabled = _selectedAlbums.count > 0;
}

- (UIBarButtonItem*)nextButton {
    // Next button has tag of 1001, add button has tag of 0
    return self.navigationItem.rightBarButtonItem.tag == 1001
        ? self.navigationItem.rightBarButtonItem
        : nil;
}

// MARK: - Fetching Albums

- (void)requestPhotoLibraryAccess {
    __weak typeof(self) weakself = self;
    
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            switch (status) {
            case PHAuthorizationStatusNotDetermined:
            case PHAuthorizationStatusRestricted:
            case PHAuthorizationStatusDenied:
                [PHPhotoLibrary.sharedPhotoLibrary registerChangeObserver:self];
                [weakself showPhotoLibraryUnauthorizedAlert];
                break;
            case PHAuthorizationStatusAuthorized:
                [weakself fetchAlbums];
                [weakself.tableView reloadData];
                break;
            }
        });
    }];
}

- (void)fetchAlbums {
    // Use PHAssetCollectionTypeSmartAlbum if we want to include smart albums later
    
    NSSortDescriptor *albumTitleSort = [NSSortDescriptor sortDescriptorWithKey:@"localizedTitle" ascending:YES selector:@selector(caseInsensitiveCompare:)];
    
    PHFetchOptions *fetchOptions = [[PHFetchOptions alloc] init];
    fetchOptions.sortDescriptors = @[albumTitleSort];
    fetchOptions.includeAllBurstAssets = NO;
    fetchOptions.includeHiddenAssets = NO;
    
    self.albums = [PHAssetCollection
        fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum
        subtype:PHAssetCollectionSubtypeAlbumRegular
        options:fetchOptions];
}

- (void)showPhotoLibraryUnauthorizedAlert {
    UIAlertController *alert = [UIAlertController
        alertControllerWithTitle:NSLocalizedString(@"Unable to access photo library", @"Photo library access unauthorized alert tite")
        message:NSLocalizedString(@"Please grant access to your photo library", @"Photo library access unauthorized alert message")
        preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addAction:[UIAlertAction
        actionWithTitle:NSLocalizedString(@"Dismiss", @"Photo library access unauthorized dismiss action")
        style:UIAlertActionStyleCancel
        handler:nil]];
    
    [alert addAction:[UIAlertAction
        actionWithTitle:NSLocalizedString(@"Grant Access", @"Photo library access unauthorized grant access action")
        style:UIAlertActionStyleDefault
        handler:^(UIAlertAction * _Nonnull action) {
            [UIApplication.sharedApplication openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:@{} completionHandler:nil];
        }]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)photoLibraryDidChange:(PHChange *)changeInfo {
    // Only interested in the first change after authorization status has been approved
    [PHPhotoLibrary.sharedPhotoLibrary unregisterChangeObserver:self];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self fetchAlbums];
    });
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.albums.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    EvaluatePhotoAlbumTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kAlbumCellIdentifier forIndexPath:indexPath];
    PHAssetCollection *album = [self.albums objectAtIndex:indexPath.row];
    
    cell.titleLabel.font = [UIFont systemFontOfSize:[UIFont systemFontSize]];
    
    cell.accessoryType = [self.selectedAlbums containsObject:album]
        ? UITableViewCellAccessoryCheckmark
        : UITableViewCellAccessoryNone;
    
    cell.actionTarget = self;
    cell.album = album;
    
    return cell;
}

// MARK: -

- (void)didSwitchAlbum:(PHAssetCollection*)album toSelected:(BOOL)selected {
    if ( [self.selectedAlbums containsObject:album] ) {
        [[self mutableSetValueForKey:@"selectedAlbums"] removeObject:album];
    } else {
        [[self mutableSetValueForKey:@"selectedAlbums"] addObject:album];
    }
}

// MARK: - User Actions

- (IBAction)createAlbum:(id)sender {
    // TODO: Refactor (this belongs to data labeling only)
    
    NSString *title = ((TIOModelBundle*)[self.data[@"bundles"] firstObject]).name;
    __block PHObjectPlaceholder *placeholder;
    
    [PHPhotoLibrary.sharedPhotoLibrary performChanges:^{
        PHAssetCollectionChangeRequest *create = [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:title];
        placeholder = create.placeholderForCreatedAssetCollection;
    
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        if (!success) {
            NSLog(@"There was a problem creating the photo album, error: %@", error);
            [SVProgressHUD showErrorWithStatus:@"Unable to Create Album"];
            return;
        }
        
        // TODO: Use PHPhotoLibraryChangeObserver to observe creation of album
        // This would also ensure newly created albums outside the app are immediately visible
        
        // PHFetchOptions *fetchOptions = [[PHFetchOptions alloc] init];
        // fetchOptions.includeAllBurstAssets = NO;
        // fetchOptions.includeHiddenAssets = NO;
        
        // PHFetchResult<PHAssetCollection*> *result = [PHAssetCollection fetchAssetCollectionsWithLocalIdentifiers:@[placeholder.localIdentifier] options:fetchOptions];
        // PHAssetCollection *collection = result.firstObject;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD showSuccessWithStatus:[NSString stringWithFormat:@"Created %@ Album", title]];
            [self fetchAlbums];
            [self.tableView reloadData];
        });
    }];
}

@end
