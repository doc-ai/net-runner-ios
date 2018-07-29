//
//  ModelOutput.h
//  Net Runner
//
//  Created by Philip Dow on 7/28/18.
//  Copyright © 2018 doc.ai. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * A wrapper around a model's output. All `Model` instances should return an instance of `ModelOutput`
 * from their execute function.
 */

@protocol ModelOutput <NSObject>

/**
 * The underlying output of the model. May be in any format appropriate to your use case.
 */

@property (readonly) id value;

/**
 * A property list representation of the underlying results. The representation should be json serializable.
 */

@property (readonly) id propertyList;

/**
 * A string that describes the contents of the receiver.
 */

@property(readonly, copy) NSString *description;

/**
 * A human readable representation of the results.
 */

@property (readonly) NSString *localizedDescription;

/**
 * `YES` if the two outputs are equal, `NO` otherwise
 */

- (BOOL)isEqual:(id)anObject;

/**
 * A decayed combination of the model's previous and current outputs.
 * If you don't want to return a decayed value, simply return `self`.
 *
 * @param previousOutput the previous output of the model. The previous output may be `nil`,
 *  in which case you should return `self`.
 *
 * @return a decayed combination of the previous and current outputs
 */

- (id<ModelOutput>)decayedOutput:(nullable id<ModelOutput>)previousOutput;

@end

NS_ASSUME_NONNULL_END
