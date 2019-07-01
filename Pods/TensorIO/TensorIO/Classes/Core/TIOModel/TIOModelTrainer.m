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

@implementation TIOModelTrainer

- (instancetype)initWithModel:(id<TIOTrainableModel>)model dataSource:(id<TIOBatchDataSource>)dataSource placeholders:(NSDictionary<NSString*, id<TIOData>>*)placeholders epochs:(NSUInteger)epochs batchSize:(NSUInteger)batchSize {
    if ((self=[super init])) {
        _model = model;
        _dataSource = dataSource;
        _placeholders = placeholders;
        _epochs = epochs;
        _batchSize = batchSize;
    }
    return self;
}

- (id<TIOData>)train {
    NSUInteger batchCount = self._batchCount;
    id<TIOData> results;
    
    for ( NSUInteger epoch = 0; epoch < self.epochs; epoch++ ) {
        for ( NSUInteger batchIndex = 0; batchIndex < batchCount; batchIndex++ ) {
            @autoreleasepool {
                TIOBatch *batch = [self _batchAtIndex:batchIndex];
                NSError *error;
                
                results = [self.model train:batch error:&error];
            }
        }
    }
    
    return results;
}

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
        TIOBatchItem *item = [self.dataSource itemAtIndex:itemIndex];
        [batch addItem:item];
    }
    
    return batch;
}

@end
