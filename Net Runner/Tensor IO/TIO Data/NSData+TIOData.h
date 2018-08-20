//
//  NSData+TIOData.h
//  Net Runner Parser
//
//  Created by Philip Dow on 8/3/18.
//  Copyright © 2018 doc.ai. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "TIODataDescription.h"
#import "TIOData.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * An `NSData` object may be an input to a tensor or an output from a tensor.
 *
 * The underlying bytes will be supplied directly to or accepted directly from a tensor.
 * NSData already implements both:
 *
 * @code
 * `- (instancetype)initWithBytes:(const void *)bytes length:(NSUInteger)length` and
 * `- (void)getBytes:(void *)buffer length:(NSUInteger)length`.
 * @endcode
 *
 * So we just pass initialization to those methods without making any assumptions about the type
 * of the data (float_t or uint8_t).
 */

@interface NSData (TIOData) <TIOData>

/**
 * Initializes an `NSData` object with bytes from a tensor.
 *
 * @param bytes The output buffer to read from.
 * @param length The length of the buffer.
 * @param description A description of the data this buffer produces.
 *
 * @return instancetype An instance of `NSData`.
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
