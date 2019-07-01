//
//  NSDictionary+TIOExtensions.m
//  Net Runner
//
//  Created by Philip Dow on 8/6/18.
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

#import "NSDictionary+TIOExtensions.h"

#import "NSArray+TIOExtensions.h"

@implementation NSDictionary (Extensions)

- (NSDictionary *)topN:(NSUInteger)count {
    NSArray *keys = [[[self keysSortedByValueUsingSelector:@selector(compare:)] reversed] firstN:count];
    NSArray *objects = [self objectsForKeys:keys notFoundMarker:NSNull.null];
    return [NSDictionary dictionaryWithObjects:objects forKeys:keys];
}

- (NSDictionary *)topN:(NSUInteger)count threshold:(float)threshold {
    
    // Filter entries below the threshold
    
    NSArray<NSString*> *thresholdedKeys = [self keysOfEntriesPassingTest:^BOOL(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        return ((NSNumber *)obj).floatValue > threshold;
    }].allObjects;
    
    NSArray *thresholdedObjects = [self objectsForKeys:thresholdedKeys notFoundMarker:NSNull.null];
    
    NSDictionary *thresholded = [NSDictionary dictionaryWithObjects:thresholdedObjects forKeys:thresholdedKeys];
    
    // Sort the remaining values and take the top N
    
    NSArray *topNKeys = [[[thresholded keysSortedByValueUsingSelector:@selector(compare:)] reversed] firstN:count];
    NSArray *topNObjects = [thresholded objectsForKeys:topNKeys notFoundMarker:NSNull.null];
    
    return [NSDictionary dictionaryWithObjects:topNObjects forKeys:topNKeys];
}


@end
