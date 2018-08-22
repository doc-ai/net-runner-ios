//
//  LatencyCounter.m
//  Net Runner
//
//  Created by Philip Dow on 7/4/18.
//  Copyright © 2018 doc.ai (http://doc.ai)
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
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
