//
//  TextLabelTableViewCell.h
//  Net Runner
//
//  Created by Philip Dow on 12/18/18.
//  Copyright © 2018 doc.ai. All rights reserved.
//

@import UIKit;

#import "LabelOutputTableViewCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface TextLabelTableViewCell : UITableViewCell <LabelOutputTableViewCell, UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UILabel *countLabel;

@property (weak) id<LabelOutputTableViewCellDelegate> delegate;
@property UIReturnKeyType returnKeyType;

@property (nullable, nonatomic) NSString *textValue;
@property (nullable, nonatomic) NSArray<NSString*> *labels;

@end

NS_ASSUME_NONNULL_END
