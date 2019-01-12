//
//  TextLabelTableViewCell.h
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

@interface TextLabelTableViewCell : UITableViewCell <LabelOutputTableViewCell, UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel;
@property (weak, nonatomic) IBOutlet UILabel *errorLabel;

@property (weak) id<LabelOutputTableViewCellDelegate> delegate;
@property UIReturnKeyType returnKeyType;

/**
 * The universe of known possible text labels for this output, e.g. the list of supported
 * image classifications.
 *
 * These will be shown in a table view below the cell, and as the user types they will be
 * filtered.
 */

@property (nullable, nonatomic) NSArray<NSString*> *knownLabels;

/**
 * Returns `YES` if the cell encountered an erorr oupdating the value, `NO` otherwise.
 */

@property (readonly) BOOL hasError;

/**
 * The set of labels being managed by the view this cell belongs to.
 */

@property (readonly) ImageModelLabels *labels;

/**
 * The key (name) for the label this cell is managing specifically.
 */

@property (readonly) NSString *key;

/**
 * Set the output labels object and key (layer name) which this cell is managing.
 *
 * The cell and not the table view is responsible for displaying its content from this object
 * and writing changes to its content back to this object.
 */

- (void)setLabels:(ImageModelLabels*)labels key:(NSString*)key;

@end

NS_ASSUME_NONNULL_END
