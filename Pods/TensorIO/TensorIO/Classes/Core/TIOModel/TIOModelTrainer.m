//
//  TIOModelTrainer.m
//  TensorIO
//
//  Created by Phil Dow on 5/18/19.
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

#import "TIOModelTrainer.h"
#import "TIOBatchDataSource.h"
#import "TIOTrainableModel.h"
#import "TIOData.h"

@interface NSMutableArray (TIOShuffle)

- (NSMutableArray *)TIOShuffle;

@end

@implementation NSMutableArray (TIOShuffle)

/**
 * Fisher-Yates shuffle for shuffling training items order. `shuffledArray` is
 * only availabe on iOS 10.0+.
 */

- (NSMutableArray *)TIOShuffle {
    for (NSUInteger i = self.count; i > 1; i--) {
        [self exchangeObjectAtIndex:i - 1 withObjectAtIndex:arc4random_uniform((u_int32_t)i)];
    }
    
    return self;
}

@end

// MARK: -

@implementation TIOModelTrainer {
    NSArray<NSNumber*> *_itemOrder;
}

- (instancetype)initWithModel:(id<TIOTrainableModel>)model dataSource:(id<TIOBatchDataSource>)dataSource placeholders:(NSDictionary<NSString*, id<TIOData>> *)placeholders epochs:(NSUInteger)epochs batchSize:(NSUInteger)batchSize shuffle:(BOOL)shuffle {
    if ((self=[super init])) {
        _model = model;
        _dataSource = dataSource;
        _placeholders = placeholders;
        _epochs = epochs;
        _batchSize = batchSize;
        _shuffle = shuffle;
    }
    return self;
}

- (id<TIOData>)train {
    [self _prepareItemOrder];

    NSUInteger batchCount = self._batchCount;
    id<TIOData> results;
    
    for ( NSUInteger epoch = 0; epoch < self.epochs; epoch++ ) {
        for ( NSUInteger batchIndex = 0; batchIndex < batchCount; batchIndex++ ) {
            @autoreleasepool {
                TIOBatch *batch = [self _batchAtIndex:batchIndex];
                NSError *error;
                
                results = [self.model train:batch placeholders:self.placeholders error:&error];
            }
        }
    }
    
    return results;
}

- (void)train:(void(^_Nonnull)(NSUInteger epoch, id<TIOData> results, NSError * _Nullable error))callback {
    [self _prepareItemOrder];

    NSUInteger batchCount = self._batchCount;
    id<TIOData> results;
    NSError *error;
    
    for ( NSUInteger epoch = 0; epoch < self.epochs; epoch++ ) {
        for ( NSUInteger batchIndex = 0; batchIndex < batchCount; batchIndex++ ) {
            @autoreleasepool {
                TIOBatch *batch = [self _batchAtIndex:batchIndex];
                results = [self.model train:batch placeholders:self.placeholders error:&error];
            }
        }
        callback(epoch, results, error);
    }
}

// MARK: -

/**
 * The total number of batches needed to feed all of the data source's item
 * in chunks of the specified batch size.
 */

- (NSUInteger)_batchCount {
    return (NSUInteger)ceilf((float)self.dataSource.numberOfItems / (float)self.batchSize);
}

/**
 * Prepares a batch for the training pass.
 */

- (TIOBatch *)_batchAtIndex:(NSUInteger)index {
    TIOBatch *batch = [[TIOBatch alloc] initWithKeys:self.dataSource.keys];
    NSUInteger numberOfItems = self.dataSource.numberOfItems;
    NSRange itemRange;
    
    NSUInteger start = index * self.batchSize;
    
    if ( (start + self.batchSize) > numberOfItems ) {
        itemRange = NSMakeRange(start, numberOfItems - start);
    } else {
        itemRange = NSMakeRange(start, self.batchSize);
    }
    
    for ( NSUInteger itemIndex = itemRange.location; itemIndex < NSMaxRange(itemRange); itemIndex++ ) {
        TIOBatchItem *item = [self.dataSource itemAtIndex:_itemOrder[itemIndex].unsignedIntegerValue];
        [batch addItem:item];
    }
    
    return batch;
}

/**
 * Prepare the batch item order for requests to the data source, shuffled if necessary
 */

- (void)_prepareItemOrder {
    NSMutableArray *order = NSMutableArray.array;
    
    for ( NSUInteger i = 0; i < self.dataSource.numberOfItems; i++ ) {
        [order addObject:@(i)];
    }
    
    _itemOrder = self.shuffle
        ? order.TIOShuffle.copy
        : order.copy;
}

@end
