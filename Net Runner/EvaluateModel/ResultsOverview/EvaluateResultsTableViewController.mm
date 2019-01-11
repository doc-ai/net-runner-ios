//
//  EvaluateResultsTableViewController.mm
//  Net Runner
//
//  Created by Philip Dow on 7/18/18.
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

#import "EvaluateResultsTableViewController.h"

#import "AlbumPhotoEvaluator.h"
#import "Evaluator.h"
#import "ImageEvaluator.h"
#import "EvaluateResultsModelTableViewCell.h"
#import "EvaluationResultsActivityItemProvider.h"
#import "EvaluateResultsByModelCollectionViewController.h"
#import "PHFetchResult+Extensions.h"
#import "EvaluatorConstants.h"

@import TensorIO;

static NSString * const kModelResultsCellIdentifier = @"ModelResultsCell";

@interface EvaluateResultsTableViewController ()

@property IBOutlet UILabel *modelsLabel;
@property IBOutlet UILabel *albumsLabel;
@property IBOutlet UILabel *photosLabel;
@property IBOutlet UILabel *iterationsLabel;

@property PHCachingImageManager *imageManager;
@property NSArray<TIOModelBundle*> *bundles;
@property NSArray<PHAssetCollection*> *albums;
@property NSNumber *iterations;

@end

@implementation EvaluateResultsTableViewController {
    dispatch_queue_t _evaluatorQueue;
    
    NSMutableDictionary *_progress;
    NSMutableDictionary *_results;
    NSMutableDictionary *_state;
    
    BOOL _cancelledEvaluation;
    BOOL _completedEvaluation;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _evaluatorQueue = dispatch_queue_create("evaluator_queue", NULL);
    _cancelledEvaluation = NO;
    _completedEvaluation = NO;
    
    // State initialization: keep track of progress, results, and cell state
    
    _progress = [[NSMutableDictionary alloc] init];
    _results = [[NSMutableDictionary alloc] init];
    _state = [[NSMutableDictionary alloc] init];
    
    for ( TIOModelBundle *bundle in self.bundles ) {
        // Do not initialize _results values to anything
        _state[bundle.identifier] = @(EvaluateResultsStateShowProgress);
        _progress[bundle.identifier] = @(0);
    }
    
    // Navigation items
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelEvaluation:)];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(shareEvaluation:)];
    
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    // Format title label
    
    NSNumber *numberOfPhotos =
        [[self.albums
        map:^id _Nonnull(PHAssetCollection * _Nonnull obj) {
            return @(obj.estimatedAssetCount);
        }]
        reduce:@(0) combine:^id _Nonnull(NSNumber *  _Nonnull accumulator, NSNumber * _Nonnull item) {
            return @(accumulator.integerValue + item.integerValue);
        }];
    
    NSString *modelsString = [NSString stringWithFormat:
        @"%tu %@",
        self.bundles.count,
        self.bundles.count == 1 ? @"model" : @"models"
    ];
    
    NSString *albumsString = [NSString stringWithFormat:
        @"%tu %@",
        self.albums.count,
        self.albums.count == 1 ? @"album" : @"albums"
    ];
    
    NSString *photosString = [NSString stringWithFormat:
        @"%tu %@",
        numberOfPhotos.integerValue,
        numberOfPhotos.integerValue == 1 ? @"photo" : @"photos"
    ];
    
    NSString *iterationsString = [NSString stringWithFormat:
        @"%tu %@",
        self.iterations.integerValue,
        self.iterations.integerValue == 1 ? @"iteration" : @"iterations"
    ];
    
    self.modelsLabel.text = modelsString;
    self.albumsLabel.text = albumsString;
    self.photosLabel.text = [NSString stringWithFormat:@"~%@", photosString];
    self.iterationsLabel.text = iterationsString;
    
    // Kick it off
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self evaluateAlbums];
    });
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ( [segue.identifier isEqualToString:@"ShowResultsForModel"] ) {
        EvaluateResultsByModelCollectionViewController *destination = (EvaluateResultsByModelCollectionViewController*)segue.destinationViewController;
        TIOModelBundle *modelBundle = self.bundles[[self.tableView.indexPathForSelectedRow row]];
        destination.results = _results[modelBundle.identifier];
        destination.imageManager = self.imageManager;
        destination.modelBundle = modelBundle;
    }
}

