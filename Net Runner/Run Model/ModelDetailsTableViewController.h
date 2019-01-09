//
//  ModelDetailsTableViewController.h
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

@import UIKit;

NS_ASSUME_NONNULL_BEGIN

typedef NS_OPTIONS(NSUInteger, SupportedModelDetailsActions) {
    ModelDetailsActionNone = 0,
    ModelDetailsActionDeleteModel = (1 << 0),
    ModelDetailsActionClearLabels = (1 << 1),
    ModelDetailsActionShareLabels = (1 << 2)
};

@class ModelDetailsTableViewController;
@class TIOModelBundle;
@protocol TIOModel;

@protocol ModelDetailsTableViewControllerDelegate

- (void)modelDetailsTableViewControllerDidDeleteModel:(ModelDetailsTableViewController*)viewController;

@end

// MARK: -

@interface ModelDetailsTableViewController : UITableViewController

@property (weak) id<ModelDetailsTableViewControllerDelegate> delegate;
@property TIOModelBundle *bundle;

@property SupportedModelDetailsActions actions;

@property (weak) IBOutlet UILabel *nameLabel;
@property (weak) IBOutlet UILabel *authorLabel;
@property (weak) IBOutlet UILabel *descriptionLabel;
@property (weak) IBOutlet UILabel *licenseLabel;
@property (weak) IBOutlet UIView *footerView;
@property (weak) IBOutlet UIStackView *actionsStackView;

- (IBAction)deleteModel:(id)sender;
- (IBAction)clearLabelsDatabase:(id)sender;

@end

NS_ASSUME_NONNULL_END
