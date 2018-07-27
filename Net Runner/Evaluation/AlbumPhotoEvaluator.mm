//
//  AlbumPhotoEvaluator.m
//  tflite_camera_example
//
//  Created by Philip Dow on 7/18/18.
//  Copyright © 2018 doc.ai. All rights reserved.
//

#import "AlbumPhotoEvaluator.h"

#import "ImageEvaluator.h"
#import "Model.h"
#import "Utilities.h"
#import "ObjcDefer.h"

@interface AlbumPhotoEvaluator()

+ (PHImageRequestOptions*) imageRequestOptions;

@property (readwrite) NSDictionary *results;
@property (readwrite) id<VisionModel> model;

@end

@implementation AlbumPhotoEvaluator {
    dispatch_once_t _once;
}

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

- (instancetype)initWithModel:(id<VisionModel>)model photo:(PHAsset*)photo album:(PHAssetCollection*)album imageManager:(PHCachingImageManager*)imageManager {
    if (self = [super init]) {
        _model = model;
        _photo = photo;
        _album = album;
        _imageManager = imageManager;
    }
    
    return self;
}

- (void)evaluateWithCompletionHandler:(nullable EvaluatorCompletionBlock)completionHandler {
    dispatch_once (&_once, ^{

    [self.imageManager
        requestImageForAsset:self.photo
        targetSize:PHImageManagerMaximumSize
        contentMode:PHImageContentModeAspectFill
        options:[AlbumPhotoEvaluator imageRequestOptions]
        resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        
        @autoreleasepool {
        
            defer_block {
                self.model = nil;
            };
        
            if ( result == nil ) {
                NSString *errorDescription = [NSString stringWithFormat:@"Unable to request image for asset %@",  self.photo.localIdentifier];
                NSLog(@"%@", errorDescription);
                self.results = @{
                    @"type": @"album_photo",
                    @"album": self.album.localIdentifier,
                    @"photo": self.photo.localIdentifier,
                    @"model": self.model.identifier,
                    @"error": @(YES),
                    @"error_description": errorDescription,
                    @"evaluation": [NSNull null]
                };
                safe_block(completionHandler, self.results);
                return;
            }
            
            ImageEvaluator *imageEvaluator = [[ImageEvaluator alloc] initWithImage:result model:self.model];
            
            [imageEvaluator evaluateWithCompletionHandler:^(NSDictionary *results) {
                self.results = @{
                    @"type": @"album_photo",
                    @"album": self.album.localIdentifier,
                    @"photo": self.photo.localIdentifier,
                    @"model": self.model.identifier,
                    @"error": @(NO),
                    @"evaluation": results
                };
                safe_block(completionHandler, self.results);
            }];
        }
    }];
    
    }); // dispatch_once
}

@end
