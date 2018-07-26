//
//  EvaluateIterationsTableViewCell.h
//  tflite_camera_example
//
//  Created by Philip Dow on 7/18/18.
//  Copyright © 2018 doc.ai. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol EvaluateIterationsTableViewCellActionTarget <NSObject>

- (void)didChangeNumberOfIterations:(NSNumber*)iterations;

@end

@interface EvaluateIterationsTableViewCell : UITableViewCell <UIKeyInput>

@property (weak) IBOutlet UILabel *valueLabel;

@property (weak) id<EvaluateIterationsTableViewCellActionTarget> actionTarget;
@property (nonatomic) NSNumber *iterations;

// UIKeyInput

@property(nonatomic, readonly) BOOL hasText;

// UITextInputTraits

@property(nonatomic) UIKeyboardAppearance keyboardAppearance;
@property(nonatomic) UIKeyboardType keyboardType;
@property(nonatomic) UIReturnKeyType returnKeyType;

@end

NS_ASSUME_NONNULL_END
