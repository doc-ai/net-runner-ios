//
//  EvaluateResultsPhotoCollectionViewCell.m
//  tflite_camera_example
//
//  Created by Philip Dow on 7/25/18.
//  Copyright © 2018 doc.ai. All rights reserved.
//

#import "EvaluateResultsPhotoCollectionViewCell.h"
#import "NSArray+Extensions.h"

@interface EvaluateResultsPhotoCollectionViewCell()

@property UIView *resultsOverlay;
@property UILabel *resultsLabel;

@end

@implementation EvaluateResultsPhotoCollectionViewCell

- (void)sharedInit {
    [super sharedInit];
    
    // Overlay
    
    _resultsOverlay = [[UIView alloc] initWithFrame:CGRectZero];
    _resultsOverlay.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.5];
    _resultsOverlay.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.contentView addSubview:_resultsOverlay];
    
    [NSLayoutConstraint activateConstraints:@[
        [_resultsOverlay.leftAnchor constraintEqualToAnchor:self.leftAnchor constant:0],
        [_resultsOverlay.rightAnchor constraintEqualToAnchor:self.rightAnchor constant:0],
        [_resultsOverlay.bottomAnchor constraintEqualToAnchor:self.bottomAnchor constant:0],
        [_resultsOverlay.heightAnchor constraintGreaterThanOrEqualToConstant:48]
    ]];
    
    // Label
    
    _resultsLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _resultsLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _resultsLabel.font = [UIFont systemFontOfSize:13];
    _resultsLabel.textColor = UIColor.whiteColor;
    _resultsLabel.numberOfLines = 0;
    
    _resultsLabel.shadowColor = [UIColor colorWithWhite:0 alpha:0.8];
    _resultsLabel.shadowOffset = CGSizeMake(0, 1);
    
    [_resultsOverlay addSubview:_resultsLabel];
    
    [NSLayoutConstraint activateConstraints:@[
        [_resultsLabel.leftAnchor constraintEqualToAnchor:_resultsOverlay.leftAnchor constant:8],
        [_resultsLabel.rightAnchor constraintEqualToAnchor:_resultsOverlay.rightAnchor constant:-8],
        [_resultsLabel.topAnchor constraintEqualToAnchor:_resultsOverlay.topAnchor constant:8],
        [_resultsLabel.bottomAnchor constraintEqualToAnchor:_resultsOverlay.bottomAnchor constant:-8],
    ]];
}

- (void)setEvaluation:(NSDictionary *)evaluation {
    _evaluation = evaluation;
    
    NSDictionary *inference = _evaluation[@"evaluation"][@"inference_results"];
    
    if ( inference.count == 0 ) {
        _resultsLabel.text = @"None";
        return;
    }
    
    NSArray *keys = [inference keysSortedByValueUsingSelector:@selector(compare:)].reversed;
    NSMutableString *description = [NSMutableString string];
    
    for ( NSString *key in keys ) {
        NSNumber *value = inference[key];
        [description appendFormat:@"(%.2f) %@\n", value.floatValue, key];
    }
    
    [description deleteCharactersInRange:NSMakeRange(description.length-1, 1)];
    
    _resultsLabel.text = description;
}

@end
