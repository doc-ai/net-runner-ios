//
//  HeadlessViewController.h
//  Net Runner
//
//  Created by Philip Dow on 7/19/18.
//  Copyright © 2018 doc.ai. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HeadlessViewController : UIViewController

@property (weak) IBOutlet UILabel *statusLabel;
@property (weak) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak) IBOutlet UILabel *summaryLabel;
@property (weak) IBOutlet UILabel *resultsLabel;

@end

NS_ASSUME_NONNULL_END
