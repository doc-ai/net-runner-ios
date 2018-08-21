//
//  TIOModelBundleManager.m
//  TensorIO
//
//  Created by Philip Dow on 7/10/18.
//  Copyright © 2018 doc.ai. All rights reserved.
//

#import "TIOModelBundleManager.h"

#import "TIOModelBundle.h"
#import "NSArray+TIOExtensions.h"
#import "TIOModel.h"

@interface TIOModelBundleManager()

@property (readwrite) NSArray<id<TIOModel>>* models;
@property (readwrite) NSArray<TIOModelBundle*> *modelBundles;

@end

@implementation TIOModelBundleManager

+ (instancetype)sharedManager {
    static dispatch_once_t once;
    static id sharedInstance;

    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (BOOL)loadModelBundlesAtPath:(NSString*)path error:(NSError**)error {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSArray<NSString*> *paths = [fileManager contentsOfDirectoryAtPath:path error:error];
    
    if (paths == nil) {
        return NO;
    }
    
    NSArray<NSString*> *bundleNames = [paths filter:^BOOL(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        return [[(NSString*)obj pathExtension] isEqualToString:kTFModelBundleExtension];
    }];
    
    NSArray<NSString*> *bundlePaths = [bundleNames map:^id _Nonnull(id _Nonnull obj) {
        return [path stringByAppendingPathComponent:(NSString*)obj];
    }];
    
    NSArray<id<TIOModel>> *bundles = [bundlePaths map:^id _Nonnull(id  _Nonnull obj) {
        return [[TIOModelBundle alloc] initWithPath:obj];
    }];
    
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(caseInsensitiveCompare:)];
    NSArray<TIOModelBundle*> *sortedBundles = [bundles sortedArrayUsingDescriptors:@[sortDescriptor]];
    
    self.modelBundles = sortedBundles;
    
    return YES;
}

- (nullable TIOModelBundle*)bundleWithId:(NSString*)modelId {
    NSArray *matching = [self.modelBundles filter:^BOOL(TIOModelBundle * _Nonnull bundle, NSUInteger idx, BOOL * _Nonnull stop) {
        return [bundle.identifier isEqualToString:modelId];
    }];
    
    return matching.count == 0 ? nil : matching.firstObject;
}

- (NSArray<TIOModelBundle*>*)bundlesWithIds:(NSArray<NSString*>*)modelIds {
    return [self.modelBundles filter:^BOOL(TIOModelBundle * _Nonnull bundle, NSUInteger idx, BOOL * _Nonnull stop) {
        return [modelIds containsObject:bundle.identifier];
    }];
}

@end
