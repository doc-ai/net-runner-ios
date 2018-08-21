//
//  NSDictionary+TIOData.h
//  TensorIO
//
//  Created by Philip Dow on 8/6/18.
//  Copyright © 2018 doc.ai. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "TIOLayerDescription.h"
#import "TIOData.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * `NSDictionary` conforms to `TIOData` so that it may be passed as input to a model and returned
 * as output from a model.
 *
 * @warning
 * A dictionary can neither provide bytes directly to nor capture bytes directly from a tensor.
 * Instead the named entries of the dictionary must be able to do so.
 */

@interface NSDictionary (TIOData) <TIOData>

/**
 * Initializes an `NSDictionary` object with bytes from a tensor.
 *
 * @param bytes The output buffer to read from.
 * @param length The length of the buffer.
 * @param description A description of the data this buffer produces.
 *
 * @return instancetype An empty dictionary.
 *
 * @warning This method is unimplemented. A dictionary cannot be constructed directly from a tensor.
 */

- (nullable instancetype)initWithBytes:(const void *)bytes length:(NSUInteger)length description:(id<TIOLayerDescription>)description;

/**
 * Request to fill a tensor with bytes.
 *
 * @param buffer The input buffer to copy bytes to.
 * @param length The length of the input buffer.
 * @param description A description of the data this buffer expects.
 */

- (void)getBytes:(void *)buffer length:(NSUInteger)length description:(id<TIOLayerDescription>)description;

@end

NS_ASSUME_NONNULL_END
