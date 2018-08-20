//
//  Quantization.m
//  Net Runner
//
//  Created by Philip Dow on 8/19/18.
//  Copyright © 2018 doc.ai. All rights reserved.
//

#import "Quantization.h"

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
