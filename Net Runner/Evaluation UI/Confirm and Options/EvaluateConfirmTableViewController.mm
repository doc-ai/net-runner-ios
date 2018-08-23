//
//  EvaluateConfirmTableViewController.m
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

#import "EvaluateConfirmTableViewController.h"

#import "EvaluateModelTableViewCell.h"
#import "EvaluatePhotoAlbumTableViewCell.h"
#import "EvaluateIterationsTableViewCell.h"
#import "EvaluateResultsTableViewController.h"
#import "UserDefaults.h"

@import TensorIO;

static NSString * const kAlbumCellIdentifier = @"AlbumCell";
static NSString * const kModelCellIdentifier = @"ModelCell";

@interface EvaluateConfirmTableViewController () <EvaluateIterationsTableViewCellActionTarget>

@property NSArray<TIOModelBundle*> *bundles;
@property NSArray<PHAssetCollection*> *albums;
@property NSNumber *iterations;

@end

@implementation EvaluateConfirmTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.iterations = [NSUserDefaults.standardUserDefaults objectForKey:kPrefsEvaluateIterations];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ( [segue.identifier isEqualToString:@"EvaluateResultsSegue"] ) {
        EvaluateResultsTableViewController *destination = (EvaluateResultsTableViewController*)segue.destinationViewController;
        
        NSMutableDictionary *data = [self.data mutableCopy];
        data[@"iterations"] = self.iterations;
        
        destination.data = [data copy];
    }
}

- (void)setData:(NSDictionary *)data {
    _data = data;
    
    NSSortDescriptor *modelNameSort = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(caseInsensitiveCompare:)];
    
    NSSortDescriptor *albumTitleSort = [NSSortDescriptor sortDescriptorWithKey:@"localizedTitle" ascending:YES selector:@selector(caseInsensitiveCompare:)];
    
    self.bundles = [_data[@"bundles"] sortedArrayUsingDescriptors:@[modelNameSort]];
    self.albums = [_data[@"albums"] sortedArrayUsingDescriptors:@[albumTitleSort]];
    
    assert(self.bundles.count > 0);
    assert(self.albums.count > 0);
    
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
    case 0: return self.bundles.count;
    case 1: return self.albums.count;
    case 2: return 1;
    case 3: return 1;
    default: return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ( indexPath.section == 0 ) {
        // Models
        
        EvaluateModelTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kModelCellIdentifier forIndexPath:indexPath];
        
        TIOModelBundle *bundle = self.bundles[indexPath.row];
    
        cell.titleLabel.font = [UIFont systemFontOfSize:[UIFont systemFontSize]];

        cell.selectedSwitch.hidden = YES;
        cell.bundle = bundle;
        
        return cell;
    }
    else if ( indexPath.section == 1 ) {
        // Albums
        
        EvaluatePhotoAlbumTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kAlbumCellIdentifier forIndexPath:indexPath];
        
        PHAssetCollection *album = self.albums[indexPath.row];
    
        cell.titleLabel.font = [UIFont systemFontOfSize:[UIFont systemFontSize]];
        
        cell.selectedSwitch.hidden = YES;
        cell.album = album;
        
        return cell;
    }
    else if ( indexPath.section == 2 && indexPath.row == 0 ) {
        // Iterations
        
        EvaluateIterationsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"IterationsCell" forIndexPath:indexPath];
        cell.valueLabel.text = self.iterations.stringValue;
        cell.actionTarget = self;
        return cell;
    }
    else if ( indexPath.section == 3 ) {
        // Evaluate Button
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"EvaluateCell" forIndexPath:indexPath];
        return cell;
    }
    else {
        // Options
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DefaultCell" forIndexPath:indexPath];
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
    case 0: return 44;
    case 1: return 80;
    case 2: return 44;
    case 3: return 44;
    default: return 44;
    }
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
    case 0: return @"Models";
    case 1: return @"Albums";
    case 2: return @"Options";
    case 3: return nil;
    default: return nil;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if ( indexPath.section == 2 && indexPath.row == 0 ) {
        [[tableView cellForRowAtIndexPath:indexPath] becomeFirstResponder];
    }
}

// MARK: -

- (void)didChangeNumberOfIterations:(NSNumber*)iterations {
    [NSUserDefaults.standardUserDefaults setObject:iterations forKey:kPrefsEvaluateIterations];
    self.iterations = iterations;
}

@end
