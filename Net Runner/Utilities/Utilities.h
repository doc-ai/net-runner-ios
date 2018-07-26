//
//  Utilities.h
//  tflite_camera_example
//
//  Created by Philip Dow on 7/3/18.
//  Copyright © 2018 doc.ai. All rights reserved.
//

#ifndef Utilities_h
#define Utilities_h

#define safe_block(block, ...) if (block) { block(__VA_ARGS__); }

typedef void(^measurable)(void);

void measuring_latency(double* latency, measurable block);

#endif /* Utilities_h */
