//
//  LatencyCounter.m
//  tflite_camera_example
//
//  Created by Philip Dow on 7/4/18.
//  Copyright © 2018 doc.ai. All rights reserved.
//

#import "LatencyCounter.h"

@implementation LatencyCounter

- (void)increaseImageProcessingLatency:(double)value {
    _lastImageProcessingLatency = value;
    _imageProcessingLatency += value;
}

- (void)increaseInferenceLatency:(double)value {
    _lastInferenceLatency = value;
    _inferenceLatency += value;
}

- (void)incrementCount {
    _count += 1;
}

- (double) averageImageProcessingLatency {
    return _imageProcessingLatency / _count;
}

- (double) averageInferenceLatency {
    return _inferenceLatency / _count;
}

- (double) averageTotalLatency {
    return self.averageImageProcessingLatency + self.averageInferenceLatency;
}

@end
