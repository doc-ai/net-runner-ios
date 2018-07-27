//
//  LatencyCounter.h
//  tflite_camera_example
//
//  Created by Philip Dow on 7/4/18.
//  Copyright © 2018 doc.ai. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LatencyCounter : NSObject

@property (readonly) double lastImageProcessingLatency;
@property (readonly) double lastInferenceLatency;

@property (readonly) double imageProcessingLatency;
@property (readonly) double inferenceLatency;
@property (readonly) int count;

@property (readonly) double averageImageProcessingLatency;
@property (readonly) double averageInferenceLatency;
@property (readonly) double averageTotalLatency;

- (void)increaseImageProcessingLatency:(double)value;
- (void)increaseInferenceLatency:(double)value;
- (void)incrementCount;

@end

NS_ASSUME_NONNULL_END
