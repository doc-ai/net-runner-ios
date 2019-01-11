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
#import "ImageModelLabelsDatabase.h"
#import "ImageModelLabelsExportActivityItemProvider.h"
#import "ModelManager.h"
#import "NRFileManager.h"

@import SVProgressHUD;
@import TensorIO;

@interface ModelDetailsTableViewController ()

@end

@implementation ModelDetailsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    [self updateAvailableActions];
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

- (void)updateAvailableActions {
    BOOL labelsDatabaseExists = [ImageModelLabelsDatabase databaseExistsForModel:self.bundle basepath:NRFileManager.sharedManager.labelDatabasesDirectory];
    
    // Disallow deletion if we are not editable or the bundle is included by default
    BOOL hideDeleteModel = (self.actions & ModelDetailsActionDeleteModel) == 0
                         || [ModelManager.sharedManager.defaultModelIDs containsObject:self.bundle.identifier];
    BOOL hideClearLabels = (self.actions & ModelDetailsActionClearLabels) == 0
                         || !labelsDatabaseExists;
    BOOL showShareLabels = (self.actions & ModelDetailsActionShareLabels) != 0
                         && labelsDatabaseExists;
    
    // Show or hide unavailable actions
    
    self.actionsStackView.arrangedSubviews[1].hidden = hideDeleteModel;
    self.actionsStackView.arrangedSubviews[0].hidden = hideClearLabels;
    
    // Add or remove the share navigation item
    
    if (showShareLabels) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(shareLabels:)];
    } else {
        self.navigationItem.rightBarButtonItem = nil;
    }
    
    // Adjust the size of the footer and show or hide it
    
    NSUInteger items = (NSUInteger)!hideDeleteModel + (NSUInteger)!hideClearLabels;
    CGFloat height = items * 44.0f;
    
    CGRect frame = self.tableView.tableFooterView.frame;
    frame.size.height = height;
    
    self.tableView.tableFooterView.frame = frame;
    self.tableView.tableFooterView = self.tableView.tableFooterView;
    self.tableView.tableFooterView.hidden = (items == 0);
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
        alertControllerWithTitle:NSLocalizedString(@"Delete Model?", @"Delete model alert title")
        message:NSLocalizedString(@"Deleting this model will remove it permanently. It will no longer be available for live inference or bulk evaluation, and any labels you have associated with it will be removed.", @"Delete model alert message")
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
            
            // Also clear the labels
            [ImageModelLabelsDatabase removeDatabaseForModel:self.bundle basepath:NRFileManager.sharedManager.labelDatabasesDirectory];
        
            [self.delegate modelDetailsTableViewControllerDidDeleteModel:self];
            
            [SVProgressHUD showSuccessWithStatus:@"Model deleted"];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.navigationController popViewControllerAnimated:YES];
            });
        }
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"Delete model alert canel button") style:UIAlertActionStyleCancel handler:nil]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (IBAction)clearLabelsDatabase:(id)sender {
    
    UIAlertController *alert = [UIAlertController
        alertControllerWithTitle:NSLocalizedString(@"Clear All Labels?", @"Clear labels alert title")
        message:NSLocalizedString(@"Clearing the labels for this model will remove any existing labels. They will no longer be visible in the labeling section, and you will no longer be able to export them.", @"Clear labels alert message")
        preferredStyle:UIAlertControllerStyleActionSheet];
    
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Clear Labels", @"Clear labels alert clear button") style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        
        [ImageModelLabelsDatabase removeDatabaseForModel:self.bundle basepath:NRFileManager.sharedManager.labelDatabasesDirectory];
        
        [SVProgressHUD showSuccessWithStatus:@"Labels cleared"];
        
        self.actions &= ~ModelDetailsActionClearLabels;
        self.actions &= ~ModelDetailsActionShareLabels;
        
        [self updateAvailableActions];
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"Clear labels alert alert canel button") style:UIAlertActionStyleCancel handler:nil]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (IBAction)shareLabels:(id)sender {
    ImageModelLabelsDatabase *database = [[ImageModelLabelsDatabase alloc] initWithModel:self.bundle.newModel basepath:NRFileManager.sharedManager.labelDatabasesDirectory];
    
    ImageModelLabelsExportActivityItemProvider *provider = [[ImageModelLabelsExportActivityItemProvider alloc] initWithDatabase:database identifier:self.bundle.identifier];
    
    UIActivityViewController *vc = [[UIActivityViewController alloc] initWithActivityItems:@[provider] applicationActivities:nil];
    
    [self presentViewController:vc animated:YES completion:nil];
}

@end
