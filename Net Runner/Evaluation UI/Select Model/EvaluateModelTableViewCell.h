//
//  EvaluateModelTableViewCell.h
//  Net Runner
//
//  Created by Philip Dow on 7/17/18.
//  Copyright © 2018 doc.ai. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class TIOModelBundle;

@protocol EvaluateModelTableViewCellActionTarget <NSObject>

- (void)didSwitchBundle:(TIOModelBundle*)bundle toSelected:(BOOL)selected;

@end

// MARK: -

@interface EvaluateModelTableViewCell : UITableViewCell

@property (weak) IBOutlet UILabel *titleLabel;
@property (weak) IBOutlet UISwitch *selectedSwitch;

@property (weak) id<EvaluateModelTableViewCellActionTarget>actionTarget;
@property (nonatomic) TIOModelBundle *bundle;

- (IBAction)selectedSwitchAction:(UISwitch*)sender;

@end

NS_ASSUME_NONNULL_END
