//
//  LatencyCounter.m
//  tflite_camera_example
//
//  Created by Philip Dow on 7/4/18.
//  Copyright © 2018 doc.ai. All rights reserved.
//

#import "LatencyCounter.h"

@implementation LatencyCounter

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
