//
//  SettingsTableViewController.m
//  Net Runner
//
//  Created by Philip Dow on 7/10/18.
//  Copyright © 2018 doc.ai. All rights reserved.
//

#import "SettingsTableViewController.h"

#import "EvaluateSelectModelsTableViewController.h"
#import "ModelsTableViewController.h"
#import "ModelBundleManager.h"
#import "ModelBundle.h"
#import "Model.h"
#import "UserDefaults.h"

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

- (void)setSelectedBundle:(ModelBundle *)selectedBundle {
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

- (void) modelTableViewController:(ModelsTableViewController*)viewController didSelectBundle:(ModelBundle*)bundle {
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
