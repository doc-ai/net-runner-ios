//
//  NSDictionary+TIOExtensions.m
//  Net Runner
//
//  Created by Philip Dow on 8/6/18.
//  Copyright © 2018 doc.ai. All rights reserved.
//

#import "NSDictionary+TIOExtensions.h"

#import "NSArray+TIOExtensions.h"

@implementation NSDictionary (Extensions)

- (NSDictionary*)topN:(NSUInteger)count {
    NSArray *keys = [[[self keysSortedByValueUsingSelector:@selector(compare:)] reversed] firstN:count];
    NSArray *objects = [self objectsForKeys:keys notFoundMarker:NSNull.null];
    return [NSDictionary dictionaryWithObjects:objects forKeys:keys];
}

- (NSDictionary*)topN:(NSUInteger)count threshold:(float)threshold {
    
    // Filter entries below the threshold
    
    NSArray<NSString*> *thresholdedKeys = [self keysOfEntriesPassingTest:^BOOL(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        return ((NSNumber*)obj).floatValue > threshold;
    }].allObjects;
    
    NSArray *thresholdedObjects = [self objectsForKeys:thresholdedKeys notFoundMarker:NSNull.null];
    
    NSDictionary *thresholded = [NSDictionary dictionaryWithObjects:thresholdedObjects forKeys:thresholdedKeys];
    
    // Sort the remaining values and take the top N
    
    NSArray *topNKeys = [[[thresholded keysSortedByValueUsingSelector:@selector(compare:)] reversed] firstN:count];
    NSArray *topNObjects = [thresholded objectsForKeys:topNKeys notFoundMarker:NSNull.null];
    
    return [NSDictionary dictionaryWithObjects:topNObjects forKeys:topNKeys];
}


@end
