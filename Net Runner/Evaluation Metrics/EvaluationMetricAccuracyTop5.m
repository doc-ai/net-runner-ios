//
//  EvaluationMetricAccuracyTop5.m
//  Net Runner
//
//  Created by Philip Dow on 7/19/18.
//  Copyright © 2018 doc.ai. All rights reserved.
//

#import "EvaluationMetricAccuracyTop5.h"
#import "NSArray+Extensions.h"

static NSString * const kClassificationOutputKey = @"classification";

@implementation EvaluationMetricAccuracyTop5

- (NSDictionary<NSString*,NSNumber*>*)evaluate:(NSDictionary<NSString*,id>*)y yhat:(NSDictionary<NSString*,id>*)yhat {
    NSArray *output = [[[yhat[kClassificationOutputKey] keysSortedByValueUsingSelector:@selector(compare:)] reversed] firstN:5];
    NSString *label = ((NSDictionary*)y[kClassificationOutputKey]).allKeys.firstObject;
    
    if ( [output containsObject:label] ) {
        return @{
            @"classification_accuracy": @(1)
         };
    } else {
        return @{
            @"classification_accuracy": @(0)
         };
    }
    
    return 0;
}

- (NSDictionary<NSString*,NSNumber*>*)reduce:(NSArray<NSDictionary<NSString*,NSNumber*>*>*)metrics {
    NSNumber *total =
        [[metrics
        map:^id _Nonnull(NSDictionary * _Nonnull obj) {
            return obj[@"classification_accuracy"];
        }]
        reduce:@(0) combine:^id _Nonnull(NSNumber * _Nonnull accumulator, NSNumber * _Nonnull item) {
            return @(accumulator.integerValue + item.integerValue);
        }];
    
    return @{
        @"classification_accuracy": @((float)total.integerValue / (float)metrics.count)
    };
}

@end
