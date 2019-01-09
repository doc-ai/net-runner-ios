//
//  NumericLabelTableViewCell.m
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

#import "NumericLabelTableViewCell.h"
#import "ImageModelLabels.h"

static NSString * const NumericLabelPlaceholder = @"Enter numeric values";

NSNumberFormatter * TextToNumberFormatter() {
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.numberStyle = NSNumberFormatterDecimalStyle;
    formatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US"];
    return formatter;
}

NSString * NumericVectorToText(NSArray<NSNumber*> * vector) {
    return [vector componentsJoinedByString:@", "];
}

NSArray<NSNumber*> * _Nullable TextToNumericVector(NSString * _Nullable text, NSNumberFormatter * formatter) {
    if (text == nil || text.length == 0) {
        return @[];
    }
    
    NSArray<NSString*> *stringVals = [text componentsSeparatedByString:@","];
    __block BOOL hasNaNs = NO;
    
    NSMutableArray<NSNumber*> *numVals = [[NSMutableArray alloc] init];
    
    for (NSString *str in stringVals) {
        NSString *stripped = [str stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceCharacterSet];
        NSNumber *number = [formatter numberFromString:stripped];
        if (number == nil) {
            number = [NSDecimalNumber notANumber];
            hasNaNs = YES;
        }
        [numVals addObject:number];
    }
    
    if (hasNaNs) {
        return nil;
    }
    
    return numVals.copy;
}

@interface NumericLabelTableViewCell()

@property ImageModelLabels *labels;
@property NSString *key;

@end

@implementation NumericLabelTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.textView.textContainerInset = UIEdgeInsetsZero;
    self.textView.textContainer.lineFragmentPadding = 0;
    
    [self setPlaceholderVisible:YES];
}

// Read the numeric vector label and display it, or display a placeholder

- (void)setLabels:(ImageModelLabels*)labels key:(NSString*)key {
    self.labels = labels;
    self.key = key;
    
    @try {
        NSArray<NSNumber*> *vector = [self.labels labelForKey:self.key];
        NSString *text = NumericVectorToText(vector);
        [self setValue:text];
    }
    @catch (NSException *exception) {
        NSLog(@"An exception occurred trying to read the %@ key from labels, exception: %@",
            self.key, exception);
    }
}

- (void)setValue:(NSString *)value {
    if ( value == nil || value.length == 0 ) {
        [self setPlaceholderVisible:YES];
    } else {
        [self setPlaceholderVisible:NO];
        self.textView.text = value;
    }
}

- (void)setNumberOfExpectedValues:(NSUInteger)numberOfExpectedValues {
    _numberOfExpectedValues = numberOfExpectedValues;
    
    self.countLabel.text = numberOfExpectedValues >= 2
        ? [NSString stringWithFormat:@"%ld comma separated numeric values", numberOfExpectedValues]
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

// Write to the labels object when the text view ends editing

- (void)textViewDidEndEditing:(UITextView *)textView {
    // The label must be set before the placeholder is returned
    NSArray<NSNumber*> *vector = TextToNumericVector(textView.text, TextToNumberFormatter());
    
    // TODO: error handling
    
    if (vector == nil) {
        // Error converting text to numbers
    } else {
        // All good
        @try {
            [self.labels setLabel:vector forKey:self.key];
        }
        @catch (NSException *exception) {
            NSLog(@"An exception occurred trying to write the %@ key to labels, exception: %@",
                self.key, exception);
        }
    }
    
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
