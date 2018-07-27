//
//  ImageEvaluator.m
//  tflite_camera_example
//
//  Created by Philip Dow on 7/18/18.
//  Copyright © 2018 doc.ai. All rights reserved.
//

#import "ImageEvaluator.h"

#import "UIImage+CVPixelBuffer.h"
#import "ObjcDefer.h"
#import "CVPixelBufferEvaluator.h"
#import "Utilities.h"

@interface ImageEvaluator ()

@property (readwrite) NSDictionary *results;
@property (readwrite) id<VisionModel> model;
@property (readwrite) UIImage *image;

@end

@implementation ImageEvaluator {
    dispatch_once_t _once;
}

- (instancetype)initWithImage:(UIImage*)image model:(id<VisionModel>)model {
    if (self = [super init]) {
        _image = image;
        _model = model;
    }
    
    return self;
}

- (void)evaluateWithCompletionHandler:(nullable EvaluatorCompletionBlock)completionHandler {
    dispatch_once (&_once, ^{
    
    defer_block {
        self.model = nil;
        self.image = nil;
    };
    
    CVPixelBufferRef pixelBuffer = self.image.pixelBuffer; // Returns ARGB
    
    // TODO: pull orientation from the UIImage
    
    CVPixelBufferEvaluator *pixelBufferEvaluator = [[CVPixelBufferEvaluator alloc] initWithPixelBuffer:pixelBuffer orientation:kCGImagePropertyOrientationUp model:self.model];
    
    [pixelBufferEvaluator evaluateWithCompletionHandler:^(NSDictionary * _Nonnull result) {
        self.results = result;
        safe_block(completionHandler, self.results);
    }];
    
    }); // dispatch_once
}

@end
