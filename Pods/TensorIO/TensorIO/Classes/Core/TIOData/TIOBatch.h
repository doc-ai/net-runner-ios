//
//  TIOBatch.h
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

#import <Foundation/Foundation.h>

#import "TIOData.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * A single batch item, equivalent to a training example or item to be used
 * for inference. A batch item is just a named tuple of values whose keys
 * correspond to the named inputs layers expected by a model operation.
 */

typedef NSDictionary<NSString*,id<TIOData>> TIOBatchItem;

/**
 * A batch represents a collection of named `TIOData` values that is used for
 * training. Batches are mutable and can be built up from inidividual training
 * examples, which are themselves just named `TIOData` values.
 */

@interface TIOBatch : NSObject

/**
 * Initializes a `TIOBatch` with the keys. Keys should correspond to the inputs
 * expected by a model operation, such as inference or training.
 */

- (instancetype)initWithKeys:(NSArray<NSString*>*)keys NS_DESIGNATED_INITIALIZER;

/**
 * Initialies a `TIOBatch` with an array of batch items. Item keys must be
 * identical and must correspond to the inputs expected by the model.
 */

- (instancetype)initWithItems:(NSArray<TIOBatchItem *> *)items;

/**
 * Initializes a `TIOBatch` with a single item, deriving the keys from it. Keys
 * must correspond to the inputs expected by the model.
 */

- (instancetype)initWithItem:(TIOBatchItem *)item;

/**
 * Use the designated initializer.
 */

- (instancetype)init NS_UNAVAILABLE;

/**
 * The number of items in the batch.
 */

@property (readonly) NSUInteger count;

/**
 * The batch keys.
 */

@property (readonly) NSArray<NSString*> *keys;

/**
 * Adds an item to the batch. The item must contain the same keys that the
 * batch was initialized with.
 */

- (void)addItem:(TIOBatchItem *)item;

/**
 * Returns the item at index (the row).
 */

- (TIOBatchItem *)itemAtIndex:(NSUInteger)index;

/**
 * Returns the values for key (the column).
 */

- (NSArray<id<TIOData>>*)valuesForKey:(NSString *)key;

/**
 * Readonly only support for indexed subscripting.
 */

- (id)objectAtIndexedSubscript:(NSUInteger)idx;

/**
 * Writing to an indexed subscript will raise an exception.
 */

- (void)setObject:(id)obj atIndexedSubscript:(NSUInteger)idx;

@end

NS_ASSUME_NONNULL_END
