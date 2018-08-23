//
//  EvaluateResultsPhotoCollectionViewCell.m
//  Net Runner
//
//  Created by Philip Dow on 7/25/18.
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

#import "EvaluateResultsPhotoCollectionViewCell.h"
#import "EvaluatorConstants.h"
#import "ModelOutput.h"

@import TensorIO;

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
    
    id<ModelOutput> output = _evaluation[kEvaluatorResultsKeyEvaluation][kEvaluatorResultsKeyInferenceResults];
    NSString *description = output.localizedDescription;
    
    if ( description.length == 0 ) {
        _resultsLabel.text = @"None";
        return;
    }
    
    _resultsLabel.text = description;
}

@end
