//
//  AddModelTableViewController.m
//  Net Runner
//
//  Created by Philip Dow on 9/12/18.
//  Copyright © 2018 doc.ai. All rights reserved.
//

#import "AddModelTableViewController.h"

#import <SSZipArchive/SSZipArchive.h>
@import TensorIO;

@interface AddModelTableViewController () <NSURLSessionDownloadDelegate>

@end

@implementation AddModelTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelAddModel:)];
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
}

// MARK: - Table View Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

// MARK: - Text Field Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

// MARK: - User Interaction

- (IBAction)cancelAddModel:(id)sender {
    [self resignFirstResponder];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)visitNetRunnerRepository:(id)sender {
    [UIApplication.sharedApplication openURL:[NSURL URLWithString:@"https://github.com/doc-ai/net-runner-ios"]];
}

- (IBAction)importModel:(id)sender {
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
    NSURL *URL = [NSURL URLWithString:@"http://localhost:8000/my-model.tfbundle.zip"];
    NSURLSessionDownloadTask *task = [session downloadTaskWithURL:URL];
    
    [task resume];
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location {
    
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
        NSURL *modelDestination = [[NSURL fileURLWithPath:[self modelsPath]] URLByAppendingPathComponent:contents[0]];
        
        // TODO: perform model validation
        
        if ( [fm fileExistsAtPath:modelDestination.path] ) {
            NSLog(@"Model with the folder name %@ already exists in the models directory", modelFilename);
            return;
        }
        
        if ( ![fm moveItemAtURL:modelSource toURL:modelDestination error:&error] ) {
            NSLog(@"Unable to copy model folder from %@ to %@, error %@", modelSource, modelDestination, error);
            return;
        }
        
        // Reload the model bundles
        
        if ( ![TIOModelBundleManager.sharedManager loadModelBundlesAtPath:[self modelsPath] error:&error] ) {
            NSLog(@"Unable to load model bundles at path %@", [self modelsPath]);
        }
        
        // Refresh the model delegate
    }];
    
    
}

- (NSString*) modelsPath {
    NSURL *documentDirectoryURL = [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains: NSUserDomainMask][0];
    NSString *documentDirectoryPath = [documentDirectoryURL path];
    NSString *modelsPath = [documentDirectoryPath stringByAppendingPathComponent:@"models"];
    return modelsPath;
}

@end
