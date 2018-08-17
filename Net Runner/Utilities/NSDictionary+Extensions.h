//
//  NSDictionary+Extensions.h
//  Net Runner
//
//  Created by Philip Dow on 8/6/18.
//  Copyright © 2018 doc.ai. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSDictionary (Extensions)

- (NSDictionary*)topN:(NSUInteger)count;
- (NSDictionary*)topN:(NSUInteger)count threshold:(float)threshold;

@end

NS_ASSUME_NONNULL_END
