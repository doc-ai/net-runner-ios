//
//  ResultInfoView.m
//  Net Runner
//
//  Created by Philip Dow on 7/26/18.
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

#import "ResultInfoView.h"

@interface ResultInfoView()

@property UIVisualEffectView *effectView;
@property UILabel *classificationLabel;
@property UILabel *statsLabel;

@end

@implementation ResultInfoView

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if ( self = [super initWithCoder:aDecoder] ) {
        [self sharedInit];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if ( self = [super initWithFrame:frame] ) {
        [self sharedInit];
    }
    return self;
}

- (void)sharedInit {
    _effectView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight]];
    _classificationLabel = [[UILabel alloc] init];
    _statsLabel = [[UILabel alloc] init];
    
    self.backgroundColor = UIColor.clearColor;
    
    self.layer.cornerRadius = 8;
    self.clipsToBounds = YES;
    
    _classificationLabel.font = [UIFont systemFontOfSize:15];
    _classificationLabel.textAlignment = NSTextAlignmentLeft;
    _classificationLabel.numberOfLines = 0;
    
    _statsLabel.font = [UIFont systemFontOfSize:15];
    _statsLabel.textAlignment = NSTextAlignmentRight;
    _statsLabel.numberOfLines = 0;
    
    _effectView.translatesAutoresizingMaskIntoConstraints = NO;
    _classificationLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _statsLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    [_classificationLabel setContentCompressionResistancePriority:1000 forAxis:UILayoutConstraintAxisVertical];
    [_classificationLabel setContentCompressionResistancePriority:1000 forAxis:UILayoutConstraintAxisHorizontal];
    [_statsLabel setContentCompressionResistancePriority:1000 forAxis:UILayoutConstraintAxisVertical];
    [_statsLabel setContentCompressionResistancePriority:1000 forAxis:UILayoutConstraintAxisHorizontal];
    
    [self addSubview:_effectView];
    [_effectView.contentView addSubview:_classificationLabel];
    [_effectView.contentView addSubview:_statsLabel];
    
    [NSLayoutConstraint activateConstraints:@[
        // Full Size
        [_effectView.topAnchor constraintEqualToAnchor:self.topAnchor constant:0],
        [_effectView.rightAnchor constraintEqualToAnchor:self.rightAnchor constant:0],
        [_effectView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor constant:0],
        [_effectView.leftAnchor constraintEqualToAnchor:self.leftAnchor constant:0],
        
        // Left Aligned
        [_classificationLabel.topAnchor constraintEqualToAnchor:_effectView.topAnchor constant:16],
        [_classificationLabel.leftAnchor constraintEqualToAnchor:_effectView.leftAnchor constant:16],
        [_classificationLabel.bottomAnchor constraintLessThanOrEqualToAnchor:_effectView.bottomAnchor constant:-16],
        
        // Right Aligned
        [_statsLabel.topAnchor constraintEqualToAnchor:_effectView.topAnchor constant:16],
        [_statsLabel.rightAnchor constraintEqualToAnchor:_effectView.rightAnchor constant:-16],
        [_statsLabel.bottomAnchor constraintLessThanOrEqualToAnchor:_effectView.bottomAnchor constant:-16],
    ]];
}

- (void)setClassifications:(NSString *)classifications {
    _classifications = classifications;
    
    self.classificationLabel.text = _classifications;
    [self setNeedsUpdateConstraints];
}

- (void)setStats:(NSString *)stats {
    _stats = stats;
    
    self.statsLabel.text = _stats;
    [self setNeedsUpdateConstraints];
}

@end
