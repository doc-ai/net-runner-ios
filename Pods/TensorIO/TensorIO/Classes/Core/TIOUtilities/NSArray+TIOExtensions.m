//
//  NSArray+TIOExtensions.m
//  TensorIO
//
//  Created by Philip Dow on 7/10/18.
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

#import "NSArray+TIOExtensions.h"

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

- (NSInteger)product {
    return [[self
        reduce:@(1) combine:^id _Nonnull(NSNumber * _Nonnull accumulator, NSNumber * _Nonnull item) {
            return @(accumulator.integerValue * item.integerValue);
        }]
        integerValue];
}

- (NSArray *)excludingBatch {
    if ( self.count == 0 ) {
        return self;
    }
    
    if ( ((NSNumber *)self.firstObject).integerValue == -1 ) {
        return self.excludingFirst;
    }
    if ( ((NSNumber *)self.lastObject).integerValue == -1 ) {
        return self.excludingLast;
    }
    
    return self;
}

- (NSArray *)excludingFirst {
    if ( self.count == 0 ) {
        return self;
    }
    
    return [self subarrayWithRange:NSMakeRange(1, self.count-1)];
}

- (NSArray *)excludingLast {
    if ( self.count == 0 ) {
        return self;
    }
    
    return [self subarrayWithRange:NSMakeRange(0, self.count-1)];
}

@end

// MARK: -

@implementation NSArray (DictionaryUtilities)

- (NSDictionary *)groupBy:(NSString *)key {
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
