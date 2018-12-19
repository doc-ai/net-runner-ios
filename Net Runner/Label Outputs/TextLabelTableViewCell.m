//
//  TextLabelTableViewCell.m
//  Net Runner
//
//  Created by Philip Dow on 12/18/18.
//  Copyright © 2018 doc.ai. All rights reserved.
//

#import "TextLabelTableViewCell.h"

static NSString * const TextLabelPlaceholder = @"Enter text label";

@interface TextLabelTableViewCell() <UITableViewDataSource, UITableViewDelegate>

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

- (void)setTextValue:(NSString *)textValue {
    _textValue = textValue;
    
    if ( textValue == nil || textValue.length == 0 ) {
        [self setPlaceholderVisible:YES];
    } else {
        [self setPlaceholderVisible:NO];
    }
}

- (void)setPlaceholderVisible:(BOOL)visible {
    if ( visible ) {
        self.textView.text = TextLabelPlaceholder;
        self.textView.textColor = [UIColor lightGrayColor];
    } else {
        self.textView.text = @"";
        self.textView.textColor = [UIColor blackColor];
    }
}

- (void)setLabels:(NSArray<NSString *> *)labels {
    _labels = labels;
    _filteredLabels = labels;
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

- (void)textViewDidEndEditing:(UITextView *)textView {
    if ( [textView.text isEqualToString:@""] ) {
        [self setPlaceholderVisible:YES];
    }
}

// Managing the return key

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ( [text isEqualToString:@"\n"] ) {
        [textView resignFirstResponder];
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
        _filteredLabels = self.labels;
    } else {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF BEGINSWITH[cd] %@", text];
        _filteredLabels = [self.labels filteredArrayUsingPredicate:predicate];
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

@end
