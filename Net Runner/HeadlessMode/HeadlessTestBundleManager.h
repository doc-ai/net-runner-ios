//
//  HeadlessTestBundleManager.h
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

NS_ASSUME_NONNULL_BEGIN

extern NSString * const kTFTestInfoFile;

@class HeadlessTestBundle;

@interface HeadlessTestBundleManager : NSObject

/**
 * All available test bundles. You must call `loadTestBundlesAtPath:error:` before accessing test bundles.
 */

@property (readonly) NSArray<HeadlessTestBundle*> *testBundles;

/**
 * Returns the shared instance of the `HeadlessTestBundleManager`.
 *
 * You may create your own test bundle managers if you require more than one.
 */

+ (instancetype)sharedManager;

/**
 * Loads the available test bundles at the specified path, e.g. folders that end in .testbundle
 * and assigns them to the testBundles property.
 *
 * @param path The path from which to load the test bundles
 * @param error Any error that occurs while loading test bundles. No error is currently set.
 *
 * @return BOOL `YES` if bundles were successfully loaded, `NO` otherwise.
 */

- (BOOL)loadTestBundlesAtPath:(NSString*)path error:(NSError**)error;

@end

NS_ASSUME_NONNULL_END
