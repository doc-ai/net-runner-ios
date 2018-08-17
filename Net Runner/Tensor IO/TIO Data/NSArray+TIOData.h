//
//  NSArray+TIOData.h
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
 * An array of numbers, also typed as a `TIOVector`, is able to provide bytes to or capture bytes
 * from a tensor.
 */

@interface NSArray (TIOData) <TIOData>

- (nullable instancetype)initWithBytes:(const void *)bytes length:(NSUInteger)length description:(id<TIODataDescription>)description;
- (void)getBytes:(void *)buffer length:(NSUInteger)length description:(id<TIODataDescription>)description;

@end

NS_ASSUME_NONNULL_END
