//
//  ModelManager.m
//  Net Runner
//
//  Created by Phil Dow on 9/27/18.
//  Copyright © 2018 doc.ai. All rights reserved.
//

#import "ModelManager.h"

#import "UserDefaults.h"

@import TensorIO;

NSString * const NRModelManagerDidDeleteModelNotification = @"NRModelManagerDidDeleteModelNotification";

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
        @"phenomenal-face-mobilenet-v2-100-224",
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
    
    NSString *selectedModelID = [NSUserDefaults.standardUserDefaults stringForKey:kPrefsSelectedModelID];
    BOOL isSelectedModel = [selectedModelID isEqualToString:modelBundle.identifier];
    NSFileManager *fm = NSFileManager.defaultManager;
    
    // Remove the model and send errors back to the client
    
    if ( ![fm removeItemAtPath:modelBundle.path error:error] ) {
        NSLog(@"Unable to remove model at path: %@, error: %@", modelBundle.path, *error);
        return NO;
    }
    
    // Reload models
    
    if ( ![TIOModelBundleManager.sharedManager loadModelBundlesAtPath:self.modelsPath error:error] ) {
        NSLog(@"Unable to load model bundles at path %@, error: %@", self.modelsPath, *error);
        return NO;
    }
    
    // Reset the selected model if the selected model was deleted
    
    if ( isSelectedModel ) {
        [NSUserDefaults.standardUserDefaults setObject:kPresDefaultModelID forKey:kPrefsSelectedModelID];
    }
    
    // Inform listeners
    
    [NSNotificationCenter.defaultCenter postNotificationName:NRModelManagerDidDeleteModelNotification object:self userInfo:@{
        @"model": modelBundle
    }];
    
    return YES;
}

@end
