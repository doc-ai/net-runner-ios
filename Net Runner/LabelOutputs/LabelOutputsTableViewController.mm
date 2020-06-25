//
//  LabelOutputsTableViewController.m
//  Net Runner
//
//  Created by Philip Dow on 12/17/18.
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

#import "LabelOutputsTableViewController.h"

#import "LabelOutputTableViewCell.h"
#import "NumericLabelTableViewCell.h"
#import "TextLabelTableViewCell.h"

//  Note that we are coupling generic labeling to models of a particular type (images)
//  A future iteration will add a ModelLabels protocol that supports the basic get and set label
//  methods and then we can reuse some of this interface across models of many types

#import "NRFileManager.h"
#import "ImageModelLabelsDatabase.h"
#import "ImageModelLabels.h"

@import SVProgressHUD;
@import TensorIO;

@interface LabelOutputsTableViewController () <LabelOutputTableViewCellDelegate>

@property (nonatomic, readwrite) UIImage *image;
@property id<TIOModel> model;

@property ImageModelLabelsDatabase *labelsDatabase;
@property ImageModelLabels *labels;

@property (readonly) BOOL hasError;
@property NSArray<NSString*> *errors;

@end

@implementation LabelOutputsTableViewController

+ (PHImageRequestOptions*)imageRequestOptions {
    static PHImageRequestOptions *options = nil;
    
    if ( options != nil ) {
        return options;
    }
    
    options = [[PHImageRequestOptions alloc] init];
    
    if ( @available(iOS 13.0, *) ) {
        options.resizeMode = PHImageRequestOptionsResizeModeNone;
        options.synchronous = NO;
    } else {
        options.resizeMode = PHImageRequestOptionsResizeModeExact;
        options.synchronous = YES;
    }
    
    options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    options.networkAccessAllowed = YES;
    
    return options;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // View Setup
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 68.0;
    
    // Load Image
    
    CGSize targetSize = PHImageManagerMaximumSize;
    PHImageContentMode contentMode = PHImageContentModeAspectFill;
    
    if ( @available(iOS 13.0, *) ) {
        targetSize = CGSizeMake(self.asset.pixelWidth, self.asset.pixelHeight);
        contentMode = PHImageContentModeDefault;
    }
    
    [self.activityIndicator startAnimating];
    
    [self.imageManager
        requestImageForAsset:self.asset
        targetSize:targetSize
        contentMode:contentMode
        options:[LabelOutputsTableViewController imageRequestOptions]
        resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        
            [self.activityIndicator stopAnimating];
        
            if ( result == nil ) {
                NSLog(@"Unable to request image for asset %@", self.asset.localIdentifier);
                return;
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                self.image = result;
            });
    }];
    
    // Load Model
    
    self.model = self.modelBundle.newModel;
    
    // Load Database and Labels
    
    self.labelsDatabase = [[ImageModelLabelsDatabase alloc] initWithModel:self.model basepath:NRFileManager.sharedManager.labelDatabasesDirectory];
    self.labels = [self.labelsDatabase labelsForImageWithID:self.asset.localIdentifier];
    
    // No initial errors
    
    self.errors = [[NSArray alloc] init];
}

- (void)setImage:(UIImage *)image {
    _image = image;
    
    self.imageView.image = _image;
}

- (BOOL)hasError {
    return self.errors.count != 0;
}

- (void)showErrorAlert {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Cannot Save Labels" message:@"Please correct the listed errors before saving." preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"Dismiss" style:UIAlertActionStyleDefault handler:nil]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

// MARK: - User Actions

- (IBAction)clearLabels:(id)sender {
    [self.labels remove];
    
    self.labels = [self.labelsDatabase labelsForImageWithID:self.asset.localIdentifier];
    [self.tableView reloadData];
    
    [SVProgressHUD showSuccessWithStatus:@"Labels cleared"];
}

- (IBAction)cancel:(id)sender {
    [self.view endEditing:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)save:(id)sender {
    [self.view endEditing:YES];
    
    if (self.hasError) {
        [self showErrorAlert];
        return;
    }
    
    [self.labels save];
    [self dismissViewControllerAnimated:YES completion:nil];
}

// MARK: - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.model.io.outputs.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    __block UITableViewCell<LabelOutputTableViewCell> *cell;
 
    TIOLayerInterface *layer = self.model.io.outputs[indexPath.section];
 
    [layer matchCasePixelBuffer:^(TIOPixelBufferLayerDescription * _Nonnull pixelBufferDescription) {
            // Image layer: editing not currently supported
            cell = [tableView dequeueReusableCellWithIdentifier:@"ImageOutputCell" forIndexPath:indexPath];
    
    } caseVector:^(TIOVectorLayerDescription * _Nonnull vectorDescription) {
        if ( vectorDescription.labels == nil ) {
            // Float values
            NumericLabelTableViewCell *numericCell = (NumericLabelTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"FloatOutputCell" forIndexPath:indexPath];
            numericCell.numberOfExpectedValues = vectorDescription.length;
            [numericCell setLabels:self.labels key:layer.name];
            cell = numericCell;
        
        } else {
            // Text labeled values
            TextLabelTableViewCell *textCell = (TextLabelTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"TextLabelOutputCell" forIndexPath:indexPath];
            textCell.knownLabels = vectorDescription.labels;
            [textCell setLabels:self.labels key:layer.name];
            cell = textCell;
        }
    } caseString:^(TIOStringLayerDescription * _Nonnull stringDescription) {
        // TODO: Raw bytes interface
        
        TextLabelTableViewCell *textCell = (TextLabelTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"TextLabelOutputCell" forIndexPath:indexPath];
        cell = textCell;
    }];
    
    if ( indexPath.section == self.model.io.outputs.count-1 ) {
        cell.returnKeyType = UIReturnKeyDone;
    } else {
        cell.returnKeyType = UIReturnKeyNext;
    }
    
    cell.delegate = self;
 
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return self.model.io.outputs[section].name;
}

// MARK: - LabelOutputTableViewCell Delegate

// Transfer first responder on a Next keyboard event

- (void)labelOutputCellDidReturn:(UITableViewCell<LabelOutputTableViewCell>*)cell {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    if ( indexPath.section == self.model.io.outputs.count-1) {
        return;
    }
    
    NSIndexPath *targetPath = [NSIndexPath indexPathForRow:0 inSection:indexPath.section+1];
    UITableViewCell<LabelOutputTableViewCell> *targetCell = [self.tableView cellForRowAtIndexPath:targetPath];
    
    [targetCell becomeFirstResponder];
}

// Manage errors

- (void)labelOutputCellDidError:(UITableViewCell<LabelOutputTableViewCell>*)cell error:(NSString*)errorDescription {
    NSMutableArray<NSString*> *update = self.errors.mutableCopy;
    [update addObject:cell.key];
    self.errors = update.copy;
}

- (void)labelOutputCellDidClearError:(UITableViewCell<LabelOutputTableViewCell>*)cell {
    NSMutableArray<NSString*> *update = self.errors.mutableCopy;
    [update removeObject:cell.key];
    self.errors = update.copy;
}

@end
