//
//  ModelHelpers.mm
//  Net Runner
//
//  Created by Philip Dow on 7/13/18.
//  Copyright © 2018 doc.ai. All rights reserved.
//

#import "ModelHelpers.h"

// MARK: - Quantization

_Nullable DataQuantizer TIODataQuantizerNone() {
    return nil;
}

// MARK: - Dequantization

_Nullable DataDequantizer TIODataDequantizerNone() {
    return nil;
}

DataDequantizer DataDequantizerZeroToOne() {
    const float scale = 1.0/255.0;
    
    return ^float_t (const uint8_t &value) {
        return ((float_t)value * scale);
    };
}

// MARK: - Errors

NSError * const kTFModelLoadModelError = [NSError errorWithDomain:@"netrunner.ios" code:101 userInfo:@{
    NSLocalizedDescriptionKey: @"Unable to load model from graph file"
}];

NSError * const kTFModelConstructInterpreterError = [NSError errorWithDomain:@"netrunner.ios" code:101 userInfo:@{
    NSLocalizedDescriptionKey: @"Unable to construct interpreter"
}];

NSError * const kTFModelAllocateTensorsError = [NSError errorWithDomain:@"netrunner.ios" code:101 userInfo:@{
    NSLocalizedDescriptionKey: @"Unable to allocate tensors"
}];
