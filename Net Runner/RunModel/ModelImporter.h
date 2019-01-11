//
//  ModelImporter.h
//  Net Runner
//
//  Created by Phil Dow on 9/21/18.
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

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class ModelImporter;
@class TIOModelBundleValidator;

@protocol ModelImporterDelegate

/**
 * Called when the model importer begins downloading.
 */

- (void)modelImporterDownloadDidBegin:(ModelImporter*)importer;

/**
 * Called when the model importer makes download progress.
 */

- (void)modelImporter:(ModelImporter*)importer downloadDidProgress:(float)progress;

/**
 * Called when the model importer finishes downloading.
 */

- (void)modelImporterDownloadDidFinish:(ModelImporter*)importer;

/**
 * Called when the model importer successfully validates the model.
 */

- (void)modelImporterDidValidate:(ModelImporter*)importer;

/**
 * Called at completion when the model importer is finished importing the model.
 */

- (void)modelImporterDidCompleteImport:(ModelImporter*)importer;

/**
 * Called when the model importer fails for any reason.
 */

- (void)modelImporter:(ModelImporter*)importer importDidFail:(NSError*)error;

/**
 * Called when the model importer is cancelled.
 */

- (void)modelImporterDidCancel:(ModelImporter*)importer;

// TODO: fix custom validation. can't forward declare a block type but can't mix obj-c and obj-c++ headers. stupid

/**
 * Called to provide a custom validator to the model importer.
 */

- (BOOL (^_Nullable)(NSString *path, NSDictionary *JSON, NSError **error))modelImporter:(ModelImporter*)importer validationBlockForModelBundleAtURL:(NSURL*)URL;

@end

// MARK: -

@interface ModelImporter : NSObject

/**
 * The model importer delegate. See the `ModelImporterDelegate` for the required delegate functions.
 */

@property (weak, readonly) id<ModelImporterDelegate> delegate;

/**
 * The directory that the downloaded model will be copied to.
 */

@property (readonly) NSURL *destinationDirectory;

/**
 * The URL contained a zipped .tfbundle that will be downloaded and imported.
 */

@property (readonly) NSURL *URL;

/**
 * The designated initializer.
 *
 * Call `import` to being importing the model. Call `cancel` to cancel the import.
 *
 * @param URL The URL of the model that will be imported.
 * @param delegate An instance conforming to `ModelImporterDelegate` that will be informed of importer progress, success, and failure.
 * @param directory The directory that the imported model will be copied to.
 *
 * @return instancetype Instance of `ModelImporter`.
 */

- (instancetype)initWithURL:(NSURL*)URL delegate:(id<ModelImporterDelegate>)delegate destinationDirectory:(NSURL*)directory NS_DESIGNATED_INITIALIZER;

/**
 * Use the designated initializer.
 */

- (instancetype)init NS_UNAVAILABLE;

/**
 * Begin importing the model.
 */

- (void)import;

/**
 * Cancels downloading the model.
 */

- (void)cancel;

@end

NS_ASSUME_NONNULL_END
