//
//  ModelImporter.m
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

#import "ModelImporter.h"

#import <SSZipArchive/SSZipArchive.h>
@import TensorIO;

// MARK: - Errors

static NSString * const NetRunnerModelImporterErrorDomain = @"ai.doc.net-runner.model-importer";

static const NSInteger NetRunnerModelImporterHTTPErrorCode          = 101;
static const NSInteger NetRunnerModelImporterUnzipErrorCode         = 102;
static const NSInteger NetRunnerModelImporterContentsErrorCode      = 103;
static const NSInteger NetRunnerModelImporterFileSystemErrorCode    = 104;

NSError * NetRunnerModelImporterHTTPError();
NSError * NetRunnerModelImporterUnzipError();
NSError * NetRunnerModelImporterContentsError();
NSError * NetRunnerModelImporterFileSystemError();

// MARK: -

@interface ModelImporter() <NSURLSessionDownloadDelegate>

@property NSURLSessionDownloadTask *downloadTask;

@end

@implementation ModelImporter

- (instancetype)initWithURL:(NSURL*)URL delegate:(id<ModelImporterDelegate>)delegate destinationDirectory:(NSURL*)directory {
    if (self = [super init]) {
        _destinationDirectory = directory;
        _delegate = delegate;
        _URL = URL;
    }
    return self;
}

- (void)import {
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
    
    _downloadTask = [session downloadTaskWithURL:_URL];
    [_downloadTask resume];
    
    [self.delegate modelImporterDownloadDidBegin:self];
}

- (void)cancel {
    [_downloadTask cancel];
    [self.delegate modelImporterDidCancel:self];
}

// MARK: - NSURLSession Delegate

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location {
    
    NSFileManager *fm = [NSFileManager defaultManager];
    
    tio_defer_block {
        [fm removeItemAtURL:location error:nil];
    };
    
    // HTTP Error
    
    if ( [downloadTask.response isKindOfClass:[NSHTTPURLResponse class]] && ((NSHTTPURLResponse*)downloadTask.response).statusCode != 200 ) {
        NSLog(@"HTTP Response Error: %@", downloadTask.response);
        [self.delegate modelImporter:self importDidFail:NetRunnerModelImporterHTTPError()];
        return;
    }
    
    // Inform delegate we are finished downloading
    
    [self.delegate modelImporterDownloadDidFinish:self];
    
    // Prepare to unzip file
    
    NSURL *unzipDestination = [[location URLByDeletingLastPathComponent] URLByAppendingPathComponent:@"unzipped"];
    
    // Unzip file
    
    [SSZipArchive unzipFileAtPath:location.path toDestination:unzipDestination.path progressHandler:nil completionHandler:^(NSString * _Nonnull path, BOOL succeeded, NSError * _Nullable error) {
        
        tio_defer_block {
            [fm removeItemAtURL:unzipDestination error:nil];
        };
        
        // Report unzip errors
        
        if ( error ) {
            NSLog(@"Unzip error: %@ %@ %@", location, unzipDestination, error);
            [self.delegate modelImporter:self importDidFail:NetRunnerModelImporterUnzipError()];
            return;
        }
        
        NSLog(@"Unzipped to %@", unzipDestination);
        
        if ( ![fm fileExistsAtPath:unzipDestination.path] ) {
            NSLog(@"Unzipped file does not exist at %@", unzipDestination);
            [self.delegate modelImporter:self importDidFail:NetRunnerModelImporterUnzipError()];
            return;
        }
        
        // Confirm unzipped contents are valid
        
        NSArray *contents = [fm contentsOfDirectoryAtPath:unzipDestination.path error:&error];
        
        if ( contents == nil && error ) {
            NSLog(@"No contents at %@", unzipDestination);
            [self.delegate modelImporter:self importDidFail:NetRunnerModelImporterContentsError()];
            return;
        }
        
        if ( contents.count != 1 ) {
            NSLog(@"Too many files in zipped folder: %@", contents);
            [self.delegate modelImporter:self importDidFail:NetRunnerModelImporterContentsError()];
            return;
        }
        
        // Prepare to copy download to destination directory
        
        NSString *modelFilename = contents[0];
        NSURL *modelSource = [unzipDestination URLByAppendingPathComponent:contents[0]];
        NSURL *modelDestination = [self.destinationDirectory URLByAppendingPathComponent:contents[0]];
        
        // Perform custom validation
        
        TIOModelBundleValidationBlock validationBlock = [self.delegate modelImporter:self validationBlockForModelBundleAtURL:modelSource];
        TIOModelBundleValidator *validator = [[TIOModelBundleValidator alloc] initWithModelBundleAtPath:modelSource.path];
        
        if ( ![validator validate:validationBlock error:&error] ) {
            NSLog(@"Custom validator failed: %@", error);
            [self.delegate modelImporter:self importDidFail:error];
            return;
        }
        
        [self.delegate modelImporterDidValidate:self];
        
        // TODO: decide on policy when the target model folder already exists
        // If model folder already exists at destination, remove it
        
        if ( [fm fileExistsAtPath:modelDestination.path] ) {
            NSLog(@"Model with the folder name %@ already exists in the models directory", modelFilename);
            
            if ( ![fm removeItemAtURL:modelDestination error:&error] ) {
                NSLog(@"FM Error: %@", error);
                [self.delegate modelImporter:self importDidFail:NetRunnerModelImporterFileSystemError()];
                return;
            }
        }
        
        // Copy to Destination
        
        if ( ![fm moveItemAtURL:modelSource toURL:modelDestination error:&error] ) {
            NSLog(@"Unable to copy model folder from %@ to %@, error %@", modelSource, modelDestination, error);
            [self.delegate modelImporter:self importDidFail:NetRunnerModelImporterFileSystemError()];
            return;
        }
        
        // Inform deletate we are done
        
        [self.delegate modelImporterDidCompleteImport:self];
    }];
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    
    float progress = (float)totalBytesWritten / (float)totalBytesExpectedToWrite;
    [self.delegate modelImporter:self downloadDidProgress:progress];
}

