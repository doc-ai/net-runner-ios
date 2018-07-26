//
//  EvaluateSelectModelsTableViewController.h
//  tflite_camera_example
//
//  Created by Philip Dow on 7/17/18.
//  Copyright © 2018 doc.ai. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class EvaluateSelectModelsTableViewController;

@protocol EvaluateSelectModelsTableViewControllerDelegate <NSObject>

- (void)evaluateSelectModelsTableViewControllerDidCancel:(EvaluateSelectModelsTableViewController*)tableViewController;

@end

// MARK: -

@interface EvaluateSelectModelsTableViewController : UITableViewController

@property (weak) id<EvaluateSelectModelsTableViewControllerDelegate> delegate;

- (IBAction)cancelEvaluation:(id)sender;

@end

NS_ASSUME_NONNULL_END
