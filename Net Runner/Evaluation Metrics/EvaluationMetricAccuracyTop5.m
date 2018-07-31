//
//  EvaluationMetricAccuracyTop5.m
//  Net Runner
//
//  Created by Philip Dow on 7/19/18.
//  Copyright © 2018 doc.ai. All rights reserved.
//

#import "EvaluationMetricAccuracyTop5.h"
#import "NSArray+Extensions.h"

@implementation EvaluationMetricAccuracyTop5

- (NSDictionary*)evaluate:(NSDictionary*)y yhat:(NSDictionary*)yhat {
    NSArray *output = [[[yhat keysSortedByValueUsingSelector:@selector(compare:)] reversed] firstN:5];
    NSString *label = y.allKeys.firstObject;
    
    if ( [output containsObject:label] ) {
        return @{
            @"accuracy": @(1)
         };
    } else {
        return @{
            @"accuracy": @(0)
         };
    }
    
    return 0;
}

- (NSDictionary*)reduce:(NSArray<NSDictionary*>*)metrics {
    NSNumber *total =
        [[metrics
        map:^id _Nonnull(NSDictionary * _Nonnull obj) {
            return obj[@"accuracy"];
        }]
        reduce:@(0) combine:^id _Nonnull(NSNumber * _Nonnull accumulator, NSNumber * _Nonnull item) {
            return @(accumulator.integerValue + item.integerValue);
        }];
    
    return @{
        @"accuracy": @((float)total.integerValue / (float)metrics.count)
    };
}

@end
