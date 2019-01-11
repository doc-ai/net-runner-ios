//
//  EvaluateSelectModelsTableViewController.m
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

#import "EvaluateSelectModelsTableViewController.h"

#import "EvaluateModelTableViewCell.h"
#import "EvaluateSelectAlbumsTableViewController.h"
#import "ModelDetailsTableViewController.h"

@import TensorIO;

static NSString * const kModelCellIdentifier = @"ModelCell";

@interface EvaluateSelectModelsTableViewController () <EvaluateModelTableViewCellActionTarget>

@property (nonatomic) NSSet<TIOModelBundle*> *selectedBundles;
@property (readonly) UIBarButtonItem *nextButton;

@end

// MARK: -

@implementation EvaluateSelectModelsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.selectedBundles = [[NSSet<TIOModelBundle*> alloc] init];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ( [segue.identifier isEqualToString:@"ModelDetailsSegue"] ) {
        ModelDetailsTableViewController *destination = (ModelDetailsTableViewController*)segue.destinationViewController;
        destination.bundle = TIOModelBundleManager.sharedManager.modelBundles[self.tableView.indexPathForSelectedRow.row];
        destination.actions = ModelDetailsActionNone;
    }
    else if ( [segue.identifier isEqualToString:@"SelectAlbumsSegue"] ) {
        EvaluateSelectAlbumsTableViewController *destination = (EvaluateSelectAlbumsTableViewController*)segue.destinationViewController;
        destination.data = @{
            @"bundles": self.selectedBundles.allObjects
        };
    }
}

- (void)setSelectedBundles:(NSSet<TIOModelBundle *> *)selectedBundles {
    _selectedBundles = selectedBundles;
    
    self.nextButton.enabled = _selectedBundles.count > 0;
}

- (UIBarButtonItem*)nextButton {
    return self.navigationItem.rightBarButtonItem;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return TIOModelBundleManager.sharedManager.modelBundles.count;
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
    case 0:
        return @"Image Models";
    default:
        return @"";
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    EvaluateModelTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kModelCellIdentifier forIndexPath:indexPath];
    TIOModelBundle *bundle = TIOModelBundleManager.sharedManager.modelBundles[indexPath.row];
    
    cell.titleLabel.font = [UIFont systemFontOfSize:[UIFont systemFontSize]];
    cell.actionTarget = self;
    cell.bundle = bundle;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"ModelDetailsSegue" sender:indexPath];
}

// MARK: -

- (void)didSwitchBundle:(TIOModelBundle*)bundle toSelected:(BOOL)selected {
    if ( [self.selectedBundles containsObject:bundle] ) {
        [[self mutableSetValueForKey:@"selectedBundles"] removeObject:bundle];
    } else {
        [[self mutableSetValueForKey:@"selectedBundles"] addObject:bundle];
    }
}

@end