- (void)setData:(NSDictionary *)data {
    _data = data;
    
    NSSortDescriptor *modelNameSort = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(caseInsensitiveCompare:)];
    
    NSSortDescriptor *albumTitleSort = [NSSortDescriptor sortDescriptorWithKey:@"localizedTitle" ascending:YES selector:@selector(caseInsensitiveCompare:)];
    
    self.bundles = [_data[@"bundles"] sortedArrayUsingDescriptors:@[modelNameSort]];
    self.albums = [_data[@"albums"] sortedArrayUsingDescriptors:@[albumTitleSort]];
    
    self.imageManager = _data[@"image-manager"];
    self.iterations = _data[@"iterations"];
    
    assert(self.imageManager != nil);
    assert(self.bundles.count > 0);
    assert(self.albums.count > 0);
    assert(self.iterations.integerValue > 0);
}

// MARK: - Evaluation

- (NSArray<PHAsset*>*)assetsForCollection:(PHAssetCollection*)collection {
    NSPredicate *fetchPredicate = [NSPredicate predicateWithFormat:@"(mediaType = %d)", PHAssetMediaTypeImage ];
    NSArray<NSSortDescriptor*> *sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
    
    PHFetchOptions *fetchOptions = [[PHFetchOptions alloc] init];
    fetchOptions.sortDescriptors = sortDescriptors;
    fetchOptions.predicate = fetchPredicate;
    fetchOptions.includeAllBurstAssets = NO;
    fetchOptions.includeHiddenAssets = NO;
    
    PHFetchResult *fetchResult = [PHAsset fetchAssetsInAssetCollection:collection options:fetchOptions];
    return fetchResult.allAssets;
}

// Future optimization might run each model on its own operation queue
// See HeadlessTestBundleRunner

- (void)evaluateAlbums {
    dispatch_async(_evaluatorQueue, ^{
    
        // For each model, album, asset, iteration: build an evaluator
    
        NSMutableArray<AlbumPhotoEvaluator*> *evaluators = [[NSMutableArray<AlbumPhotoEvaluator*> alloc] init];
        NSUInteger numberOfPhotos = 0;
        NSUInteger numberOfModels = 0;
    
        for ( TIOModelBundle *modelBundle in self.bundles ) {
        
            id<TIOModel> model = [modelBundle newModel];
            
            if ( model == nil ) {
                NSLog(@"Unable to instantiate model from model bundle: %@", modelBundle.identifier);
                continue;
            }
            
            numberOfModels++;
            
            for ( PHAssetCollection *album in self.albums ) {
                NSArray<PHAsset*> *assets = [self assetsForCollection:album];
                for ( PHAsset *photo in assets ) {
                    for ( NSUInteger iter = 0; iter < self.iterations.integerValue; iter++ ) {
                        AlbumPhotoEvaluator *evaluator = [[AlbumPhotoEvaluator alloc]
                            initWithModel:model
                            photo:photo
                            album:album
                            imageManager:self.imageManager];
                        
                        [evaluators addObject:evaluator];
                        numberOfPhotos++;
                    }
                }
            }
        }
        
        numberOfPhotos = numberOfPhotos / numberOfModels;
        
        // Execute the evaluators and collect the results
        
        NSMutableArray<NSDictionary*> *results = [[NSMutableArray<NSDictionary*> alloc] init];
        
        for ( id<Evaluator> evaluator in evaluators ) {
            
            if ( self->_cancelledEvaluation ) {
                break;
            }
            
            @autoreleasepool {
                [evaluator evaluateWithCompletionHandler:^(NSDictionary * _Nonnull result, CVPixelBufferRef _Nullable inputPixelBuffer) {
                    id<TIOModel> model = evaluator.model;
                    NSString *modelID = result[kEvaluatorResultsKeyModel];
                    NSUInteger completedCount = [self->_progress[modelID] integerValue] + 1;
                    
                    self->_progress[modelID] = @(completedCount);
                    [results addObject:result];
                    
                    if ( completedCount != numberOfPhotos ) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self updateProgressForBundle:model.bundle completed:completedCount totalCount:numberOfPhotos];
                        });
                    } else {
                        NSArray *modelResults =
                            [results
                            filter:^BOOL(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                                return [obj[kEvaluatorResultsKeyModel] isEqualToString:model.identifier];
                            }];
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self completedEvaluation:modelResults forBundle:model.bundle];
                        });
                    }
                    
                }];
            } // autorelease pool
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self->_completedEvaluation = YES;
            [self completedEvaluation];
        });
        
    }); // dispatch
}

