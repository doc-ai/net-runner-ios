//
//  URLImageEvaluator.h
//  tflite_camera_example
//
//  Created by Philip Dow on 7/18/18.
//  Copyright © 2018 doc.ai. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Evaluator.h"
#import "VisionModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface URLImageEvaluator : NSObject <Evaluator>

@property (readonly) id<VisionModel> model;
@property (readonly) NSDictionary *results;

@property (readonly) NSURL *URL;
@property (readonly) NSString *name;

- (instancetype)initWithModel:(id<VisionModel>)model URL:(NSURL*)URL name:(NSString*)name;

- (void)evaluateWithCompletionHandler:(nullable EvaluatorCompletionBlock)completionHandler;

@end

NS_ASSUME_NONNULL_END
