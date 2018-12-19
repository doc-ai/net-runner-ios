//
//  LabelOutputsTableViewController.m
//  Net Runner
//
//  Created by Philip Dow on 12/17/18.
//  Copyright © 2018 doc.ai. All rights reserved.
//

#import "LabelOutputsTableViewController.h"

#import "LabelOutputTableViewCell.h"
#import "NumericLabelTableViewCell.h"
#import "TextLabelTableViewCell.h"

@import TensorIO;

@interface LabelOutputsTableViewController () <LabelOutputTableViewCellDelegate>

@property (nonatomic, readwrite) UIImage *image;
@property id<TIOModel> model;

@end

@implementation LabelOutputsTableViewController

+ (PHImageRequestOptions*)imageRequestOptions {
    static PHImageRequestOptions *options = nil;
    
    if ( options != nil ) {
        return options;
    }
    
    options = [[PHImageRequestOptions alloc] init];
    
    options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    options.resizeMode = PHImageRequestOptionsResizeModeExact;
    options.networkAccessAllowed = YES;
    options.synchronous = YES;
    
    return options;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // View Setup
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 68.0;
    
    // Load Image
    
    [self.imageManager
        requestImageForAsset:self.asset
        targetSize:PHImageManagerMaximumSize
        contentMode:PHImageContentModeAspectFill
        options:[LabelOutputsTableViewController imageRequestOptions]
        resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        
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
}

- (void)setImage:(UIImage *)image {
    _image = image;
    
    self.imageView.image = _image;
}

// MARK: - User Actions

- (IBAction)cancel:(id)sender {
    [self.view endEditing:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)save:(id)sender {
    [self.view endEditing:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

// MARK: - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.model.outputs.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

// TODO: update the "1 numeric value" label

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    __block UITableViewCell<LabelOutputTableViewCell> *cell;
 
    [self.model.outputs[indexPath.section] matchCasePixelBuffer:^(TIOPixelBufferLayerDescription * _Nonnull pixelBufferDescription) {
        // Image layer: editing not currently supported
        cell = [tableView dequeueReusableCellWithIdentifier:@"ImageOutputCell" forIndexPath:indexPath];
    
    } caseVector:^(TIOVectorLayerDescription * _Nonnull vectorDescription) {
        if ( vectorDescription.labels == nil ) {
            // Float values
            NumericLabelTableViewCell *numericCell = (NumericLabelTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"FloatOutputCell" forIndexPath:indexPath];
            cell = numericCell;
        
        } else {
            // Text labeled values
            TextLabelTableViewCell *textCell = (TextLabelTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"TextLabelOutputCell" forIndexPath:indexPath];
            textCell.labels = vectorDescription.labels;
            cell = textCell;
        }
    }];
    
    if ( indexPath.section == self.model.outputs.count-1 ) {
        cell.returnKeyType = UIReturnKeyDone;
    } else {
        cell.returnKeyType = UIReturnKeyNext;
    }
    
    cell.delegate = self;
 
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return self.model.outputs[section].name;
}

// MARK: - LabelOutputTableViewCell Delegate

// Transfer first responder on a Next keyboard event

- (void)labelOutputCellDidReturn:(UITableViewCell<LabelOutputTableViewCell>*)cell {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    if ( indexPath.section == self.model.outputs.count-1) {
        return;
    }
    
    NSIndexPath *targetPath = [NSIndexPath indexPathForRow:0 inSection:indexPath.section+1];
    UITableViewCell<LabelOutputTableViewCell> *targetCell = [self.tableView cellForRowAtIndexPath:targetPath];
    
    [targetCell becomeFirstResponder];
}

@end
