//
//  EvaluateModelTableViewCell.h
//  tflite_camera_example
//
//  Created by Philip Dow on 7/17/18.
//  Copyright © 2018 doc.ai. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class ModelBundle;

@protocol EvaluateModelTableViewCellActionTarget <NSObject>

- (void)didSwitchBundle:(ModelBundle*)bundle toSelected:(BOOL)selected;

@end

// MARK: -

@interface EvaluateModelTableViewCell : UITableViewCell

@property (weak) IBOutlet UILabel *titleLabel;
@property (weak) IBOutlet UISwitch *selectedSwitch;

@property (weak) id<EvaluateModelTableViewCellActionTarget>actionTarget;
@property (nonatomic) ModelBundle *bundle;

- (IBAction)selectedSwitchAction:(UISwitch*)sender;

@end

NS_ASSUME_NONNULL_END
