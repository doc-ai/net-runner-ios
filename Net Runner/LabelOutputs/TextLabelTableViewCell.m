//
//  TextLabelTableViewCell.m
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

#import "TextLabelTableViewCell.h"
#import "ImageModelLabels.h"

static NSString * const TextLabelPlaceholder = @"Enter text label";
#define ErrorColor [UIColor colorWithRed:255./255. green:98./255. blue:86./255. alpha:1]

@interface TextLabelTableViewCell() <UITableViewDataSource, UITableViewDelegate>

@property (readwrite) BOOL hasError;
@property (readwrite) ImageModelLabels *labels;
@property (readwrite) NSString *key;

@end

@implementation TextLabelTableViewCell {
    // Label filtering
    NSArray<NSString*> *_filteredLabels;
    UITableView *_labelTableView;
    UIView *_inputAccessoryView;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.textView.textContainerInset = UIEdgeInsetsZero;
    self.textView.textContainer.lineFragmentPadding = 0;
    self.textView.inputAccessoryView = self.inputAccessoryView;
    
    [self setPlaceholderVisible:YES];
}

// Read the text label and display it, or display a placeholder

- (void)setLabels:(ImageModelLabels*)labels key:(NSString*)key {
    self.labels = labels;
    self.key = key;
    
    @try {
        NSString *text = [self.labels labelForKey:self.key];
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

- (void)setPlaceholderVisible:(BOOL)visible {
    if ( visible ) {
        self.textView.text = TextLabelPlaceholder;
        self.textView.textColor = [UIColor lightGrayColor];
    } else {
        self.textView.text = @"";
        self.textView.textColor = [self defaultTextViewColor];
    }
}

- (UIColor *)defaultTextViewColor {
    if ( @available(iOS 13.0, *) ) {
        if ( UITraitCollection.currentTraitCollection.userInterfaceStyle == UIUserInterfaceStyleDark ) {
            return [UIColor colorWithWhite:0.8 alpha:1.0];
        }
    }
    
    return [UIColor colorWithWhite:0.2 alpha:1.0];
}

- (void)setKnownLabels:(NSArray<NSString *> *)knownLabels {
    _knownLabels = knownLabels;
    _filteredLabels = knownLabels;
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
    
    [self updateSearchFilter:textView.text];
}

// Manages a fake placeholder for the text view

- (void)textViewDidBeginEditing:(UITextView *)textView {
    if ( [textView.text isEqualToString:TextLabelPlaceholder] ) {
        [self setPlaceholderVisible:NO];
    }
}

// Write to the labels object when the text view ends editing

- (void)textViewDidEndEditing:(UITextView *)textView {
    // The label must be set before the placeholder is returned
    @try {
        [self.labels setLabel:textView.text forKey:self.key];
    }
    @catch (NSException *exception) {
        [self showError:@"Unsupported label. Try clearing the labels first."];
        NSLog(@"An exception occurred trying to write the %@ key to labels, exception: %@",
            self.key, exception);
    }
    
    [self clearError];
    
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

// MARK: - Accessory View

- (UIView*)inputAccessoryView {
    if ( _inputAccessoryView == nil ) {
        
        // Table view
        
        _labelTableView = [[UITableView alloc] init];
        
        [_labelTableView registerClass:UITableViewCell.class forCellReuseIdentifier:@"LabelCell"];
        
        _labelTableView.translatesAutoresizingMaskIntoConstraints = NO;
        _labelTableView.dataSource = self;
        _labelTableView.delegate = self;
    
        // Input acessory view
    
        _inputAccessoryView = [[UIView alloc] init];
        
        _inputAccessoryView.backgroundColor = [UIColor colorWithWhite:0.75 alpha:1];
        _inputAccessoryView.translatesAutoresizingMaskIntoConstraints = NO;
        _inputAccessoryView.frame = CGRectMake(0, 0, CGRectGetWidth([[UIScreen mainScreen] bounds]), 44*3);
        
        // Embed table view
        
        [_inputAccessoryView addSubview:_labelTableView];
        
        [NSLayoutConstraint activateConstraints:@[
            [_labelTableView.topAnchor constraintEqualToAnchor:_inputAccessoryView.topAnchor constant:1],
            [_labelTableView.bottomAnchor constraintEqualToAnchor:_inputAccessoryView.bottomAnchor constant:0],
            [_labelTableView.leftAnchor constraintEqualToAnchor:_inputAccessoryView.leftAnchor constant:0],
            [_labelTableView.rightAnchor constraintEqualToAnchor:_inputAccessoryView.rightAnchor constant:0]
        ]];
    }
    
    return _inputAccessoryView;
}

- (void)updateSearchFilter:(NSString*)text {
    if ( text == nil || text.length == 0 ) {
        _filteredLabels = self.knownLabels;
    } else {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF BEGINSWITH[cd] %@", text];
        _filteredLabels = [self.knownLabels filteredArrayUsingPredicate:predicate];
    }
    
    [_labelTableView reloadData];
}

// MARK: - Accessory View Table Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _filteredLabels.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LabelCell"];
    
    cell.textLabel.text = _filteredLabels[indexPath.row];
    cell.textLabel.font = [UIFont systemFontOfSize:15.0];
    cell.separatorInset = UIEdgeInsetsZero;
    
    return cell;
}

// MARK: - Accessory View Table Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.textView.text = _filteredLabels[indexPath.row];
}

// MARK: - Error Handling

- (void)showError:(NSString*)errorDescription {
    self.hasError = YES;
    
    self.errorLabel.textColor = ErrorColor;
    self.errorLabel.text = errorDescription;
    self.errorLabel.hidden = NO;
    self.infoLabel.hidden = YES;
    
    [self.delegate labelOutputCellDidError:self error:errorDescription];
}

- (void)clearError {
    self.hasError = NO;
    
    self.errorLabel.text = nil;
    self.errorLabel.hidden = YES;
    self.infoLabel.hidden = NO;
    
    [self.delegate labelOutputCellDidClearError:self];
}

@end
