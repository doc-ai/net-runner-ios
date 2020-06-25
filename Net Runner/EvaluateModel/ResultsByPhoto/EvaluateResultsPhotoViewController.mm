//
//  EvaluateResultsPhotoViewController.mm
//  Net Runner
//
//  Created by Philip Dow on 7/25/18.
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

#import "EvaluateResultsPhotoViewController.h"

#import "ImageInputPreviewView.h"
#import "AlbumPhotoEvaluator.h"
#import "UserDefaults.h"
#import "ResultInfoView.h"
#import "ModelOutput.h"
#import "EvaluatorConstants.h"
#import "LabelOutputsTableViewController.h"

@import TensorIO;

@interface EvaluateResultsPhotoViewController ()

@property (nonatomic, readwrite) UIImage *image;

@end

@implementation EvaluateResultsPhotoViewController

+ (PHImageRequestOptions*)imageRequestOptions {
    static PHImageRequestOptions *options = nil;
    
    if ( options != nil ) {
        return options;
    }
    
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
    
    assert(self.modelBundle != nil);
    assert(self.results != nil);
    assert(self.imageManager != nil);
    assert(self.album != nil);
    assert(self.asset != nil);
    
    // Preferences
    
    self.imageInputPreviewView.hidden = ![NSUserDefaults.standardUserDefaults boolForKey:kPrefsShowInputBuffers];
    self.imageInputPreviewView.showsAlphaChannel = [NSUserDefaults.standardUserDefaults boolForKey:kPrefsShowInputBufferAlpha];
    
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
        options:[EvaluateResultsPhotoViewController imageRequestOptions]
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
    
    // Run the model on the asset
    
    // We could run the model on the image returned here or the asset but they should be the same
    // And we want to run the same process that produced the results we recieved
    
    [self runModelOnAsset:self.asset];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ( [segue.identifier isEqualToString:@"LabelPhotoSegue"] ) {
        UINavigationController *controller = (UINavigationController*)segue.destinationViewController;
        LabelOutputsTableViewController *destination = (LabelOutputsTableViewController*)controller.topViewController;
        destination.modelBundle = self.modelBundle;
        destination.imageManager = self.imageManager;
        destination.asset = self.asset;
    }
}

- (void)setImage:(UIImage *)image {
    _image = image;
    
    self.imageView.image = _image;
}

- (void)runModelOnAsset:(PHAsset*)asset {
    id<TIOModel> model = self.modelBundle.newModel;
    
    AlbumPhotoEvaluator *evaluator = [[AlbumPhotoEvaluator alloc] initWithModel:model photo:asset album:self.album imageManager:self.imageManager];
    
    [evaluator evaluateWithCompletionHandler:^(NSDictionary * _Nonnull result, CVPixelBufferRef _Nullable inputPixelBuffer) {
        
        id<ModelOutput> providedInference = self.results[kEvaluatorResultsKeyEvaluation][kEvaluatorResultsKeyInferenceResults];
        id<ModelOutput> myInference = result[kEvaluatorResultsKeyEvaluation][kEvaluatorResultsKeyInferenceResults];
        
        if ( ![providedInference isEqual:myInference] ) {
            NSLog(@"Expected provivided inference and new inference to match but they did not, provided inference: %@, new inference: %@", providedInference, myInference);
        }
        
        // Visualize last pixel buffer used by model
        
        if ( [NSUserDefaults.standardUserDefaults boolForKey:kPrefsShowInputBuffers] ) {
            self.imageInputPreviewView.pixelBuffer = inputPixelBuffer;
        }
        
        // Show the inference results
        
        [self displayResults:myInference];
    }];
}

- (void)displayResults:(id<ModelOutput>)output {
    NSString *description = output.localizedDescription;
    
    if ( description.length == 0 ) {
        self.resultInfoView.classifications = @"None";
        self.title = @"No Inference";
        return;
    }
    
    self.resultInfoView.classifications = description;
}

@end
