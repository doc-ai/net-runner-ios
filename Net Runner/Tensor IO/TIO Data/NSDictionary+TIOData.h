//
//  NSDictionary+TIOData.h
//  Net Runner Parser
//
//  Created by Philip Dow on 8/6/18.
//  Copyright © 2018 doc.ai. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "TIODataDescription.h"
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

- (nullable instancetype)initWithBytes:(const void *)bytes length:(NSUInteger)length description:(id<TIODataDescription>)description;
- (void)getBytes:(void *)buffer length:(NSUInteger)length description:(id<TIODataDescription>)description;

@end

NS_ASSUME_NONNULL_END
