//
//  CVPixelBufferEvaluator.h
//  Net Runner
//
//  Created by Philip Dow on 7/26/18.
//  Copyright © 2018 doc.ai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

#import "Evaluator.h"

NS_ASSUME_NONNULL_BEGIN

@interface CVPixelBufferEvaluator : NSObject <Evaluator>

@property (readonly) id<VisionModel> model;
@property (readonly) NSDictionary *results;
@property (nonatomic, readonly) CVPixelBufferRef pixelBuffer;

- (instancetype)initWithPixelBuffer:(CVPixelBufferRef)pixelBuffer model:(id<VisionModel>)model;

- (void)evaluateWithCompletionHandler:(nullable EvaluatorCompletionBlock)completionHandler;

@end

NS_ASSUME_NONNULL_END
