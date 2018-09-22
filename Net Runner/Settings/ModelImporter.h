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

@protocol ModelImporterDelegate

- (void)modelImporterDownloadDidBegin:(ModelImporter*)importer;
- (void)modelImporter:(ModelImporter*)importer downloadDidProgress:(float)progress;
- (void)modelImporter:(ModelImporter*)importer downloadDidFail:(NSError*)error;
- (void)modelImporterDownloadDidFinish:(ModelImporter*)importer;
- (void)modelImporterDidValidate:(ModelImporter*)importer;
- (void)modelImporterDidCompleteImport:(ModelImporter*)importer;
- (void)modelImporterDidCancel:(ModelImporter*)importer;

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
