//
//  NSArray+TIOExtensions.h
//  TensorIO
//
//  Created by Philip Dow on 7/10/18.
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

// MARK: - Blocks

/**
 * A set of widely used functional extensions to `NSArray`.
 */
 
@interface NSArray<T> (Blocks)

/**
 * Traverses the array and calls the combine block, returning a single value
 * that is accumulated by the block.
 */

- (id)reduce:(id)initial combine:(id (^)(id accumulator, T item))combine;

/**
 * Traverses the array and returns a new array composed only of those items
 * for which the provided block returns `YES`.
 */

- (NSArray *)filter:(BOOL (^)(T obj, NSUInteger idx, BOOL *stop))block;

/**
 * Traverses the array and calls the provided block with each item, returning a new
 * array composed of the items returned by the block.
 */

- (NSArray *)map:(id(^)(T obj))block;

/**
 * Traverses the array and returns `YES` if the provided block returns `YES` for any item.
 */

- (BOOL)contains:(BOOL(^)(T obj))block;

@end

// MARK: - Other utilities

/**
 * Additional array utilities used by TensorIO.
 */

@interface NSArray (Utilities)

/**
 * Returns the first n elements, or if the length of the array is less than n,
 * the contents of array.
 */

- (NSArray *)firstN:(NSUInteger)n;

/**
 * Returns all objects in the array reversed, by way of the `reverseObjectEnumerator`.
 */

- (NSArray *)reversed;

/**
 * Returns the numeric product of the array's entries. The entries must be of type `NSNumber`.
 */

- (NSInteger)product;

/**
 * Returns a subset of the array without the batch dimension, if it has one.
 * The batch will always be along the first or last axis and is indicated by
 * the presence of `-1` in that dimension.
 */

- (NSArray *)excludingBatch;

/**
 * Returns a subset of the array excluding the first item, or an empty array
 * if the array is empty.
 */

- (NSArray *)excludingFirst;

/**
 * Returns a subset of the array excluding the last item, or an empty array
 * if the array is empty.
 */

- (NSArray *)excludingLast;

@end

// MARK: - Arrays of Dictionaries

/**
 * Utilities for arrays of dictionaries.
 */

@interface NSArray (DictionaryUtilities)

/**
 * Groups the items in the array by some key, returning a dictionary of those key-grouping pairs.
 */

- (NSDictionary *)groupBy:(NSString *)key;

@end

NS_ASSUME_NONNULL_END
