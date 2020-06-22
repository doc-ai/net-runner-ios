//
//  TIOBatchDataSource.h
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

#import <Foundation/Foundation.h>

#import "TIOBatch.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * Classes which implement the `TIOBatchDataSource` protocol are able to provide
 * data to a model for training or prediction in chunks rather than all at once.
 *
 * A data source is used by the `TIOModelTrainer` class for training on
 * variable amount of data and is passed through to that class by the
 * `TIOFederatedManager`. Application classes will typically implement this
 * protocol and register themselves with a `TIOFederatedManager` as a data
 * provider.
 */

@protocol TIOBatchDataSource <NSObject>

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
