//
//  AddModelTableViewController.m
//  Net Runner
//
//  Created by Philip Dow on 9/12/18.
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

#import "AddModelTableViewController.h"

#import "ModelImporter.h"
#import "ModelManager.h"

#import <SSZipArchive/SSZipArchive.h>
@import TensorIO;

static NSString * const NetRunnerGitHubRepository = @"https://github.com/doc-ai/net-runner-ios";

// MARK: - Errors

static NSString * const NetRunnerAddModelErrorDomain = @"ai.doc.net-runner.add-model";

NSError * NetRunnerAddModelInvalidURLError() {
    return [[NSError alloc] initWithDomain:NetRunnerAddModelErrorDomain code:101 userInfo:@{
        NSLocalizedDescriptionKey: [NSString stringWithFormat:@"The URL is invalid."],
        NSLocalizedRecoverySuggestionErrorKey: @"Please enter a valid URL. Make sure to include the http or https scheme."
    }];
}

NSError * NetRunnerModelInputsError() {
    return [[NSError alloc] initWithDomain:NetRunnerAddModelErrorDomain code:102 userInfo:@{
        NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Net Runner cannot use this model."],
        NSLocalizedRecoverySuggestionErrorKey: @"Net Runner models must take a single input of type image."
    }];
}

NSError * NetRunnerImageShapeError() {
    return [[NSError alloc] initWithDomain:NetRunnerAddModelErrorDomain code:103 userInfo:@{
        NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Net Runner cannot use this model."],
        NSLocalizedRecoverySuggestionErrorKey: @"Net Runner image inputs must have an image shape with three elements whose last element is 3 dimensions, corresponding to 3 color channels in height-width-channels ordering."
    }];
}

NSError * NetRunnerReloadModelsError() {
    return [[NSError alloc] initWithDomain:NetRunnerAddModelErrorDomain code:104 userInfo:@{
        NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Net Runner was unable to reload the models."],
        NSLocalizedRecoverySuggestionErrorKey: @"Restart Net Runner and try again."
    }];
}

// MARK: -

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
    [UIApplication.sharedApplication openURL:[NSURL URLWithString:NetRunnerGitHubRepository] options:@{} completionHandler:nil];
}

- (IBAction)importModel:(id)sender {
    
    if ( self.URLField.text.length == 0 ) {
        NSLog(@"Enter a URL");
        [self showError:NetRunnerAddModelInvalidURLError()];
        return;
    }
    
    NSURL *URL = [NSURL URLWithString:self.URLField.text];
    
    if ( URL == nil || URL.scheme == nil || URL.host == nil ) {
        NSLog(@"Invalid URL");
        [self showError:NetRunnerAddModelInvalidURLError()];
        return;
    }
    
    if ( self.importer != nil ) {
        [self.importer cancel];
        self.importer = nil;
    }
    
    NSURL *destination = [NSURL fileURLWithPath:ModelManager.sharedManager.modelsPath];
    
    self.importer = [[ModelImporter alloc]
        initWithURL:URL
        delegate:self
        destinationDirectory:destination];
    
    [self.importer import];
}

// MARK: - Model Importer Delegate

- (BOOL (^_Nullable)(NSString *path, NSDictionary *JSON, NSError **error))modelImporter:(ModelImporter*)importer validationBlockForModelBundleAtURL:(NSURL*)URL {
    
    // Net Runner requires a single input that is of type "image",
    // whose "shape" is 3 elements with the last element being 3 for three color channels
    
    return ^BOOL(NSString *path, NSDictionary *JSON, NSError **error) {
        
        NSArray *inputs = JSON[@"inputs"];
        
        if ( inputs.count != 1 ) {
            *error = NetRunnerModelInputsError();
            return NO;
        }
        
        NSDictionary *input = inputs[0];
        
        if ( ![input[@"type"] isEqualToString:@"image"] ) {
            *error = NetRunnerModelInputsError();
            return NO;
        }
        
        if ( [input[@"shape"] count] != 3 || [input[@"shape"][2] integerValue] != 3 ) {
            *error = NetRunnerImageShapeError();
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
        self.downloadProgressView.hidden = YES;
        self.downloadLabel.hidden = YES;
        
        [self showError:error];
    });
}

- (void)modelImporterDownloadDidFinish:(ModelImporter*)importer {
    NSLog(@"Importer Did Finish Download");
}

- (void)modelImporterDidValidate:(ModelImporter*)importer {
    NSLog(@"Importer Did Validate");
}

- (void)modelImporterDidCompleteImport:(ModelImporter*)importer {
    NSLog(@"Importer Did Complete Import");
    
    self.importer = nil;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.downloadProgressView.hidden = YES;
        self.downloadLabel.hidden = YES;
    });
    
    // Reload the model bundles
    
    NSError *error;
    
    if ( ![TIOModelBundleManager.sharedManager loadModelBundlesAtPath:ModelManager.sharedManager.modelsPath error:&error] ) {
        NSLog(@"Unable to load model bundles at path %@", ModelManager.sharedManager.modelsPath);
        [self showError:NetRunnerReloadModelsError()];
        return;
    }

    dispatch_async(dispatch_get_main_queue(), ^{
        
        // Inform delegate import is successful
        
        [self.delegate addModelTableViewControllerDidAddModel:self];
        
        // Success alert
        
        NSString *message = NSLocalizedString(@"The model was sucessfully imported and is available for selection in the model list", @"model imported success message");
        NSString *title = NSLocalizedString(@"Model Imported", @"model imported success title");
    
        UIAlertController *alert = [UIAlertController
            alertControllerWithTitle:title
            message:message
            preferredStyle:UIAlertControllerStyleAlert];
        
        [alert addAction:[UIAlertAction
            actionWithTitle:NSLocalizedString(@"Dismiss", @"Alert dismiss action")
            style:UIAlertActionStyleDefault
            handler:^(UIAlertAction * _Nonnull action) {
                [self dismissViewControllerAnimated:YES completion:nil];
            }]];
        
        [self presentViewController:alert animated:YES completion:nil];
    });
}

- (void)modelImporterDidCancel:(ModelImporter*)importer {
    NSLog(@"Importer Did Cancel");
    
    self.importer = nil;
}

// MARK: -

- (void)showError:(NSError*)error {
    NSString *description = error.localizedDescription;
    NSString *recovery = error.localizedRecoverySuggestion;

    if ( description == nil || description.length == 0 ) {
        description = @"";
    }

    if ( recovery == nil || recovery.length == 0 ) {
        recovery = @"";
    }

    NSString *message = [[[description stringByAppendingString:@"\n\n"] stringByAppendingString:recovery] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *title = NSLocalizedString(@"Problem Importing Model", @"Import model error alert title");

    UIAlertController *alert = [UIAlertController
        alertControllerWithTitle:title
        message:message
        preferredStyle:UIAlertControllerStyleAlert];

    [alert addAction:[UIAlertAction
        actionWithTitle:NSLocalizedString(@"Dismiss", @"Alert dismiss action")
        style:UIAlertActionStyleDefault
        handler:nil]];

    [self presentViewController:alert animated:YES completion:nil];
}

@end
