//
//  ModelImporter.h
//  Net Runner
//
//  Created by Phil Dow on 9/21/18.
//  Copyright © 2018 doc.ai. All rights reserved.
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

// TODO: add documentation

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class ModelImporter;
@class TIOModelBundleValidator;

@protocol ModelImporterDelegate

- (void)modelImporterDownloadDidBegin:(ModelImporter*)importer;
- (void)modelImporter:(ModelImporter*)importer downloadDidProgress:(float)progress;
- (void)modelImporterDownloadDidFinish:(ModelImporter*)importer;
- (void)modelImporterDidValidate:(ModelImporter*)importer;
- (void)modelImporterDidCompleteImport:(ModelImporter*)importer;
- (void)modelImporter:(ModelImporter*)importer importDidFail:(NSError*)error;
- (void)modelImporterDidCancel:(ModelImporter*)importer;

// TODO: fix custom validation. can't forward declare a block type but can't mix obj-c and obj-c++ headers. stupid

- (BOOL (^_Nonnull)(NSString *path, NSDictionary *JSON, NSError **error))modelImporter:(ModelImporter*)importer validationBlockForModelBundleAtURL:(NSURL*)URL;

@end

// MARK: -

@interface ModelImporter : NSObject

@property (readonly) id<ModelImporterDelegate> delegate;
@property (readonly) NSURL *destinationDirectory;
@property (readonly) NSURL *URL;

- (instancetype)initWithURL:(NSURL*)URL delegate:(id<ModelImporterDelegate>)delegate destinationDirectory:(NSURL*)directory NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;

- (void)download;
- (void)cancel;

@end

NS_ASSUME_NONNULL_END
