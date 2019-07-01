//
//  TIOModelIdentifier.h
//  TensorIO
//
//  Created by Phil Dow on 6/28/19.
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

/**
 * Encapsulate the canonical information required to uniquely identify a
 * Tensor/IO model and is used by both the deployment and federated client code.
 *
 * A model is uniquely identified by triple of (Model ID, Hyperparameters ID,
 * Checkpoint ID):
 *
 * - Model ID: Uniquely identifies the model task.
 * - Hyperparameters ID: Identifes a set of training parameters applied to the model.
 * - Checkpoint ID: Identifies the checkpoint at which this model, with these
 *   hyperparameters, was produced.
 *
 * Only the Model ID is required, which may simplify the use of this class, but
 * the Hyperparameters and Checkpoint ID are both required when using the
 * deployment or federated learning clients.
 */

@interface TIOModelIdentifier : NSObject

/**
 * The Model ID uniquely identifying the problem space or task.
 */

@property (readonly) NSString *modelId;

/**
 * The Hyperparameters ID identifying a set of training parameters applied to
 * the model.
 */

@property (nullable, readonly) NSString *hyperparametersId;

/**
 * The Checkpoint ID identifying the checkpoint at which this model, with these
 * hyperparameters, was produced.
 */

@property (nullable, readonly) NSString *checkpointId;

/**
 * Creates an instance with the canonical identifiers of a unique model.
 */

- (instancetype)initWithModelId:(NSString *)modelId hyperparametersId:(nullable NSString *)hyperparametersId checkpointsId:(nullable NSString *)checkpointId NS_DESIGNATED_INITIALIZER;

/**
 * Creates an instance from the ID stored in a model bundle.
 *
 * Model bundle IDs are more flexible than canonical model identifiers and can
 * identify a model in an arbitrary way. If a model bundle is associated with a
 * model respository, its ID can be parsed into a canonical triple and will
 * have the format following:
 *
 * tio:///models/{model-id}/hyperparameters/{hyperparameters-id}/checkpoints/{checkpoint-id}
 *
 * Note that this is a URL with the "tio" scheme and no server. The path can be
 * applied directly to the base URL of a model repository to acquire the model
 * described by this identifier.
 *
 * Returns `nil` if the bundle ID does not match this format.
 */

- (nullable instancetype)initWithBundleId:(NSString *)bundleId;

/**
 * Use the designated initializer or one of the convenience initializers.
 */

- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
