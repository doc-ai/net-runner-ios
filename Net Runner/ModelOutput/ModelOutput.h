//
//  ModelOutput.h
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

NS_ASSUME_NONNULL_BEGIN

/**
 * A wrapper around a model's output.
 *
 * This is a utility protocol that is application specific so that we can handle multiple kinds of
 * descriptions for multiple kinds of models.
 */

@protocol ModelOutput <NSObject>

/**
 * The underlying output of the model. May be in any format appropriate to your use case.
 */

@property (readonly) id value;

/**
 * A property list representation of the underlying output. The representation should be JSON serializable.
 */

@property (readonly) id propertyList;

/**
 * A debug string that describes the contents of the receiver.
 */

@property(readonly, copy) NSString *description;

/**
 * A human readable representation of the underlying output.
 */

@property (readonly) NSString *localizedDescription;

/**
 * Designated initializer.
 *
 * @param dictionary the results of performing inference with a model.
 */

- (instancetype)initWithDictionary:(NSDictionary*)dictionary;

/**
 * `YES` if the two outputs are equal, `NO` otherwise
 */

- (BOOL)isEqual:(id)anObject;

/**
 * A decayed combination of the model's previous and current outputs.
 * If you don't want to return a decayed value, simply return `self`.
 *
 * @param previousOutput the previous output of the model. The previous output may be `nil`,
 * in which case you should return `self`.
 *
 * @return a decayed combination of the previous and current outputs
 */

- (id<ModelOutput>)decayedOutput:(nullable id<ModelOutput>)previousOutput;

@end

NS_ASSUME_NONNULL_END
