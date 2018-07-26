//
//  EvaluationResultsActivityItemProvider.m
//  tflite_camera_example
//
//  Created by Philip Dow on 7/24/18.
//  Copyright © 2018 doc.ai. All rights reserved.
//

#import "EvaluationResultsActivityItemProvider.h"

@implementation EvaluationResultsActivityItemProvider

- (instancetype)initWithResults:(id)results {
    if ( self = [super initWithPlaceholderItem:[NSData new]] ) {
        _results = results;
    }
    
    return self;
}

- (NSString *)activityViewController:(UIActivityViewController *)activityViewController subjectForActivityType:(UIActivityType)activityType {
    return @"Evaluation Results";
}

- (NSString *)activityViewController:(UIActivityViewController *)activityViewController dataTypeIdentifierForActivityType:(UIActivityType)activityType {
    return @"public.json";
}

- (id)item {
    NSError *jsonError;
    NSData *data = [NSJSONSerialization dataWithJSONObject:self.results options:NSJSONWritingPrettyPrinted error:&jsonError];
    
    if (data == nil ) {
        NSLog(@"Error converting results to json: %@", jsonError);
        return nil;
    }
    
    return data;
}

@end
