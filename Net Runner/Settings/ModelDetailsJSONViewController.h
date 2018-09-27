//
//  ModelDetailsJSONViewController.h
//  Net Runner
//
//  Created by Phil Dow on 9/27/18.
//  Copyright © 2018 doc.ai. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TIOModelBundle;

NS_ASSUME_NONNULL_BEGIN

@interface ModelDetailsJSONViewController : UIViewController

@property (weak) IBOutlet UITextView *textView;
@property TIOModelBundle *bundle;

@end

NS_ASSUME_NONNULL_END
