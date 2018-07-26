//
//  ModelDetailsTableViewController.h
//  tflite_camera_example
//
//  Created by Philip Dow on 7/10/18.
//  Copyright © 2018 doc.ai. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ModelBundle;
@protocol Model;

NS_ASSUME_NONNULL_BEGIN

@interface ModelDetailsTableViewController : UITableViewController

@property ModelBundle *bundle;

@property (weak) IBOutlet UILabel *nameLabel;
@property (weak) IBOutlet UILabel *authorLabel;
@property (weak) IBOutlet UILabel *descriptionLabel;
@property (weak) IBOutlet UILabel *licenseLabel;

@end

NS_ASSUME_NONNULL_END
