//
//  SettingsTableViewController.m
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

#import "SettingsTableViewController.h"

#import "EvaluateSelectModelsTableViewController.h"
#import "ModelsTableViewController.h"
#import "UserDefaults.h"

@import TensorIO;

@interface SettingsTableViewController () <EvaluateSelectModelsTableViewControllerDelegate>

@end

@implementation SettingsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.rowHeight = 44;
    self.selectedModelNameLabel.text = self.selectedBundle.name;
    self.showInputBuffersSwitch.on = [NSUserDefaults.standardUserDefaults boolForKey:kPrefsShowInputBuffers];
    self.showInputBuffersAlphaSwitch.on = [NSUserDefaults.standardUserDefaults boolForKey:kPrefsShowInputBufferAlpha];
    self.evaluateModelsLabel.textColor = self.view.tintColor;
}

- (void)willMoveToParentViewController:(UIViewController *)parent {
    [super willMoveToParentViewController:parent];
    
    if ( parent == nil ) {
        [self.delegate settingsTableViewControllerWillDisappear:self];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ( [segue.identifier isEqualToString:@"ModelsSegue"] ) {
        ModelsTableViewController *destination = (ModelsTableViewController*)segue.destinationViewController;
        destination.selectedBundle = self.selectedBundle;
        destination.delegate = self;
    }
    else if ( [segue.identifier isEqualToString:@"EvaluateSegue"] ) {
        EvaluateSelectModelsTableViewController *destination = (EvaluateSelectModelsTableViewController*)((UINavigationController*)segue.destinationViewController).topViewController;
        destination.delegate = self;
    }
}

- (void)setSelectedBundle:(TIOModelBundle *)selectedBundle {
    _selectedBundle = selectedBundle;
    
    if (self.isViewLoaded) {
        self.selectedModelNameLabel.text = selectedBundle.name;
    }
}

//MARK: - Table view data source

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

// MARK: - Models Table View Controller Delegate

- (void) modelTableViewController:(ModelsTableViewController*)viewController didSelectBundle:(TIOModelBundle*)bundle {
    [NSUserDefaults.standardUserDefaults setObject:bundle.identifier forKey:kPrefsSelectedModelID];
    self.selectedBundle = bundle;
}

// MARK: - Evaluate Delegate

- (void)evaluateSelectModelsTableViewControllerDidCancel:(EvaluateSelectModelsTableViewController *)tableViewController {
    [self dismissViewControllerAnimated:YES completion:nil];
}

// MARK: -

- (IBAction)toggleShowInputBuffers {
    [NSUserDefaults.standardUserDefaults setBool:![NSUserDefaults.standardUserDefaults boolForKey:kPrefsShowInputBuffers] forKey:kPrefsShowInputBuffers];
}

- (IBAction)toggleShowInputBuffersAlpha:(id)sender {
    [NSUserDefaults.standardUserDefaults setBool:![NSUserDefaults.standardUserDefaults boolForKey:kPrefsShowInputBufferAlpha] forKey:kPrefsShowInputBufferAlpha];
}

@end
