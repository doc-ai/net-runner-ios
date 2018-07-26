//
//  ModelHelpers.mm
//  tflite_camera_example
//
//  Created by Philip Dow on 7/13/18.
//  Copyright © 2018 doc.ai. All rights reserved.
//

#include "ModelHelpers.h"

NSError * const kTFModelLoadModelError = [NSError errorWithDomain:@"netrunner.ios" code:101 userInfo:@{
    NSLocalizedDescriptionKey: @"Unable to load model from graph file"
}];

NSError * const kTFModelConstructInterpreterError = [NSError errorWithDomain:@"netrunner.ios" code:101 userInfo:@{
    NSLocalizedDescriptionKey: @"Unable to construct interpreter"
}];

NSError * const kTFModelAllocateTensorsError = [NSError errorWithDomain:@"netrunner.ios" code:101 userInfo:@{
    NSLocalizedDescriptionKey: @"Unable to allocate tensors"
}];
