//
//  EvaluateResultsModelTableViewCell.h
//  Net Runner
//
//  Created by Philip Dow on 7/18/18.
//  Copyright © 2018 doc.ai. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    EvaluateResultsStateShowProgress,
    EvaluateResultsStateShowResults
} EvaluateResultsModelTableViewCellState;

@interface EvaluateResultsModelTableViewCell : UITableViewCell

@property (weak) IBOutlet UILabel *titleLabel;
@property (weak) IBOutlet UIProgressView *progressView;
@property (weak) IBOutlet UILabel *latencyTitleLabel;
@property (weak) IBOutlet UILabel *latencyValueLabel;

@property (nonatomic) EvaluateResultsModelTableViewCellState resultsState;

@end

NS_ASSUME_NONNULL_END
