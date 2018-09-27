//
//  ModelManager.m
//  Net Runner
//
//  Created by Phil Dow on 9/27/18.
//  Copyright © 2018 doc.ai. All rights reserved.
//

#import "ModelManager.h"

@implementation ModelManager

+ (instancetype)sharedManager {
    static dispatch_once_t once;
    static id sharedInstance;

    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (NSArray<NSString*>*)defaultModelIDs {
    return @[
        @"mobilenet-v2-100-224-unquantized",
        @"mobilenet-v1-100-224-quantized",
        @"mobilenet-v1-100-224-unquantized",
        @"mobilenet-v1-100-128-quantized",
        @"",
    ];
}

// MARK: - Model Directories

- (NSString*)initialModelsPath {
    return [[NSBundle mainBundle] pathForResource:@"models" ofType:nil];
}

- (NSString*)modelsPath {
    NSURL *documentDirectoryURL = [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains: NSUserDomainMask][0];
    NSString *documentDirectoryPath = [documentDirectoryURL path];
    NSString *modelsPath = [documentDirectoryPath stringByAppendingPathComponent:@"models"];
    return modelsPath;
}

// MARK: - Activity

- (BOOL)deleteModel:(TIOModelBundle*)modelBundle error:(NSError**)error {
    return YES;
}

@end