- (void)updateProgressForBundle:(TIOModelBundle*)bundle completed:(NSUInteger)completed totalCount:(NSUInteger)totalCount {
    NSUInteger index = [self.bundles indexOfObject:bundle];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    
    EvaluateResultsModelTableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    
    if ( cell == nil ) {
        return;
    }
    
    [cell.progressView setProgress:(float)completed/(float)totalCount animated:YES];
}

- (void)completedEvaluation:(NSArray<NSDictionary*>*)results forBundle:(TIOModelBundle*)bundle {
    _state[bundle.identifier] = @(EvaluateResultsStateShowResults);
    _results[bundle.identifier] = results;
    
    NSUInteger index = [self.bundles indexOfObject:bundle];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    
    EvaluateResultsModelTableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    
    if ( cell == nil ) {
        return;
    }
    
    cell.resultsState = EvaluateResultsStateShowResults;
    cell.latencyValueLabel.text = [NSString stringWithFormat:@"%.1lfms", [self averageLatencyForModel:bundle]];
}

- (void)completedEvaluation {
    self.navigationItem.rightBarButtonItem.enabled = YES;
    self.navigationItem.leftBarButtonItem = nil;
    
    for ( UITableViewCell *cell in self.tableView.visibleCells ) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.userInteractionEnabled = YES;
    }
}

- (double)averageLatencyForModel:(TIOModelBundle*)bundle {
    NSArray *results = _results[bundle.identifier];
    
    if ( results == nil || results.count == 0) {
        return 0;
    }
    
    NSArray<NSDictionary*> *goodResults =
        [results
        filter:^BOOL(NSDictionary * _Nonnull result, NSUInteger idx, BOOL * _Nonnull stop) {
            return ![result[kEvaluatorResultsKeyError] boolValue];
        }];
    
    NSInteger goodCount = goodResults.count;
    
    double totalLatency =
        [[[goodResults
        map:^id _Nonnull(NSDictionary * _Nonnull obj) {
            return obj[kEvaluatorResultsKeyEvaluation][kEvaluatorResultsKeyInferenceLatency];
        }]
        reduce:@((double)0.0) combine:^id _Nonnull(NSNumber * _Nonnull accumulator, NSNumber * _Nonnull item) {
            return @(accumulator.doubleValue + item.doubleValue);
        }]
        doubleValue
        ];
    
    return totalLatency / goodCount;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.bundles.count;
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"Results";
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 88.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    EvaluateResultsModelTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kModelResultsCellIdentifier forIndexPath:indexPath];
    TIOModelBundle *bundle = self.bundles[indexPath.row];
 
    cell.titleLabel.text = bundle.name;
    cell.progressView.progress = [_progress[bundle.identifier] integerValue];
    cell.latencyValueLabel.text = [NSString stringWithFormat:@"%.1lfms", [self averageLatencyForModel:bundle]];
    cell.resultsState = (EvaluateResultsModelTableViewCellState)[_state[bundle.identifier] integerValue];
    
    cell.accessoryType = _completedEvaluation
        ? UITableViewCellAccessoryDisclosureIndicator
        : UITableViewCellAccessoryNone;
    
    cell.userInteractionEnabled = _completedEvaluation;
 
    return cell;
}

// MARK: - User Actions

- (void)cancelEvaluation:(id)sender {
    
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Stop Evaluation" message:@"Stopping will immediately cancel evaluation and discard any results." preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *stopEvaluation = [UIAlertAction actionWithTitle:@"Stop Evaluation" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        self->_cancelledEvaluation = YES;
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self dismissViewControllerAnimated:YES completion:nil];
        });
    }];
    
    UIAlertAction *doNotStopEvaluation = [UIAlertAction actionWithTitle:@"Do Not Stop" style:UIAlertActionStyleCancel handler:nil];
    
    [alert addAction:stopEvaluation];
    [alert addAction:doNotStopEvaluation];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)doneEvaluation:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)shareEvaluation:(id)sender {

    // Convert results dictionary to array

    NSMutableArray<NSDictionary*> *results = [[NSMutableArray alloc] init];
    
    for ( NSString *model in _results ) {
        [results addObjectsFromArray:_results[model]];
    }
    
    NSDictionary *evaluation = @{
        @"results": results
    };
    
    EvaluationResultsActivityItemProvider *provider = [[EvaluationResultsActivityItemProvider alloc] initWithResults:evaluation];
    UIActivityViewController *vc = [[UIActivityViewController alloc] initWithActivityItems:@[provider] applicationActivities:nil];
    
    [self presentViewController:vc animated:YES completion:nil];
}

@end
