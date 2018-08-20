//
//  NSNumber+TIOData.h
//  TensorIO
//
//  Created by Philip Dow on 8/4/18.
//  Copyright © 2018 doc.ai. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "TIODataDescription.h"
#import "TIOData.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * An `NSNumber` can provide a single value to a tensor or accepts a single value from a tensor.
 */

@interface NSNumber (TIOData) <TIOData>

/**
 * Initializes an `NSNumber` with bytes from a tensor.
 *
 * @param bytes The output buffer to read from.
 * @param length The length of the buffer.
 * @param description A description of the data this buffer produces.
 *
 * @return instancetype An instance of `NSNumber`.
 */

- (nullable instancetype)initWithBytes:(const void *)bytes length:(NSUInteger)length description:(id<TIODataDescription>)description;

/**
 * Request to fill a tensor with bytes.
 *
 * @param buffer The input buffer to copy bytes to.
 * @param length The length of the input buffer.
 * @param description A description of the data this buffer expects.
 */

- (void)getBytes:(void *)buffer length:(NSUInteger)length description:(id<TIODataDescription>)description;

@end

NS_ASSUME_NONNULL_END
