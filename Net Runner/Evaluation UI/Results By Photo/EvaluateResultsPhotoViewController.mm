//
//  EvaluateResultsPhotoViewController.m
//  Net Runner
//
//  Created by Philip Dow on 7/25/18.
//  Copyright © 2018 doc.ai. All rights reserved.
//

#import "EvaluateResultsPhotoViewController.h"

#import "ImageInputPreviewView.h"
#import "TIOModelBundle.h"
#import "AlbumPhotoEvaluator.h"
#import "UserDefaults.h"
#import "NSArray+TIOExtensions.h"
#import "ResultInfoView.h"
#import "ModelOutput.h"
#import "EvaluatorConstants.h"

@interface EvaluateResultsPhotoViewController ()

@property (nonatomic, readwrite) UIImage *image;

@end

@implementation EvaluateResultsPhotoViewController

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
    
    assert(self.modelBundle != nil);
    assert(self.results != nil);
    assert(self.imageManager != nil);
    assert(self.album != nil);
    assert(self.asset != nil);
    
    // Preferences
    
    self.imageInputPreviewView.hidden = ![NSUserDefaults.standardUserDefaults boolForKey:kPrefsShowInputBuffers];
    self.imageInputPreviewView.showsAlphaChannel = [NSUserDefaults.standardUserDefaults boolForKey:kPrefsShowInputBufferAlpha];
    
    // Load Image
    
    [self.imageManager
        requestImageForAsset:self.asset
        targetSize:PHImageManagerMaximumSize
        contentMode:PHImageContentModeAspectFill
        options:[EvaluateResultsPhotoViewController imageRequestOptions]
        resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        
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
