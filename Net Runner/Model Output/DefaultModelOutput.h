//
//  DefaultModelOutput.h
//  Net Runner
//
//  Created by Philip Dow on 8/16/18.
//  Copyright © 2018 doc.ai. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ModelOutput.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * The default model output accepts a dictionary of any kinds of keys, values, and hierarchy
 * It produces a simple description of the dictionary and applies no decay.
 */

@interface DefaultModelOutput : NSObject <ModelOutput>

/**
 * The output of the model, e.g. the result of performing inference with the model.
 */

@property (readonly) NSDictionary<NSString*,NSNumber*> *output;

- (instancetype)initWithDictionary:(NSDictionary<NSString*,NSNumber*>*)dictionary;

// Model Output Conformance

/**
 * An instance of `NSDictionary`, the same as output
 */

@property (readonly) id value;

/**
 * A property list representation of the underlying model output
 */

@property (readonly) id propertyList;

/**
 * Simply calls `output.description` or returns an empty string is the output is empty
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
 * Return self, ignoring the previous output
 */

- (id<ModelOutput>)decayedOutput:(nullable id<ModelOutput>)previousOutput;

@end

NS_ASSUME_NONNULL_END
