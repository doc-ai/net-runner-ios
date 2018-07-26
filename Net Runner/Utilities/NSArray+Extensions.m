//
//  NSArray+Extensions.m
//  tflite_camera_example
//
//  Created by Philip Dow on 7/10/18.
//  Copyright © 2018 doc.ai. All rights reserved.
//

#import "NSArray+Extensions.h"

@implementation NSArray (Blocks)

- (NSArray *)filter:(BOOL (^)(id obj, NSUInteger idx, BOOL *stop))block {
    NSIndexSet * filteredIndexes = [self indexesOfObjectsPassingTest:block];
    return [self objectsAtIndexes:filteredIndexes];
}

- (NSArray *)map:(id(^)(id))block {
    NSMutableArray * newArray = [NSMutableArray array];
    for (id item in self) {
        id obj = block(item);
        [newArray addObject:obj];
    }
    return newArray;
}

- (id)reduce:(id)initial combine:(id (^)(id, id))combine{
    id accumulator = initial;
    for (id item in self) {
        accumulator = combine(accumulator, item);
    }
    return accumulator;
}

- (BOOL)contains:(BOOL (^)(id))block{
    for (id obj in self) {
        if (block(obj)) {
            return YES;
        }
    }
    return NO;
}

@end

// MARK: -

@implementation NSArray (Utilities)

- (NSArray *)firstN:(NSUInteger)n {
    if ( self.count <= n ) {
        return self;
    } else {
        return [self subarrayWithRange:NSMakeRange(0, n)];
    }
}

- (NSArray *)reversed {
    return [[self reverseObjectEnumerator] allObjects];
}

@end

// MARK: -

@implementation NSArray (DictionaryUtilities)

- (NSDictionary *)groupBy:(NSString*)key {
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    
    for (id obj in self) {
        id keyValue = [obj valueForKey:key];
        if (keyValue) {
            NSMutableArray *array = dictionary[keyValue];
            if (!array) {
                array = [NSMutableArray array];
                dictionary[keyValue] = array;
            }
            [array addObject:obj];
        }
    }
    return [dictionary copy];
}

@end
