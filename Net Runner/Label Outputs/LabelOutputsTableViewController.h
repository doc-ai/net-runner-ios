//
//  LabelOutputsTableViewController.h
//  Net Runner
//
//  Created by Philip Dow on 12/17/18.
//  Copyright © 2018 doc.ai. All rights reserved.
//

@import UIKit;
@import Photos;

NS_ASSUME_NONNULL_BEGIN

@class TIOModelBundle;

@interface LabelOutputsTableViewController : UITableViewController

@property (weak) IBOutlet UIImageView *imageView;

@property (nonatomic) PHCachingImageManager *imageManager;
@property (nonatomic) PHAsset *asset;

@property TIOModelBundle *modelBundle;

- (IBAction)cancel:(id)sender;
- (IBAction)save:(id)sender;

@end

NS_ASSUME_NONNULL_END
