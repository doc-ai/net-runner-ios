//
//  AddModelTableViewController.m
//  Net Runner
//
//  Created by Philip Dow on 9/12/18.
//  Copyright © 2018 doc.ai. All rights reserved.
//

#import "AddModelTableViewController.h"

#import "ModelImporter.h"

#import <SSZipArchive/SSZipArchive.h>
@import TensorIO;

@interface AddModelTableViewController () <ModelImporterDelegate>

@property ModelImporter *importer;

@end

@implementation AddModelTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelAddModel:)];
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    self.downloadLabel.hidden = YES;
    self.downloadProgressView.hidden = YES;
    self.validatedLabel.hidden = YES;
    self.savedLabel.hidden = YES;
    self.completedLabel.hidden = YES;
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
    
    if ( self.URLField.text.length == 0 ) {
        NSLog(@"Enter a URL");
        return;
    }
    
    NSURL *URL = [NSURL URLWithString:self.URLField.text]; // @"http://localhost:8000/my-model.tfbundle.zip"
    
    if ( URL == nil ) {
        NSLog(@"Invalid URL");
        return;
    }
    
    if ( self.importer != nil ) {
        [self.importer cancel];
        self.importer = nil;
    }
    
    self.importer = [[ModelImporter alloc] initWithURL:URL delegate:self destinationDirectory:[NSURL fileURLWithPath:[self modelsPath]]];
    
    [self.importer download];
}

// MARK: - Model Importer Delegate

- (BOOL (^_Nonnull)(NSString *path, NSDictionary *JSON, NSError **error))modelImporter:(ModelImporter*)importer validationBlockForModelBundleAtURL:(NSURL*)URL {
    
    // TODO: Yuck
    
    // Net Runner requires a single input that is of type "image"
    
    return ^BOOL(NSString *path, NSDictionary *JSON, NSError **error) {
        
        NSArray *inputs = JSON[@"inputs"];
        
        if ( inputs.count != 1 ) {
            // *error =
            return NO;
        }
        
        NSDictionary *input = inputs[0];
        
        if ( ![input[@"type"] isEqualToString:@"image"] ) {
            // *error =
            return NO;
        }
        
        return YES;
    };
}

- (void)modelImporterDownloadDidBegin:(ModelImporter*)importer {
    NSLog(@"Importer Did Begin Download");
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.downloadProgressView.hidden = NO;
        self.downloadProgressView.progress = 0;
        self.downloadLabel.hidden = NO;
    });
}

- (void)modelImporter:(ModelImporter*)importer downloadDidProgress:(float)progress {
    NSLog(@"Importer Did Progress");
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.downloadProgressView setProgress:progress animated:YES];
    });
}

- (void)modelImporter:(ModelImporter*)importer importDidFail:(NSError*)error {
    NSLog(@"Importer Download Failed: %@", error);
    
    dispatch_async(dispatch_get_main_queue(), ^{
    
        UIAlertController *alert = [UIAlertController
            alertControllerWithTitle:NSLocalizedString(@"Problem Importing Model", @"Import model error alert title")
            message:NSLocalizedString(@"...", @"Import model error alert message")
            preferredStyle:UIAlertControllerStyleAlert];
        
        [alert addAction:[UIAlertAction
            actionWithTitle:NSLocalizedString(@"Dismiss", @"Alert dismiss action")
            style:UIAlertActionStyleDefault
            handler:nil]];
        
        [self presentViewController:alert animated:YES completion:nil];
    
    });
}

- (void)modelImporterDownloadDidFinish:(ModelImporter*)importer {
    NSLog(@"Importer Did Finish Download");
    
}

- (void)modelImporterDidValidate:(ModelImporter*)importer {
    NSLog(@"Importer Did Validate");
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.validatedLabel.hidden = NO;
    });
}

- (void)modelImporterDidCompleteImport:(ModelImporter*)importer {
    NSLog(@"Importer Did Complete Import");
    self.importer = nil;
    
    // Reload the model bundles
    
    NSError *error;
    
    if ( ![TIOModelBundleManager.sharedManager loadModelBundlesAtPath:[self modelsPath] error:&error] ) {
        NSLog(@"Unable to load model bundles at path %@", [self modelsPath]);
        return;
    }
    
    // Refresh the model delegate
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.savedLabel.hidden = NO;
        self.completedLabel.hidden = NO;
    });
}

- (void)modelImporterDidCancel:(ModelImporter*)importer {
    NSLog(@"Importer Did Cancel");
    self.importer = nil;
}

// MARK: -

// TODO: Duplicated in AppDelegate

- (NSString*)modelsPath {
    NSURL *documentDirectoryURL = [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains: NSUserDomainMask][0];
    NSString *documentDirectoryPath = [documentDirectoryURL path];
    NSString *modelsPath = [documentDirectoryPath stringByAppendingPathComponent:@"models"];
    return modelsPath;
}

@end
