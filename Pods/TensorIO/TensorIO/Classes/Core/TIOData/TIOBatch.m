//
//  TIOBatch.m
//  TensorIO
//
//  Created by Phil Dow on 4/24/19.
//  Copyright © 2019 doc.ai (http://doc.ai)
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

#import "TIOBatch.h"

@interface TIOBatch ()

@property (readwrite) NSArray<NSString*> *keys;

@end

@implementation TIOBatch {

    /**
     * Items are managed as a collection of named arrays of `TIOData`. Think of
     * the collection as a matrix whose rows are a single item, whose columns
     * are named, and whose values are accessed by row index or column name.
     */

    NSMutableDictionary<NSString*,NSMutableArray<id<TIOData>>*> *_items;
}

- (instancetype)initWithKeys:(NSArray<NSString*>*)keys {
#if DEBUG
    assert(keys.count > 0);
#endif

    if ((self=[super init])) {
        _items = [[NSMutableDictionary alloc] init];
        _keys = keys;
        
        for (NSString *key in _keys) {
            _items[key] = [[NSMutableArray alloc] init];
        }
        
    }
    return self;
}

- (instancetype)initWithItems:(NSArray<TIOBatchItem *> *)items {
#if DEBUG
    assert(items.count > 0);
#endif

    if ((self=[self initWithKeys:items[0].allKeys])) {
        for (TIOBatchItem *item in items) {
            [self addItem:item];
        }
    }
    return self;
}

- (instancetype)initWithItem:(TIOBatchItem *)item {
    if ((self=[self initWithKeys:item.allKeys])) {
        [self addItem:item];
    }
    return self;
}

- (NSUInteger)count {
    return _items[_keys[0]].count;
}

- (void)addItem:(TIOBatchItem *)item {
#if DEBUG
    assert([[NSSet setWithArray:item.allKeys] isEqualToSet:[NSSet setWithArray:_keys]]);
#endif
    
    for (NSString *key in item.allKeys) {
        [_items[key] addObject:item[key]];
    }
}

- (TIOBatchItem *)itemAtIndex:(NSUInteger)index {
    assert(index < self.count);
    
    NSMutableDictionary *item = [[NSMutableDictionary alloc] init];
    
    for (NSString *key in _keys) {
        item[key] = _items[key][index];
    }
    
    return (TIOBatchItem *)item.copy;
}

- (NSArray<id<TIOData>>*)valuesForKey:(NSString *)key {
    return _items[key].copy;
}

- (id)objectAtIndexedSubscript:(NSUInteger)idx {
    return [self itemAtIndex:idx];
}

- (void)setObject:(id)obj atIndexedSubscript:(NSUInteger)idx {
    NSAssert(NO, @"Writing to an indexed subscript is not supported. Use addItem: to add an item to a batch");
}

@end
