//
//  NSDictionary+Extensions.m
//  Net Runner
//
//  Created by Philip Dow on 8/6/18.
//  Copyright © 2018 doc.ai. All rights reserved.
//

#import "NSDictionary+Extensions.h"

#import "NSArray+Extensions.h"

@implementation NSDictionary (Extensions)

- (NSDictionary*)topN:(NSUInteger)count {
    NSArray *keys = [[[self keysSortedByValueUsingSelector:@selector(compare:)] reversed] firstN:count];
    NSArray *objects = [self objectsForKeys:keys notFoundMarker:NSNull.null];
    return [NSDictionary dictionaryWithObjects:objects forKeys:keys];
}

@end
