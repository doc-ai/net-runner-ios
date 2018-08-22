//
//  EvaluationMetricFactory.m
//  Net Runner
//
//  Created by Philip Dow on 7/19/18.
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
