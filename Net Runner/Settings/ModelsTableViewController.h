//
//  ModelsTableViewController.h
//  Net Runner
//
//  Created by Philip Dow on 7/16/18.
//  Copyright © 2018 doc.ai. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class ModelsTableViewController;
@class TIOModelBundle;
@protocol TIOModel;

@protocol ModelsTableViewControllerDelegate

- (void) modelTableViewController:(ModelsTableViewController*)viewController didSelectBundle:(TIOModelBundle*)bundle;

@end

// MARK: -

@interface ModelsTableViewController : UITableViewController

@property (weak) id<ModelsTableViewControllerDelegate> delegate;
@property TIOModelBundle *selectedBundle;

@end

NS_ASSUME_NONNULL_END
