//
//  LabelOutputTableViewCell.h
//  Net Runner
//
//  Created by Philip Dow on 12/18/18.
//  Copyright © 2018 doc.ai. All rights reserved.
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
