//
//  ModelManager.m
//  Net Runner
//
//  Created by Phil Dow on 9/27/18.
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
    
    // Inform listeners
    
    [NSNotificationCenter.defaultCenter postNotificationName:NRModelManagerDidDeleteModelNotification object:self userInfo:@{
        @"model": modelBundle
    }];
    
    return YES;
}

@end
