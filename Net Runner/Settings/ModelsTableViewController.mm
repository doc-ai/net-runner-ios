//
//  ModelsTableViewController.
//  Net Runner
//
//  Created by Philip Dow on 7/16/18.
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

#import "ModelsTableViewController.h"

#import "ModelDetailsTableViewController.h"

@import TensorIO;

@implementation ModelsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ( [segue.identifier isEqualToString:@"ModelDetailsSegue"] ) {
        ModelDetailsTableViewController *destination = (ModelDetailsTableViewController*)segue.destinationViewController;
        destination.bundle = TIOModelBundleManager.sharedManager.modelBundles[((NSIndexPath*)sender).row];
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
        return @"TensorFlow Lite Models";
    default:
        return @"";
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ModelCell" forIndexPath:indexPath];
    TIOModelBundle *bundle = [TIOModelBundleManager.sharedManager.modelBundles objectAtIndex:indexPath.row];
    
    cell.textLabel.text = bundle.name;
    cell.accessoryType = UITableViewCellAccessoryDetailButton;
    
    cell.textLabel.font = self.selectedBundle == bundle
        ? [UIFont boldSystemFontOfSize:[UIFont systemFontSize]]
        : [UIFont systemFontOfSize:[UIFont systemFontSize]];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self deselectModelRowsExceptRowAtIndexPath:indexPath];
    
    [tableView cellForRowAtIndexPath:indexPath].textLabel.font = [UIFont boldSystemFontOfSize:[UIFont systemFontSize]];
    self.selectedBundle = [TIOModelBundleManager.sharedManager.modelBundles objectAtIndex:indexPath.row];
    
    [self.delegate modelTableViewController:self didSelectBundle:self.selectedBundle];
}

- (void)deselectModelRowsExceptRowAtIndexPath:(NSIndexPath *)indexPath {
    const NSInteger modelSection = 0;
    
    for (NSInteger row = 0; row < [self.tableView numberOfRowsInSection:modelSection]; row++) {
        if (row == indexPath.row) {
            continue;
        }
        NSIndexPath *path = [NSIndexPath indexPathForRow:row inSection:modelSection];
        [self.tableView cellForRowAtIndexPath:path].textLabel.font = [UIFont systemFontOfSize:[UIFont systemFontSize]];
    }
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"ModelDetailsSegue" sender:indexPath];
}

@end
