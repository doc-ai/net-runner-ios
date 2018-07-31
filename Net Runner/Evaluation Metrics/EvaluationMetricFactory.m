//
//  EvaluationMetricFactory.m
//  Net Runner
//
//  Created by Philip Dow on 7/19/18.
//  Copyright © 2018 doc.ai. All rights reserved.
//

#import "EvaluationMetricFactory.h"

@implementation EvaluationMetricFactory

+ (instancetype)sharedInstance {
    static dispatch_once_t once;
    static id sharedInstance;

    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (id<EvaluationMetric>) evaluationMetricForName:(NSString*)name {
    Class EvaluationMetricClass = NSClassFromString(name);
    
    if ( EvaluationMetricClass == nil ) {
        NSLog(@"Unable to convert metric class name to metric, %@", name);
        return nil;
    }
    
    id<EvaluationMetric> evaluationMetric = [[EvaluationMetricClass alloc] init];
    
    if ( evaluationMetric == nil ) {
        NSLog(@"Unable to instantiate metric for class %@", EvaluationMetricClass);
        return nil;
    }
    
    return evaluationMetric;
}

@end
