//
//  TIOModelTrainer.h
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

NS_ASSUME_NONNULL_BEGIN

@protocol TIOBatchDataSource;
@protocol TIOTrainableModel;
@protocol TIOData;

/**
 * Responsible for actually executing training passes on a model, iterating
 * over a specified number of epochs and preparing batches of a specified size.
 * The trainer receives is instantiated with a `TIOBatchDataSource` which will
 * nprovide data as needed during the training loop.
 */

@interface TIOModelTrainer : NSObject

/**
 * Instantiates a `TIOModelTrainer` with the information required to exceute a
 * training loop.
 *
 * @param model The model that will be trained.
 * @param dataSource A data source that will provide batch items.
 * @param placeholders A dictionary of placeholder values that will be injected
 *  into the underlying model, e.g. hyperparameters. Currently unsupported.
 * @param epochs The number of training epochs.
 * @param batchSize The batch size to use for each training pass.
 * @param shuffle `YES` if batch items should be shuffled.
 *
 * @return TIOModelTrainer The trainer instance.
 *
 * @warning placeholders is currently unsupported.
 */

- (instancetype)initWithModel:(id<TIOTrainableModel>)model dataSource:(id<TIOBatchDataSource>)dataSource placeholders:(nullable NSDictionary<NSString*, id<TIOData>> *)placeholders epochs:(NSUInteger)epochs batchSize:(NSUInteger)batchSize shuffle:(BOOL)shuffle NS_DESIGNATED_INITIALIZER;

/**
 * Use the designated initializer.
 */

- (instancetype)init NS_UNAVAILABLE;

/**
 * The model that will be trained.
 */

@property (readonly) id<TIOTrainableModel> model;

/**
 * A data source that will provide batch items.
 */

@property (readonly) id<TIOBatchDataSource> dataSource;

/**
 * A dictionary of placeholder values that will be injected into the underlying
 * model. Except for the number of epochs and the batch size, hyperparameters
 * are usually passed into the model trainer via this property.
 */

@property (nullable, readonly) NSDictionary<NSString*, id<TIOData>> *placeholders;

/**
 * The number of training epochs.
 */

@property (readonly) NSUInteger epochs;

/**
 * The batch size to use for each training pass.
 */

@property (readonly) NSUInteger batchSize;

/**
 * `YES` if the trainer will shuffle batch item indices before requesting them
 * from the data source, `NO` otherwise.
 */

@property (readonly) BOOL shuffle;

/**
 * Executes the training loop and returns the results.
 */

- (id<TIOData>)train;

// TODO: Test

/**
 * Executes the training loop with a callback.
 *
 * The callback is called after each epoch with that epoch's training results.
 *
 * @warning
 * An error will be reported only if an error occurred during the last batch
 * processing for the current epoch
 */

- (void)train:(void(^_Nonnull)(NSUInteger epoch, id<TIOData> results, NSError * _Nullable error))callback;

@end

NS_ASSUME_NONNULL_END

