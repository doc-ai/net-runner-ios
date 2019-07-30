//
//  TIOTrainableModel.h
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
#import "TIOModel.h"
#import "TIOBatch.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * A trainable model extends the `TIOModel` protocol with support for training.
 */

@protocol TIOTrainableModel <TIOModel, NSObject>

/**
 * Calls the underlying training op with a single batch.
 *
 * A complete round of training will involve iterating over all the available
 * batches for a certain number of epochs. It is the responsibility of other
 * objects to execute those loops and prepare batches for calls to this method.
 * The `TIOModelTrainer` provides that functionality.
 *
 * @param batch A batch of input data.
 * @param error Set if an error occurred during inference. May be nil.
 * @return TIOData The results of training, or an empty dictionary if an error
 *  occurs.
 */

- (id<TIOData>)train:(TIOBatch *)batch error:(NSError * _Nullable *)error;

/**
 * Calls the underlying training op with a single batch and a set of placeholder
 * values.
 *
 * A complete round of training will involve iterating over all the available
 * batches for a certain number of epochs. It is the responsibility of other
 * objects to execute those loops and prepare batches for calls to this method.
 * The `TIOModelTrainer` provides that functionality.
 *
 * @param batch A batch of input data.
 * @param placeholders A dictionary of `TIOData` conforming placeholder values,
 *  which will be matched to placeholder layers in the model. May be nil.
 * @param error Set if an error occurred during inference. May be nil.
 * @return TIOData The results of training, or an empty dictionary if an error
 *  occurs.
 */

- (id<TIOData>)train:(TIOBatch *)batch placeholders:(nullable NSDictionary<NSString*,id<TIOData>> *)placeholders error:(NSError * _Nullable *)error;

/**
 * Deprecated. `Use train:error:` or train:placeholders:error:` instead.
 */

- (id<TIOData>)train:(TIOBatch *)batch __attribute__((deprecated));

/**
 * Exports the results of training to the specified directory. The directory
 * must already exist.
 *
 * @param fileURL File URL to the directory in which the export will be saved
 * @param error Set to any error that occurs during the export, otherwise `nil`
 *
 * @return `YES` if the export was successful,`NO` otherwise
 */

- (BOOL)exportTo:(NSURL *)fileURL error:(NSError * _Nullable *)error;

@end

NS_ASSUME_NONNULL_END
