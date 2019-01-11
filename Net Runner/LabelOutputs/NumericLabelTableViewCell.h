//
//  NumericLabelTableViewCell.h
//  Net Runner
//
//  Created by Philip Dow on 12/18/18.
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

@import UIKit;

#import "LabelOutputTableViewCell.h"

NS_ASSUME_NONNULL_BEGIN

@class ImageModelLabels;

@interface NumericLabelTableViewCell : UITableViewCell <LabelOutputTableViewCell, UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UILabel *countLabel;

@property (weak) id<LabelOutputTableViewCellDelegate> delegate;
@property UIReturnKeyType returnKeyType;

/**
 * The number of numeric values this cell expects the user to input.
 */

@property (nonatomic) NSUInteger numberOfExpectedValues;

/**
 * Set the output labels object and key (layer name) which this cell is managing.
 *
 * The cell and not the table view is responsible for displaying its content from this object
 * and writing changes to its content back to this object.
 */

- (void)setLabels:(ImageModelLabels*)labels key:(NSString*)key;

@end

NS_ASSUME_NONNULL_END
