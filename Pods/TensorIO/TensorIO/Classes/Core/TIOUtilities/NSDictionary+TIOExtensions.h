//
//  NSDictionary+TIOExtensions.h
//  Net Runner
//
//  Created by Philip Dow on 8/6/18.
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

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * TensorIO utility functions for `NSDictionary`.
 *
 * A number of models return a softmax function over a set of labeled output,
 * for example, classification outputs. These utility functions are meant to
 * be worked with that kind of data, where the entries in the dictionary are
 * label-probability key-value pairs.
 */

@interface NSDictionary (Extensions)

/**
 * Returns the top N or fewer entries in the dictionary, by probability.
 */

- (NSDictionary *)topN:(NSUInteger)count;

/**
 * Returns the top N entries in the dictionary, by probability, but only
 * those that surpass a threshold.
 *
 * Entries are first filtered by the threshold then sorted, and finally the
 * top N or fewer entries are returned.
 */

- (NSDictionary *)topN:(NSUInteger)count threshold:(float)threshold;

@end

NS_ASSUME_NONNULL_END
