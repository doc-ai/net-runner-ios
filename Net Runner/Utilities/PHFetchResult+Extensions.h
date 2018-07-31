//
//  PHFetchResult+Extensions.h
//  Net Runner
//
//  Created by Philip Dow on 7/24/18.
//  Copyright © 2018 doc.ai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>

NS_ASSUME_NONNULL_BEGIN

@interface PHFetchResult (Extensions)

- (NSArray<PHAsset*>*)allAssets;

@end

NS_ASSUME_NONNULL_END
