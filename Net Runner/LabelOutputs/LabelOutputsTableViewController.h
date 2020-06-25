//
//  LabelOutputsTableViewController.h
//  Net Runner
//
//  Created by Philip Dow on 12/17/18.
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

// TODO: rename this, maybe specific for images?

@import UIKit;
@import Photos;

NS_ASSUME_NONNULL_BEGIN

@class TIOModelBundle;

@interface LabelOutputsTableViewController : UITableViewController

@property (weak) IBOutlet UIImageView *imageView;
@property (weak) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (nonatomic) PHCachingImageManager *imageManager;
@property (nonatomic) PHAsset *asset;

@property TIOModelBundle *modelBundle;

- (IBAction)clearLabels:(id)sender;
- (IBAction)cancel:(id)sender;
- (IBAction)save:(id)sender;

@end

NS_ASSUME_NONNULL_END
