//
//  NSArray+Extensions.h
//  Net Runner
//
//  Created by Philip Dow on 7/10/18.
//  Copyright © 2018 doc.ai. All rights reserved.
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
