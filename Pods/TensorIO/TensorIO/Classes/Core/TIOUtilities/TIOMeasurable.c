//
//  TIOMeasurable.c
//  TensorIO
//
//  Created by Phil Dow on 5/29/19.
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

#include "TIOMeasurable.h"

#include <stdio.h>
#include <time.h>
#include <mach/mach_time.h>
#include <stdint.h>

void tio_measuring_latency(double* latency, tio_measurable block) {
    const uint64_t tick = mach_absolute_time();
    block();
    const uint64_t tock = mach_absolute_time();
    const uint64_t elapsed = tock - tick;
    
    mach_timebase_info_data_t info;
    mach_timebase_info(&info);
    
    const double ns = (double)elapsed * (double)info.numer / (double)info.denom;
    const double ms = ns / 1000000;
    
    *latency = ms;
}
