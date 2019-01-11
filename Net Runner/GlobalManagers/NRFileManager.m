//
//  NRFileManager.m
//  Net Runner
//
//  Created by Philip Dow on 1/8/19.
//  Copyright © 2019 doc.ai (http://doc.ai)
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

#import "NRFileManager.h"

@implementation NRFileManager

+ (instancetype)sharedManager {
    static dispatch_once_t once;
    static id sharedInstance;

    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

- (NSString*)labelDatabasesDirectory {
    NSFileManager *fm = NSFileManager.defaultManager;
    NSURL *documentDirectoryURL = [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask][0];
    NSString *documentDirectoryPath = [documentDirectoryURL path];
    NSString *labelsPath = [documentDirectoryPath stringByAppendingPathComponent:@"labels"];
    NSError *fileError;
    
    if (![fm fileExistsAtPath:labelsPath] && ![fm createDirectoryAtPath:labelsPath withIntermediateDirectories:NO attributes:nil error:&fileError]) {
        NSLog(@"Unable to create label databases directory at path %@, error: %@", labelsPath, fileError);
    }
    
    return labelsPath;
}

@end
