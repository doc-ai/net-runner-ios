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
 * The underlying bytes will be supplied directly to or accepted directly form a tensor.
 * NSData already implements both:
 *
 * @code
 * `- (instancetype)initWithBytes:(const void *)bytes length:(NSUInteger)length` and
 * `- (void)getBytes:(void *)buffer length:(NSUInteger)length`.
 * @endcode
 *
 * So we just pass initialization to those methods without making any assumptions about the type
 * of the data (float32 or uint8).
 */

@interface NSData (TIOData) <TIOData>

- (nullable instancetype)initWithBytes:(const void *)bytes length:(NSUInteger)length description:(id<TIODataDescription>)description;
- (void)getBytes:(void *)buffer length:(NSUInteger)length description:(id<TIODataDescription>)description;

@end

NS_ASSUME_NONNULL_END
