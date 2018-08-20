//
//  ModelDetailsTableViewController.h
//  Net Runner
//
//  Created by Philip Dow on 7/10/18.
//  Copyright © 2018 doc.ai. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TIOModelBundle;
@protocol TIOModel;

NS_ASSUME_NONNULL_BEGIN

@interface ModelDetailsTableViewController : UITableViewController

@property TIOModelBundle *bundle;

@property (weak) IBOutlet UILabel *nameLabel;
@property (weak) IBOutlet UILabel *authorLabel;
@property (weak) IBOutlet UILabel *descriptionLabel;
@property (weak) IBOutlet UILabel *licenseLabel;

@end

NS_ASSUME_NONNULL_END
