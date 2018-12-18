//
//  LabelOutputsTableViewController.m
//  Net Runner
//
//  Created by Philip Dow on 12/17/18.
//  Copyright © 2018 doc.ai. All rights reserved.
//

#import "LabelOutputsTableViewController.h"

@import TensorIO;

@interface LabelOutputsTableViewController ()

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
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)save:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

// MARK: - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.model.outputs.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    __block UITableViewCell *cell;
 
    [self.model.outputs[indexPath.section] matchCasePixelBuffer:^(TIOPixelBufferLayerDescription * _Nonnull pixelBufferDescription) {
        // Image layer: editing not currently supported
        cell = [tableView dequeueReusableCellWithIdentifier:@"ImageOutputCell" forIndexPath:indexPath];
    
    } caseVector:^(TIOVectorLayerDescription * _Nonnull vectorDescription) {
        if ( vectorDescription.labels == nil ) {
            // Float values
            cell = [tableView dequeueReusableCellWithIdentifier:@"FloatOutputCell" forIndexPath:indexPath];
        } else {
            // Text labeled values
            cell = [tableView dequeueReusableCellWithIdentifier:@"TextLabelOutputCell" forIndexPath:indexPath];
        }
    }];
 
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return self.model.outputs[section].name;
}

@end
