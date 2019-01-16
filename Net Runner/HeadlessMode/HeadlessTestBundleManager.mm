//
//  HeadlessTestBundleManager.mm
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

#import "HeadlessTestBundleManager.h"

#import "HeadlessTestBundle.h"

@import TensorIO;

NSString * const kTFTestBundleExtension = @"testbundle";
NSString * const kTFTestInfoFile = @"test.json";

@interface HeadlessTestBundleManager()

@property (readwrite) NSArray<HeadlessTestBundle*> *testBundles;

@end

@implementation HeadlessTestBundleManager

+ (instancetype)sharedManager {
    static dispatch_once_t once;
    static id sharedInstance;

    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (BOOL)loadTestBundlesAtPath:(NSString*)path error:(NSError**)error {
    NSArray<NSString*> *paths = [NSFileManager.defaultManager contentsOfDirectoryAtPath:path error:error];
    
    if (paths == nil) {
        return NO;
    }
    
    NSArray<NSString*> *bundleNames = [paths filter:^BOOL(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        return [[(NSString*)obj pathExtension] isEqualToString:kTFTestBundleExtension];
    }];
    
    NSArray<NSString*> *bundlePaths = [bundleNames map:^id _Nonnull(id _Nonnull obj) {
        return [path stringByAppendingPathComponent:(NSString*)obj];
    }];
    
    NSArray<HeadlessTestBundle*> *bundles = [bundlePaths map:^id _Nonnull(id  _Nonnull obj) {
        return [[HeadlessTestBundle alloc] initWithPath:(NSString*)obj];
    }];
    
    self.testBundles = bundles;
    
    return YES;
}

@end
