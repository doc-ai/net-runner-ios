//
//  EvaluateResultsModelTableViewCell.m
//  tflite_camera_example
//
//  Created by Philip Dow on 7/18/18.
//  Copyright © 2018 doc.ai. All rights reserved.
//

#import "EvaluateResultsModelTableViewCell.h"

@implementation EvaluateResultsModelTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setResultsState:(EvaluateResultsModelTableViewCellState)resultsState {
    switch (resultsState) {
    case EvaluateResultsStateShowProgress:
        self.progressView.hidden = NO;
        self.latencyTitleLabel.hidden = YES;
        self.latencyValueLabel.hidden = YES;
        break;
    case EvaluateResultsStateShowResults:
        self.progressView.hidden = YES;
        self.latencyTitleLabel.hidden = NO;
        self.latencyValueLabel.hidden = NO;
        break;
    }
}

@end
