//
//  NumericLabelTableViewCell.h
//  Net Runner
//
//  Created by Philip Dow on 12/18/18.
//  Copyright © 2018 doc.ai. All rights reserved.
//

@import UIKit;

#import "LabelOutputTableViewCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface NumericLabelTableViewCell : UITableViewCell <LabelOutputTableViewCell, UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UILabel *countLabel;

@property (weak) id<LabelOutputTableViewCellDelegate> delegate;
@property UIReturnKeyType returnKeyType;

@property (nullable, nonatomic) NSArray *numericValues;
@property (nonatomic) NSUInteger numberOfExpectedValues;

@end

NS_ASSUME_NONNULL_END
