//
//  ImageModelLabelsExportActivityItemProvider.m
//  Net Runner
//
//  Created by Philip Dow on 1/10/19.
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

#import "ImageModelLabelsExportActivityItemProvider.h"
#import "ImageModelLabelsDatabase.h"
#import "ImageModelLabelsExporter.h"

@import SVProgressHUD;

NSURL * ZipFilepathWithIdentifier(NSString * identifier) {
    NSURL *directory = [NSURL fileURLWithPath:NSTemporaryDirectory() isDirectory:YES];
    NSString *filename = [[NSString stringWithFormat:@"%@-labels", identifier] stringByAppendingPathExtension:@"zip"];
    NSURL *filepath = [directory URLByAppendingPathComponent:filename];
    
    return filepath;
}

@interface ImageModelLabelsExportActivityItemProvider()

@property NSURL *zipFilepath;

@end

@implementation ImageModelLabelsExportActivityItemProvider

- (instancetype)initWithDatabase:(ImageModelLabelsDatabase*)database identifier:(nonnull NSString *)identifier {
    NSURL *filepath = ZipFilepathWithIdentifier(identifier);
    if ((self=[super initWithPlaceholderItem:filepath])) {
        _database = database;
        _identifier = identifier;
        _zipFilepath = filepath;
    }
    return self;
}

- (NSString *)activityViewController:(UIActivityViewController *)activityViewController subjectForActivityType:(UIActivityType)activityType {
    return @"Labels Export";
}

- (id)item {
    ImageModelLabelsExporter *exporter = [[ImageModelLabelsExporter alloc] initWithDatabase:self.database];
    
    if ([NSFileManager.defaultManager fileExistsAtPath:self.zipFilepath.path]) {
        [NSFileManager.defaultManager removeItemAtPath:self.zipFilepath.path error:nil];
    }
    
    [SVProgressHUD showWithStatus:@"Preparing Export"];
    
    [exporter exportTo:self.zipFilepath.path];
    
    [SVProgressHUD dismiss];
    
    return self.zipFilepath;
}

@end
