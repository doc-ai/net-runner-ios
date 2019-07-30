//
//  TIOMemorySampler.m
//  TensorIO
//
//  Created by Phil Dow on 7/2/19.
//  Copyright © 2019 doc.ai (http://doc.ai)
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

#import "TIOMemorySampler.h"

#import <mach/mach.h>
#import <mach/mach_host.h>

uint64_t TIOMemorySamplerResidentMemoryInBytes() {
    kern_return_t rval = 0;
    mach_port_t task = mach_task_self();

    struct mach_task_basic_info info = {0};
    mach_msg_type_number_t tcnt = MACH_TASK_BASIC_INFO_COUNT;
    task_flavor_t flavor = MACH_TASK_BASIC_INFO;

    task_info_t tptr = (task_info_t) &info;
    if (tcnt > sizeof(info)) {
        return 0;
    }

    rval = task_info(task, flavor, tptr, &tcnt);
    if (rval != KERN_SUCCESS) {
        return 0;
    }

    return info.resident_size;
}

@implementation TIOMemorySampler {
    dispatch_queue_t _queue;
    uint64_t _max_bytes;
    BOOL _active;
}

- (instancetype) initWithInterval:(NSTimeInterval)interval {
    if ((self=[super init])) {
        _queue = dispatch_queue_create("ai.doc.tensorio.memory-sampler", DISPATCH_QUEUE_SERIAL);
        _interval = interval;
        _max_bytes = 0;
    }
    return self;
}

- (NSNumber *)max {
    return _max_bytes > 0
        ? @(_max_bytes)
        : @(-1);
}

- (void)start {
    _active = YES;
    [self repeat];
}

- (void)stop {
    _active = NO;
}

- (void)repeat {
    if (!_active) {
        return;
    }
    
    dispatch_async(_queue, ^{
        [self sample];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, self.interval * NSEC_PER_SEC), self->_queue, ^{
            [self repeat];
        });
    });
}

- (void)sample {
    uint64_t sample = TIOMemorySamplerResidentMemoryInBytes();
    if (sample > _max_bytes) {
        _max_bytes = sample;
    }
}

@end
