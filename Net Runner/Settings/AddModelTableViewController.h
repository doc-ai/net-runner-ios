//
//  AddModelTableViewController.h
//  Net Runner
//
//  Created by Philip Dow on 9/12/18.
//  Copyright © 2018 doc.ai. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AddModelTableViewController : UITableViewController <UITextFieldDelegate>

@property (weak) IBOutlet UITextField *URLField;
@property (weak) IBOutlet UIProgressView *downloadProgressView;
@property (weak) IBOutlet UILabel *downloadLabel;
@property (weak) IBOutlet UILabel *validatedLabel;
@property (weak) IBOutlet UILabel *savedLabel;
@property (weak) IBOutlet UILabel *completedLabel;

@end

NS_ASSUME_NONNULL_END
