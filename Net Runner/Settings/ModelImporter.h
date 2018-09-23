//
//  ModelImporter.h
//  Net Runner
//
//  Created by Phil Dow on 9/21/18.
//  Copyright © 2018 doc.ai. All rights reserved.
//

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
