//
//  LabelOutputTableViewCell.h
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

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol LabelOutputTableViewCell;

@protocol LabelOutputTableViewCellDelegate

- (void)labelOutputCellDidReturn:(UITableViewCell<LabelOutputTableViewCell>*)cell;

@end

NS_ASSUME_NONNULL_END

// MARK: -

NS_ASSUME_NONNULL_BEGIN

@protocol LabelOutputTableViewCell <NSObject>

@property (weak) id<LabelOutputTableViewCellDelegate> delegate;
@property UIReturnKeyType returnKeyType;

- (BOOL)becomeFirstResponder;

@end

NS_ASSUME_NONNULL_END
