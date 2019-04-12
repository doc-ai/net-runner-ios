//
//  TIOQuantization.mm
//  TensorIO
//
//  Created by Philip Dow on 8/19/18.
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

#import "TIOQuantization.h"

// MARK: - Quantization

TIODataQuantizer TIODataQuantizerWithQuantization(TIODataQuantization quantization) {
    const float scale = quantization.scale;
    const float bias = quantization.bias;
    
    return ^uint8_t(float_t value) {
        return (uint8_t)((value+bias) * scale);
    };
}

TIODataQuantizer TIODataQuantizerZeroToOne() {
    const float scale = 255.0;
    
    return ^uint8_t(float_t value) {
        return (uint8_t)(value * scale);
    };
}

TIODataQuantizer TIODataQuantizerNegativeOneToOne() {
    const float scale = 255.0/2.0;
    const float bias = 1;
    
    return ^uint8_t(float_t value) {
        return (uint8_t)((value+bias) * scale);
    };
}

_Nullable TIODataQuantizer TIODataQuantizerNone() {
    return nil;
}

// MARK: - Dequantization

TIODataDequantizer TIODataDequantizerWithDequantization(TIODataDequantization dequantization) {
    const float scale = dequantization.scale;
    const float bias = dequantization.bias;
    
    return ^float_t(uint8_t value) {
        return ((float_t)value * scale) + bias;
    };
}

TIODataDequantizer TIODataDequantizerZeroToOne() {
    const float scale = 1.0/255.0;
    
    return ^float_t(uint8_t value) {
        return ((float_t)value * scale);
    };
}

TIODataDequantizer TIODataDequantizerNegativeOneToOne() {
    const float scale = 2.0/255.0;
    const float bias = -1;
    
    return ^float_t(uint8_t value) {
        return ((float_t)value * scale) + bias;
    };
}

_Nullable TIODataDequantizer TIODataDequantizerNone() {
    return nil;
}
