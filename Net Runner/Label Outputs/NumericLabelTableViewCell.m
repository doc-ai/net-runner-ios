//
//  NumericLabelTableViewCell.m
//  Net Runner
//
//  Created by Philip Dow on 12/18/18.
//  Copyright © 2018 doc.ai. All rights reserved.
//

#import "NumericLabelTableViewCell.h"

static NSString * const NumericLabelPlaceholder = @"Enter numeric values";

@implementation NumericLabelTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.textView.textContainerInset = UIEdgeInsetsZero;
    self.textView.textContainer.lineFragmentPadding = 0;
    
    [self setPlaceholderVisible:YES];
}

- (void)setNumericValues:(NSArray *)numericValues {
    _numericValues = numericValues;
    
    if ( numericValues == nil || numericValues.count == 0 ) {
        [self setPlaceholderVisible:YES];
    } else {
        [self setPlaceholderVisible:NO];
    }
}

- (void)setNumberOfExpectedValues:(NSUInteger)numberOfExpectedValues {
    _numberOfExpectedValues = numberOfExpectedValues;
    
    self.countLabel.text = numberOfExpectedValues >= 2
        ? [NSString stringWithFormat:@"%ld numeric values", numberOfExpectedValues]
        : [NSString stringWithFormat:@"%ld numeric value", numberOfExpectedValues];
}

- (void)setPlaceholderVisible:(BOOL)visible {
    if ( visible ) {
        self.textView.text = NumericLabelPlaceholder;
        self.textView.textColor = [UIColor lightGrayColor];
    } else {
        self.textView.text = @"";
        self.textView.textColor = [UIColor blackColor];
    }
}

// MARK - Label Output Table View Cell Protocol

- (UIReturnKeyType)returnKeyType {
    return self.textView.returnKeyType;
}

- (void)setReturnKeyType:(UIReturnKeyType)returnKeyType {
    self.textView.returnKeyType = returnKeyType;
}

- (BOOL)becomeFirstResponder {
    return [self.textView becomeFirstResponder];
}

// MARK: - UITextView Delegate

// Calls on autolayout to resize the table view cell when the text changes

- (void)textViewDidChange:(UITextView *)textView {
    CGSize size = textView.bounds.size;
    CGSize newSize = [textView sizeThatFits:CGSizeMake(size.width, CGFLOAT_MAX)];
    
    if ( size.height != newSize.height ) {
        [UIView setAnimationsEnabled:NO];
        [self.tableView beginUpdates];
        [self.tableView endUpdates];
        [UIView setAnimationsEnabled:YES];
    }
}

// Manages a fake placeholder for the text view

- (void)textViewDidBeginEditing:(UITextView *)textView {
    if ( [textView.text isEqualToString:NumericLabelPlaceholder] ) {
        [self setPlaceholderVisible:NO];
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    if ( [textView.text isEqualToString:@""] ) {
        [self setPlaceholderVisible:YES];
    }
}

// Managing the return key

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ( [text isEqualToString:@"\n"] ) {
        [textView resignFirstResponder];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.delegate labelOutputCellDidReturn:self];
        });
        
        return NO;
    }
    
    return YES;
}

@end
