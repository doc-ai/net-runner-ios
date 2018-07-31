//
//  Utilities.mm
//  Net Runner
//
//  Created by Philip Dow on 7/3/18.
//  Copyright © 2018 doc.ai. All rights reserved.
//

#include "Utilities.h"
#include <Foundation/Foundation.h>

#include <stdio.h>
#include <time.h>
#include <mach/mach_time.h>
#include <stdint.h>

void measuring_latency(double* latency, measurable block) {
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
