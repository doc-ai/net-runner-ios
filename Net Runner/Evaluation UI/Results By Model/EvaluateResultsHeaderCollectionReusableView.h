//
//  EvaluateResultsHeaderCollectionReusableView.h
//  Net Runner
//
//  Created by Philip Dow on 7/25/18.
//  Copyright © 2018 doc.ai. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface EvaluateResultsHeaderCollectionReusableView : UICollectionReusableView

@property (weak) IBOutlet UILabel *modelTitleLabel;
@property (weak) IBOutlet UILabel *albumTitleLabel;

@end

NS_ASSUME_NONNULL_END
