//
//  ClassificationModelOutput.h
//  Net Runner
//
//  Created by Phil Dow on 2/14/19.
//  Copyright © 2019 doc.ai. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ModelOutput.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * A wrapper for classification outputs. Model outputs are considered application specific
 * at this point. For this formatter, there must be only one output and its name
 * must be "classification".
 */

@interface NoDecayClassificationModelOutput : NSObject <ModelOutput>

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
