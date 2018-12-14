//
//  ModelDetailsTableViewController.m
//  Net Runner
//
//  Created by Philip Dow on 7/10/18.
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

#import "ModelDetailsTableViewController.h"

#import "ModelDetailsJSONViewController.h"
#import "ModelManager.h"

@import TensorIO;

@interface ModelDetailsTableViewController ()

@end

@implementation ModelDetailsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    // Disallow deletion if we are not editable or the bundle is included by default
    
    if ( !self.editable || [ModelManager.sharedManager.defaultModelIDs containsObject:self.bundle.identifier] ) {
        self.tableView.tableFooterView.hidden = YES;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    self.title = self.bundle.name;
    self.nameLabel.text = self.bundle.name;
    self.authorLabel.text = self.bundle.author;
    self.descriptionLabel.text = self.bundle.details;
    self.licenseLabel.text = self.bundle.license;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ( [segue.identifier isEqualToString:@"ModelDetailsJSONSegue"] ) {
        ModelDetailsJSONViewController *vc = (ModelDetailsJSONViewController*)segue.destinationViewController;
        vc.bundle = self.bundle;
    }
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
    case 0:
        return NSLocalizedString(@"Name", @"Model name section heading");
    case 1:
        return NSLocalizedString(@"Author", @"Model authors section heading");
    case 2:
        return NSLocalizedString(@"Description", @"Model description section heading");
    case 3:
        return NSLocalizedString(@"License", @"Model license section heading");
    case 4:
        return NSLocalizedString(@"More", @"Model more section heading");
    default:
        return @"";
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

// MARK: - Actions

- (IBAction)deleteModel:(id)sender {
    
    UIAlertController *alert = [UIAlertController
        alertControllerWithTitle:NSLocalizedString(@"Are you sure you want to delete this model?", @"Delete model alert title")
        message:NSLocalizedString(@"Deleting this model will remove it permanently. It will no longer be available to select for live inference or for bulk evaluation.", @"Delete model alert message")
        preferredStyle:UIAlertControllerStyleActionSheet];
    
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Delete Model", @"Delete model alert delete button") style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        
        NSError *error;
        
        if ( ![ModelManager.sharedManager deleteModel:self.bundle error:&error] ) {
            NSLog(@"There was a problem deleting the model with identifier %@, error: %@", self.bundle.identifier, error);
            
            UIAlertController *errorAlert = [UIAlertController
                alertControllerWithTitle:NSLocalizedString(@"There was a problem removing the model", @"Delete model error alert title")
                message:NSLocalizedString(@"Try restarting Net Runner and deleting the model again or re-installing Net Runner.", @"Delete model error alert message")
                preferredStyle:UIAlertControllerStyleAlert];
            
            [errorAlert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Dismiss", @"Dismiss alert title") style:UIAlertActionStyleDefault handler:nil]];
            
            [self presentViewController:errorAlert animated:YES completion:nil];
        
        } else {
            [self.delegate modelDetailsTableViewControllerDidDeleteModel:self];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.navigationController popViewControllerAnimated:YES];
            });
        }
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"Delete model alert canel button") style:UIAlertActionStyleCancel handler:nil]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

@end
