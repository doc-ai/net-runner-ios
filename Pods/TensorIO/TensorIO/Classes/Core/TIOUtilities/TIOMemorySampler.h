//
//  TIOMemorySampler.h
//  TensorIO
//
//  Created by Phil Dow on 7/2/19.
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

@interface TIOMemorySampler : NSObject

/**
 * Initializes a sampler that will sample resident memory at every interval.
 * Only the maximum value will be stored and is available through the `max`
 * property.
 */

- (instancetype) initWithInterval:(NSTimeInterval)interval NS_DESIGNATED_INITIALIZER;

/**
 * Use the designated initializer.
 */

- (instancetype) init NS_UNAVAILABLE;

/**
 * The time interval at which to take a sample.
 */

@property (readonly) NSTimeInterval interval;

/**
 * The maximum size of the resident memory discovered during sampling, in bytes,
 * or -1 if you have not started sampling yet.
 */

@property (readonly) NSNumber *max;

/**
 * Begin memory sampling.
 */

- (void)start;

/**
 * Stop memory sampling
 */

- (void)stop;

@end

NS_ASSUME_NONNULL_END
