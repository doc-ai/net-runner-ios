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

@interface NSArray<T> (Blocks)

- (id)reduce:(id)initial combine:(id (^)(id accumulator,T item))combine;
- (NSArray *)filter:(BOOL (^)(T obj, NSUInteger idx, BOOL *stop))block;
- (NSArray *)map:(id(^)(T obj))block;
- (BOOL)contains:(BOOL(^)(T obj))block;

@end

// MARK: - Other utilities

@interface NSArray (Utilities)

// Returns the first n elements, or if the length of the array is less than n,
// the contents of array.

- (NSArray *)firstN:(NSUInteger)n;

// Returns all objects in the array reversed, by way of the reverseObjectEnumerator

- (NSArray *)reversed;

// Returns the numeric product of the array's entries. The entries must be of type NSNumber

- (NSInteger)product;

@end

// MARK: - Arrays of Dictionaries

@interface NSArray (DictionaryUtilities)

- (NSDictionary *)groupBy:(NSString*)key;

@end

NS_ASSUME_NONNULL_END
