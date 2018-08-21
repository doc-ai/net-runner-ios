//
//  ImageEvaluator.m
//  Net Runner
//
//  Created by Philip Dow on 7/18/18.
//  Copyright © 2018 doc.ai. All rights reserved.
//

#import "ImageEvaluator.h"

#import "UIImage+CVPixelBuffer.h"
#import "TIOObjcDefer.h"
#import "CVPixelBufferEvaluator.h"
#import "Utilities.h"

@interface ImageEvaluator ()

@property (readwrite) NSDictionary *results;
@property (readwrite) id<TIOModel> model;
@property (readwrite) UIImage *image;

@end

@implementation ImageEvaluator {
    dispatch_once_t _once;
}

- (instancetype)initWithModel:(id<TIOModel>)model image:(UIImage*)image {
    if (self = [super init]) {
        _image = image;
        _model = model;
    }
    
    return self;
}

- (void)evaluateWithCompletionHandler:(nullable EvaluatorCompletionBlock)completionHandler {
    dispatch_once(&_once, ^{
    
    tio_defer_block {
        self.model = nil;
        self.image = nil;
    };
    
    CVPixelBufferRef pixelBuffer = self.image.pixelBuffer; // Returns ARGB
    
    CVPixelBufferEvaluator *pixelBufferEvaluator = [[CVPixelBufferEvaluator alloc] initWithModel:self.model pixelBuffer:pixelBuffer orientation:kCGImagePropertyOrientationUp];
    
    [pixelBufferEvaluator evaluateWithCompletionHandler:^(NSDictionary * _Nonnull result, CVPixelBufferRef _Nullable inputPixelBuffer) {
        safe_block(completionHandler, result, inputPixelBuffer);
    }];
    
    }); // dispatch_once
}

@end
