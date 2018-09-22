//
//  ModelImporter.m
//  Net Runner
//
//  Created by Phil Dow on 9/21/18.
//  Copyright © 2018 doc.ai. All rights reserved.
//

#import "ModelImporter.h"

#import <SSZipArchive/SSZipArchive.h>
@import TensorIO;

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

- (void)download {
    
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
    
    if ( [downloadTask.response isKindOfClass:[NSHTTPURLResponse class]] && ((NSHTTPURLResponse*)downloadTask.response).statusCode != 200 ) {
        [self.delegate modelImporter:self downloadDidFail:nil];
        return;
    }
    
    [self.delegate modelImporterDownloadDidFinish:self];
    
    NSLog(@"Location: %@", location);
    
    NSURL *unzipDestination = [[location URLByDeletingLastPathComponent] URLByAppendingPathComponent:@"unzipped"];
    NSURL *zipDestination = [[location URLByDeletingPathExtension] URLByAppendingPathExtension:@"zip"];
    
    NSFileManager *fm = [NSFileManager defaultManager];
    NSError *error;
    
    if ( [fm fileExistsAtPath:zipDestination.path] && ![fm removeItemAtURL:zipDestination error:&error] ) {
        NSLog(@"FM Error: %@", error);
        return;
    }
    
    if ( [fm fileExistsAtPath:unzipDestination.path] && ![fm removeItemAtURL:unzipDestination error:&error] ) {
        NSLog(@"FM Error: %@", error);
        return;
    }
    
    if ( ![fm moveItemAtURL:location toURL:zipDestination error:&error] ) {
        NSLog(@"FM Error: %@", error);
        return;
    }
    
    [SSZipArchive unzipFileAtPath:zipDestination.path toDestination:unzipDestination.path progressHandler:^(NSString * _Nonnull entry, unz_file_info zipInfo, long entryNumber, long total) {

        ;

    } completionHandler:^(NSString * _Nonnull path, BOOL succeeded, NSError * _Nullable error) {
        if ( error ) {
            NSLog(@"Unzip error: %@ %@ %@", zipDestination, unzipDestination, error);
            return;
        }
        
        NSLog(@"Unzipped to %@", unzipDestination);
        
        if ( ![fm fileExistsAtPath:unzipDestination.path] ) {
            NSLog(@"Unzipped file does not exist at %@", unzipDestination);
            return;
        }
        
        NSArray *contents = [fm contentsOfDirectoryAtPath:unzipDestination.path error:&error];
        
        if ( contents == nil && error ) {
            NSLog(@"No contents at %@", unzipDestination);
            return;
        }
        
        if ( contents.count != 1 ) {
            NSLog(@"Too many files in zipped folder: %@", contents);
            return;
        }
        
        NSString *modelFilename = contents[0];
        NSURL *modelSource = [unzipDestination URLByAppendingPathComponent:contents[0]];
        NSURL *modelDestination = [self.destinationDirectory URLByAppendingPathComponent:contents[0]];
        
        // TODO: perform model validation
        
        [self.delegate modelImporterDidValidate:self];
        
        if ( [fm fileExistsAtPath:modelDestination.path] ) {
            NSLog(@"Model with the folder name %@ already exists in the models directory", modelFilename);
            
            // Temporarily remove it for testing
            
            if ( ![fm removeItemAtURL:modelDestination error:&error] ) {
                NSLog(@"FM Error: %@", error);
                return;
            }
        }
        
        if ( ![fm moveItemAtURL:modelSource toURL:modelDestination error:&error] ) {
            NSLog(@"Unable to copy model folder from %@ to %@, error %@", modelSource, modelDestination, error);
            return;
        }
        
        [self.delegate modelImporterDidCompleteImport:self];
    }];
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    
    float progress = (float)totalBytesWritten / (float)totalBytesExpectedToWrite;
    [self.delegate modelImporter:self downloadDidProgress:progress];
}

@end
