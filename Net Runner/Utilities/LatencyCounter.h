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

@property double lastImageProcessingLatency;
@property double lastInferenceLatency;

@property double imageProcessingLatency;
@property double inferenceLatency;
@property int count;

@property (readonly) double averageImageProcessingLatency;
@property (readonly) double averageInferenceLatency;
@property (readonly) double averageTotalLatency;

@end

NS_ASSUME_NONNULL_END
