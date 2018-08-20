//
//  NSDictionary+TIOData.m
//  TensorIO
//
//  Created by Philip Dow on 8/6/18.
//  Copyright © 2018 doc.ai. All rights reserved.
//

#import "NSDictionary+TIOData.h"

@implementation NSDictionary (TIOData)

- (nullable instancetype)initWithBytes:(const void *)bytes length:(NSUInteger)length description:(id<TIODataDescription>)description {
    NSAssert(NO, @"This method is unimplemented. A dictionary cannot be constructed directly from a tensor.");
    return [self init];
}

- (void)getBytes:(void *)buffer length:(NSUInteger)length description:(id<TIODataDescription>)description {
    NSAssert(NO, @"This method is unimplemented. Tensor bytes cannot be captured from a dictionary.");
}

@end
