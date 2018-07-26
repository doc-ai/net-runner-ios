//
//  HeadlessTestBundle.h
//  tflite_camera_example
//
//  Created by Philip Dow on 7/19/18.
//  Copyright © 2018 doc.ai. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol EvaluationMetric;

@interface HeadlessTestBundle : NSObject

@property (readonly) NSString *path;
@property (readonly) NSDictionary *info;

@property (readonly) NSString *name;
@property (readonly) NSString *identifier;
@property (readonly) NSString *version;

@property (readonly) NSArray<NSString*> *modelIds;
@property (readonly) NSArray<NSDictionary*> *images;
@property (readonly) NSDictionary *labels;
@property (readonly) NSDictionary *options;

@property (readonly) NSUInteger iterations;
@property (readonly) id<EvaluationMetric> metric;

- (instancetype) initWithPath:(NSString*)path;

- (NSString*)filePathForImageInfo:(NSDictionary*)imageInfo;

@end

NS_ASSUME_NONNULL_END
