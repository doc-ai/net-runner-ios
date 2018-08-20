//
//  SettingsTableViewController.h
//  Net Runner
//
//  Created by Philip Dow on 7/10/18.
//  Copyright © 2018 doc.ai. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ModelsTableViewController.h"

NS_ASSUME_NONNULL_BEGIN

@class SettingsTableViewController;
@class TIOModelBundle;
@protocol Model;

@protocol SettingsTableViewControllerDelegate

- (void)settingsTableViewControllerWillDisappear:(SettingsTableViewController*)viewController;

@end

// MARK: -

@interface SettingsTableViewController : UITableViewController <ModelsTableViewControllerDelegate>

@property (weak) IBOutlet UISwitch *showInputBuffersSwitch;
@property (weak) IBOutlet UISwitch *showInputBuffersAlphaSwitch;
@property (weak) IBOutlet UILabel *selectedModelNameLabel;
@property (weak) IBOutlet UILabel *evaluateModelsLabel;

@property (weak) id<SettingsTableViewControllerDelegate> delegate;
@property (nonatomic) TIOModelBundle *selectedBundle;

- (IBAction)toggleShowInputBuffers;
- (IBAction)toggleShowInputBuffersAlpha:(id)sender;

@end

NS_ASSUME_NONNULL_END