@end

// MARK: - Errors

NSError * NetRunnerModelImporterHTTPError() {
    return [[NSError alloc] initWithDomain:NetRunnerModelImporterErrorDomain code:NetRunnerModelImporterHTTPErrorCode userInfo:@{
        NSLocalizedDescriptionKey: [NSString stringWithFormat:@"There was a problem requesting the file from the server."],
        NSLocalizedRecoverySuggestionErrorKey: @"Make sure the URL points to a file that exists and that you have permission to access that file."
    }];
}

NSError * NetRunnerModelImporterUnzipError() {
    return [[NSError alloc] initWithDomain:NetRunnerModelImporterErrorDomain code:NetRunnerModelImporterUnzipErrorCode userInfo:@{
        NSLocalizedDescriptionKey: [NSString stringWithFormat:@"There was a problem unzipping the downloaded file."],
        NSLocalizedRecoverySuggestionErrorKey: @"Make sure you are importing a model directory (e.g. a .tfbundle folder) that has been zipped using a utility like gzip or the Finder's \"Compress\" option."
    }];
}

NSError * NetRunnerModelImporterContentsError() {
    return [[NSError alloc] initWithDomain:NetRunnerModelImporterErrorDomain code:NetRunnerModelImporterContentsErrorCode userInfo:@{
        NSLocalizedDescriptionKey: [NSString stringWithFormat:@"There was a problem unzipping the downloaded file."],
        NSLocalizedRecoverySuggestionErrorKey: @"Make sure you are importing a model directory (e.g. a .tfbundle folder) that has been zipped using a utility like gzip or the Finder's \"Compress\" option."
    }];
}

NSError * NetRunnerModelImporterFileSystemError() {
    return [[NSError alloc] initWithDomain:NetRunnerModelImporterErrorDomain code:NetRunnerModelImporterFileSystemErrorCode userInfo:@{
        NSLocalizedDescriptionKey: [NSString stringWithFormat:@"There was a moving or copying the downloaded model."],
        NSLocalizedRecoverySuggestionErrorKey: @"Make sure you have enough space on your device for the model. Some models are quite large."
    }];
}
