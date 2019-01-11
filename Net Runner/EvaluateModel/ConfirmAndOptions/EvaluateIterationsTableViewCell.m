//
//  EvaluateIterationsTableViewCell.m
//  Net Runner
//
//  Created by Philip Dow on 7/18/18.
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

#import "EvaluateIterationsTableViewCell.h"

@interface EvaluateIterationsTableViewCell()

@property(nonatomic, readwrite, strong) __kindof UIView *inputAccessoryView;
@property UITextField *valueField;
@property UIButton *doneButton;

@end

@implementation EvaluateIterationsTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.keyboardAppearance = UIKeyboardAppearanceDefault;
    self.keyboardType = UIKeyboardTypeNumberPad;
    self.returnKeyType = UIReturnKeyDone;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

// MARK: - UIResponder

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (BOOL)becomeFirstResponder {
    [self setupAccessoryView];
    return [super becomeFirstResponder];
}

- (void)setupAccessoryView {
    if ( self.inputAccessoryView != nil ) {
        self.valueField.text = @"";
        [self.valueField insertText:self.valueLabel.text];
        return;
    }
    
    self.inputAccessoryView = [self createInputAccessoryView];
}

- (UIView*)createInputAccessoryView {
    
    // View
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 44)];
    view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin;
    view.backgroundColor = UIColor.whiteColor;
    
    UIView *separator = [[UIView alloc] initWithFrame:CGRectZero];
    separator.translatesAutoresizingMaskIntoConstraints = NO;
    separator.backgroundColor = [UIColor colorWithWhite:0.2 alpha:1];
    
    [view addSubview:separator];
    
    // Done Button

    UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [doneButton setTitle:NSLocalizedString(@"Done", @"Done button for keyboard input") forState:UIControlStateNormal];
    doneButton.titleLabel.font = [UIFont boldSystemFontOfSize:17];
    [doneButton addTarget:self action:@selector(didTapDoneButton:) forControlEvents:UIControlEventTouchUpInside];
    [doneButton setTitleColor:view.tintColor forState:UIControlStateNormal];
    [doneButton setTitleColor:[view.tintColor colorWithAlphaComponent:0.5] forState:UIControlStateDisabled];
    
    doneButton.translatesAutoresizingMaskIntoConstraints = NO;
    [view addSubview:doneButton];
    
    self.doneButton = doneButton;
    
    // Cancel Button
    
    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancelButton setTitle:NSLocalizedString(@"Cancel", @"Cancel button for keyboard input") forState:UIControlStateNormal];
    cancelButton.titleLabel.font = [UIFont boldSystemFontOfSize:17];
    [cancelButton addTarget:self action:@selector(didTapCancelButton:) forControlEvents:UIControlEventTouchUpInside];
    [cancelButton setTitleColor:[UIColor colorWithWhite:0.2 alpha:1] forState:UIControlStateNormal];
    
    cancelButton.translatesAutoresizingMaskIntoConstraints = NO;
    [view addSubview:cancelButton];
    
    // New Value Label
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = NSLocalizedString(@"New Value:", @"New number of iterations title label");
    titleLabel.font = [UIFont systemFontOfSize:17];
    titleLabel.textColor = UIColor.blackColor;

    titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [view addSubview:titleLabel];
    
    // New Value Input
    
    UITextField *valueField = [[UITextField alloc] init];
    valueField.userInteractionEnabled = NO;
    valueField.borderStyle = UITextBorderStyleRoundedRect;
    valueField.textColor = UIColor.blackColor;
    valueField.font = [UIFont systemFontOfSize:17];
    valueField.text = @"";
    [valueField insertText:self.valueLabel.text];
    
    valueField.translatesAutoresizingMaskIntoConstraints = NO;
    [view addSubview:valueField];
    
    self.valueField = valueField;
    
    // Layout
    
    [NSLayoutConstraint activateConstraints:@[
        [separator.topAnchor constraintEqualToAnchor:view.topAnchor constant:0],
        [separator.leftAnchor constraintEqualToAnchor:view.leftAnchor constant:0],
        [separator.rightAnchor constraintEqualToAnchor:view.rightAnchor constant:0],
        [separator.heightAnchor constraintEqualToConstant:1.0/UIScreen.mainScreen.scale],
        
        [titleLabel.leftAnchor constraintEqualToAnchor:view.leftAnchor constant:16],
        [titleLabel.centerYAnchor constraintEqualToAnchor:view.centerYAnchor constant:0],
        
        [valueField.leftAnchor constraintEqualToAnchor:titleLabel.rightAnchor constant:16],
        [valueField.centerYAnchor constraintEqualToAnchor:view.centerYAnchor constant:0],
        [valueField.widthAnchor constraintGreaterThanOrEqualToConstant:48],
        
        [doneButton.rightAnchor constraintEqualToAnchor:view.rightAnchor constant:-16],
        [doneButton.centerYAnchor constraintEqualToAnchor:view.centerYAnchor constant:0],
        
        [cancelButton.rightAnchor constraintEqualToAnchor:doneButton.leftAnchor constant:-24],
        [cancelButton.centerYAnchor constraintEqualToAnchor:view.centerYAnchor constant:0]
    ]];
    
    return view;
}

// MARK: - UIKeyInput

- (void)insertText:(NSString *)text {
    [self.valueField insertText:text];
    self.doneButton.enabled = self.valueField.text.length > 0;
}

- (void)deleteBackward {
    [self.valueField deleteBackward];
    self.doneButton.enabled = self.valueField.text.length > 0;
}

- (BOOL)hasText {
    return self.valueField.hasText;
}

// MARK: - Actions

- (void)didTapDoneButton:(id)sender {
    self.valueLabel.text = self.valueField.text;
    self.iterations = [NSNumber numberWithInteger:self.valueLabel.text.integerValue];
    [self.actionTarget didChangeNumberOfIterations:self.iterations];
    [self resignFirstResponder];
}

- (void)didTapCancelButton:(id)sender {
    [self resignFirstResponder];
}

@end
