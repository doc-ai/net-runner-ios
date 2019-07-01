//
//  TIOModelModes.h
//  TensorIO
//
//  Created by Phil Dow on 4/30/19.
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
 * Encapsulates the modes supported by a model, e.g. predict, train, and evaluate.
 */

@interface TIOModelModes : NSObject

/**
 * Initializes a `TIOModelModes` from an array of string values which must be
 * "predict", "train", or "evaluate".
 *
 * @param array An array of string values to parse
 * @return instancetype An instance of TIOModelModes
 */

- (instancetype)initWithArray:(nullable NSArray<NSString*>*)array NS_DESIGNATED_INITIALIZER;

/**
 * Use the designated initializer.
 */

- (instancetype)init NS_UNAVAILABLE;

/**
 * Returns `YES` if this model includes prediction ops.
 */

@property (readonly) BOOL predicts;

/**
 * Returns `YES` if this model includes training ops.
 */

@property (readonly) BOOL trains;

/**
 * Returns `YES` if this model includes evaluation ops.
 */

@property (readonly) BOOL evals;

@end

NS_ASSUME_NONNULL_END
