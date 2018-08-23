//
//  EvaluateModelTableViewCell.m
//  Net Runner
//
//  Created by Philip Dow on 7/17/18.
//  Copyright © 2018 doc.ai (http://doc.ai)
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import "EvaluateModelTableViewCell.h"

@import TensorIO;

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

- (void)setBundle:(TIOModelBundle *)bundle {
    if ( _bundle != bundle ) {
        [self displayBundle:bundle];
    }
    
    _bundle = bundle;
}

- (void)displayBundle:(TIOModelBundle*)bundle {
    self.titleLabel.text = bundle.name;
}

@end
