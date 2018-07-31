//
//  EvaluateModelTableViewCell.m
//  Net Runner
//
//  Created by Philip Dow on 7/17/18.
//  Copyright © 2018 doc.ai. All rights reserved.
//

#import "EvaluateModelTableViewCell.h"

#import "ModelBundle.h"

@implementation EvaluateModelTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self.selectedSwitch addTarget:self action:@selector(selectedSwitchAction:) forControlEvents:UIControlEventValueChanged];
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (IBAction)selectedSwitchAction:(UISwitch*)sender {
    [self.actionTarget didSwitchBundle:self.bundle toSelected:sender.on];
}

- (void)setBundle:(ModelBundle *)bundle {
    if ( _bundle != bundle ) {
        [self displayBundle:bundle];
    }
    
    _bundle = bundle;
}

- (void)displayBundle:(ModelBundle*)bundle {
    self.titleLabel.text = bundle.name;
}

@end
