//
//  TIOInMemoryBatchDataSource.h
//  TensorIO
//
//  Created by Phil Dow on 5/19/19.
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

#import "TIOBatchDataSource.h"
#import "TIOBatch.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * A convenience data source when batch data is small enough to be loaded into
 * memory at the same time. Provide it a batch of any size and it will handle
 * the data source implementation. Provide this data source to a class such as
 * `TIOModelTrainer`.
 *
 * It will typically not be possible to use an in-memory data source if you are
 * working with image data, as only a few images can be loaded into memory
 * simultaneously without encountering out of memory errors.
 */

@interface TIOInMemoryBatchDataSource : NSObject <TIOBatchDataSource>

/**
 * The batch this data source will vend.
 */

@property (readonly) TIOBatch *batch;

/**
 * Instantiates an in-memory data source from a batch.
 */

- (instancetype)initWithBatch:(TIOBatch *)batch NS_DESIGNATED_INITIALIZER;

/**
 * A convenience initializer when you only have a single batch item.
 */

- (instancetype)initWithItem:(TIOBatchItem *)item;

/**
 * Use the designated initializer.
 */

- (instancetype)init NS_UNAVAILABLE;

// MARK: - TIOBatchDataSource

/**
 * The batch keys.
 */

@property (readonly) NSArray<NSString*> *keys;

/**
 * The total number of items that will be vended by the data source.
 */

- (NSUInteger)numberOfItems;

/**
 * The item at a given index. It is the responsibility of the data source to
 * randomize item order (shuffle).
 */

- (TIOBatchItem *)itemAtIndex:(NSUInteger)index;

@end

NS_ASSUME_NONNULL_END
