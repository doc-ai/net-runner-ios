//
//  ImageNetClassificationModelOutput.h
//  Net Runner
//
//  Created by Philip Dow on 7/28/18.
//  Copyright © 2018 doc.ai. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ModelOutput.h"

NS_ASSUME_NONNULL_BEGIN

@interface ImageNetClassificationModelOutput : NSObject <ModelOutput>

@property (readonly) NSDictionary *output;

- (instancetype)initWithDictionary:(NSDictionary*)dictionary;

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
 * `YES` if the two outputs dictionaries are equal, `NO` otherwise
 */

- (BOOL)isEqual:(id)anObject;

/**
 * Applies an exponential decay to the model output using the previous results
 * and returns the combination.
 */

- (id<ModelOutput>)decayedOutput:(nullable id<ModelOutput>)previousOutput;

@end

NS_ASSUME_NONNULL_END
