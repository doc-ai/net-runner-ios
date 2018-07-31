//
//  HeadlessTestBundleManager.h
//  Net Runner
//
//  Created by Philip Dow on 7/19/18.
//  Copyright © 2018 doc.ai. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString * const kTFTestInfoFile;

@class HeadlessTestBundle;

@interface HeadlessTestBundleManager : NSObject

/**
 * All available test bundles. You must call `loadTestBundlesAtPath:error:` before accessing test bundles.
 */

@property (readonly) NSArray<HeadlessTestBundle*>* testBundles;

/**
 * Returns the shared instance of the HeadlessTestBundleManager.
 * You may create your own test bundle managers if you require more than one.
 */

+ (instancetype)sharedManager;

/**
 * Loads the available test bundles at the specified path, e.g. folders that end in .testbundle
 * and assigns them to the testBundles property.
 */

- (BOOL)loadTestBundlesAtPath:(NSString*)path error:(NSError**)error;

@end

NS_ASSUME_NONNULL_END
