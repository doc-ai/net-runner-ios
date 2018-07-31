//
//  HeadlessTestBundleManager.m
//  Net Runner
//
//  Created by Philip Dow on 7/19/18.
//  Copyright © 2018 doc.ai. All rights reserved.
//

#import "HeadlessTestBundleManager.h"

#import "HeadlessTestBundle.h"
#import "NSArray+Extensions.h"

NSString * const kTFTestBundleExtension = @"testbundle";
NSString * const kTFTestInfoFile = @"test.json";

@interface HeadlessTestBundleManager()

@property (readwrite) NSArray<HeadlessTestBundle*>* testBundles;

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
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSArray<NSString*> *paths = [fileManager contentsOfDirectoryAtPath:path error:error];
    
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
