//
//  ImageNetClassificationModelOutput.h
//  Net Runner
//
//  Created by Philip Dow on 7/28/18.
//  Copyright © 2018 doc.ai (http://doc.ai)
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

@import Foundation;

#import "ModelOutput.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * A wrapper for imagenet classification outputs. Model outputs are considered application specific
 * at this point. The `ImageNetClassificationModelOutput` takes the top 5 results over a probability
 * threshold of 0.1 from the "classification" value in the output.
 */

@interface ImageNetClassificationModelOutput : NSObject <ModelOutput>

/**
 * The output of the model, e.g. the result of performing inference with the model
 * and a mapping of classifications to their probabilities.
 */

@property (readonly) NSDictionary *output;

/**
 * Designated initializer.
 *
 * @param dictionary the results of performing inference with a model.
 */

- (instancetype)initWithDictionary:(NSDictionary*)dictionary NS_DESIGNATED_INITIALIZER;

/**
 * Use the designated initializer.
 */

- (instancetype)init NS_UNAVAILABLE;

// Model Output Conformance

/**
 * An instance of `NSDictionary` mapping classifications to probabilities.
 * The same value as `output`.
 */

@property (readonly) id value;

/**
 * An instance of `NSDictionary` mapping classifications to probabilities.
 * The same value as `output`.
 */

@property (readonly) id propertyList;

/**
 * The top-5 results with probabilities in human readable format
 */

@property (readonly) NSString *localizedDescription;

/**
 * Determines if two outputs are equal or not. Compares the `output` dictionaries of the two models.
 *
 * @param anObject The object to compare equality against.
 *
 * @return `YES` if the two outputs dictionaries are equal, `NO` otherwise.
 */

- (BOOL)isEqual:(id)anObject;

/**
 * Applies an exponential decay to the model output using the previous results
 * and returns the combination.
 *
 * Returns `self` if the `previousOutput` is nil.
 *
 * @param previousOutput The previous output produced by the model
 *
 * @return An exponentially weighted decay of the current and previous outputs, or `self` if `previousOutput` is `nil`.
 */

- (id<ModelOutput>)decayedOutput:(nullable id<ModelOutput>)previousOutput;

@end

NS_ASSUME_NONNULL_END
