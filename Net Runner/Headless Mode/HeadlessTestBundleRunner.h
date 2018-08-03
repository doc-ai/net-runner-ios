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

/**
 * The test bundle that will be executed.
 */

@property (readonly) HeadlessTestBundle *testBundle;

/**
 * All the evaluation results from running the test.
 */

@property (readonly) NSArray<NSDictionary<NSString*, id>*> *results;

/**
 * The summary statistics from running the test.
 */

@property (readonly) NSArray<NSDictionary<NSString*, id>*> *summary;

/**
 * Instantiates a test bundle runner with the provided test bundle. Call `evaluate` to actually
 * run the tests.
 *
 * @param testBundle The test bundle that will be run.
 *
 * @return HeadlessTestBundleRunner
 */

- (instancetype)initWithTestBundle:(HeadlessTestBundle*)testBundle NS_DESIGNATED_INITIALIZER;

/**
 * Use the designated initializer.
 */

- (instancetype)init NS_UNAVAILABLE;

/**
 * Actually runs the test and evaluation metrics on the provided test bundle.
 *
 * After evaluation is completed you may inspect `results` and `summary`.
 */

- (void)evaluate;

@end

NS_ASSUME_NONNULL_END
