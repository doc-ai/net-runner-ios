//
//  TIOModelIO.h
//  TensorIO
//
//  Created by Phil Dow on 6/25/19.
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

@class TIOLayerInterface;
@class TIOModelIOList;

/**
 * Encapsulates information about the inputs, outputs, and placeholders for a model.
 */

@interface TIOModelIO : NSObject

/**
 * Initializes an instance of TIOModelIO with input and output interfaces.
 */

- (instancetype)initWithInputInterfaces:(NSArray<TIOLayerInterface*> *)inputInterfaces ouputInterfaces:(NSArray<TIOLayerInterface*> *)outputInterfaces NS_DESIGNATED_INITIALIZER;

/**
 * Initializes an instance of TIOModelIO with input, output, and placeholder interfaces.
 */

- (instancetype)initWithInputInterfaces:(NSArray<TIOLayerInterface*> *)inputInterfaces ouputInterfaces:(NSArray<TIOLayerInterface*> *)outputInterfaces placeholderInterfaces:(nullable NSArray<TIOLayerInterface*> *)placeholderInterfaces;

/**
 * Use the designated initializer.
 */

- (instancetype)init NS_UNAVAILABLE;

/**
 * The inputs list. Access the values in this list using indexed subscripting
 * by name or by key.
 *
 * @code
 * inputs[0]
 * inputs[@"image"]
 * @endcode
 */

@property (readonly) TIOModelIOList *inputs;

/**
 * The outputs list. Access the values in this list using indexed subscripting
 * by name or by key.
 *
 * @code
 * outputs[0]
 * outputs[@"label"]
 * @endcode
 */

@property (readonly) TIOModelIOList *outputs;

/**
 * The placeholders list. May be empty. Access the values in this list using
 * indexed subscripting by name or by key.
 *
 * @code
 * placeholders[0]
 * placeholders[@"label"]
 * @endcode
 */

@property (readonly) TIOModelIOList *placeholders;

@end

// MARK: -

/**
 * An I/O list may be indexed by key or by index.
 */

@interface TIOModelIOList : NSObject <NSFastEnumeration>

/**
 * Initializes an indexed model list with a list interfaces. You should not
 * need to create instances of this class yourself.
 *
 * If the initializing interfaces parameter is nil, it will be treated as an
 * empty list.
 */

- (instancetype)initWithLayerInterfaces:(nullable NSArray<TIOLayerInterface*> *)interfaces NS_DESIGNATED_INITIALIZER;

/**
 * Use the designated initializer.
 */

- (instancetype)init NS_UNAVAILABLE;

// MARK: -

/**
 * The number of items in the list.
 */

@property (readonly) NSUInteger count;

/**
 * All items in the list as an array.
 */

@property (readonly) NSArray<TIOLayerInterface*> *all;

/**
 * All of the keys (names) in the list.
 */

@property (readonly) NSArray<NSString*> *keys;

/**
 * Returns the numeric index for the named index.
 */

- (NSNumber *)indexForName:(NSString *)name;

// MARK: -

/**
 * Returns the `TIOLayerInterface` for the I/O at a numeric index, or raises an
 * exception if no interface is available at the index.
 */

- (TIOLayerInterface *)objectAtIndexedSubscript:(NSInteger)idx;

/**
 * Raises an exception. List values are read-only.
 */

- (void)setObject:(TIOLayerInterface *)obj atIndexedSubscript:(NSInteger)idx;

/**
 * Returns the `TIOLayerInterface` for the I/O at a named index, or raises an
 * exception if no interface is available at the index.
 */

- (TIOLayerInterface *)objectForKeyedSubscript:(NSString *)key;

/**
 * Raises an exception. List values are read-only.
 */

- (void)setObject:(TIOLayerInterface *)obj forKeyedSubscript:(NSString *)key;

// MARK: -

- (BOOL)isEqualToModelIOList:(TIOModelIOList *)otherList;

@end

NS_ASSUME_NONNULL_END
