//
//  TIOQuantization.m
//  TensorIO
//
//  Created by Philip Dow on 8/19/18.
//  Copyright © 2018 doc.ai. All rights reserved.
//

#import "TIOQuantization.h"

// MARK: - Quantization

_Nullable TIODataQuantizer TIODataQuantizerNone() {
    return nil;
}

// MARK: - Dequantization

_Nullable TIODataDequantizer TIODataDequantizerNone() {
    return nil;
}

TIODataDequantizer TIODataDequantizerZeroToOne() {
    const float scale = 1.0/255.0;
    
    return ^float_t (const uint8_t &value) {
        return ((float_t)value * scale);
    };
}
