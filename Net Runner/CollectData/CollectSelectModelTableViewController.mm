//
//  CollectSelectModelTableViewController.m
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

#import "CollectSelectModelTableViewController.h"

#import "ModelDetailsTableViewController.h"
#import "EvaluateSelectAlbumsTableViewController.h"
#import "EvaluateModelTableViewCell.h"

@import TensorIO;

static NSString * const kModelCellIdentifier = @"ModelCell";

@interface CollectSelectModelTableViewController ()

@end

@implementation CollectSelectModelTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

// TODO: revisit how "data" payload is passed across controllers
// ^^^^: This may involve a refactoring of the Evaluate and Collect code to make it simpler to share across them.

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ( [segue.identifier isEqualToString:@"ModelDetailsSegue"] ) {
        ModelDetailsTableViewController *destination = (ModelDetailsTableViewController*)segue.destinationViewController;
        destination.bundle = TIOModelBundleManager.sharedManager.modelBundles[((NSIndexPath*)sender).row];
        destination.actions = (ModelDetailsActionClearLabels|ModelDetailsActionShareLabels);
    
    } else if ( [segue.identifier isEqualToString:@"SelectAlbumsSegue"] ) {
        EvaluateSelectAlbumsTableViewController *destination = (EvaluateSelectAlbumsTableViewController*)segue.destinationViewController;
        TIOModelBundle *bundle = TIOModelBundleManager.sharedManager.modelBundles[self.tableView.indexPathForSelectedRow.row];
        
        destination.data = @{
            @"bundles": @[bundle]
        };
    }
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
    cell.accessoryType = UITableViewCellAccessoryDetailButton;
    
    cell.bundle = bundle;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"ModelDetailsSegue" sender:indexPath];
}

@end
