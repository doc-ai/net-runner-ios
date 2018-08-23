//
//  HeadlessTestBundleRunner.h
//  Net Runner
//
//  Created by Philip Dow on 7/19/18.
//  Copyright © 2018 doc.ai (http://doc.ai)
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

@import Foundation;

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
