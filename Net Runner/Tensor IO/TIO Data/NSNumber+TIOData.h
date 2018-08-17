//
//  NSNumber+TIOData.h
//  Net Runner Parser
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
 *
 * The length of the data determines if the number will be instantiated with a floating point value
 * single byte integer.
 *
 */

@interface NSNumber (TIOData) <TIOData>

- (nullable instancetype)initWithBytes:(const void *)bytes length:(NSUInteger)length description:(id<TIODataDescription>)description;
- (void)getBytes:(void *)buffer length:(NSUInteger)length description:(id<TIODataDescription>)description;

@end

NS_ASSUME_NONNULL_END
