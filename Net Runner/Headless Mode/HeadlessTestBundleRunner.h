//
//  HeadlessTestBundleRunner.h
//  Net Runner
//
//  Created by Philip Dow on 7/19/18.
//  Copyright © 2018 doc.ai. All rights reserved.
//

#import <Foundation/Foundation.h>

@class HeadlessTestBundle;

NS_ASSUME_NONNULL_BEGIN

@interface HeadlessTestBundleRunner : NSObject

@property (readonly) HeadlessTestBundle *testBundle;
@property (readonly) NSArray<NSDictionary*> *results;
@property (readonly) NSArray<NSDictionary*> *summary;

- (instancetype)initWithTestBundle:(HeadlessTestBundle*)testBundle;

- (void)evaluate;

@end

NS_ASSUME_NONNULL_END
