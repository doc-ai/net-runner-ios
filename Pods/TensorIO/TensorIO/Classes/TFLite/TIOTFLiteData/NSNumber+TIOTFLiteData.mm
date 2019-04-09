//
//  NSNumber+TIOTFLiteData.mm
//  TensorIO
//
//  Created by Philip Dow on 8/4/18.
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

#import "NSNumber+TIOTFLiteData.h"

#import "TIOVectorLayerDescription.h"

@implementation NSNumber (TIOTFLiteData)

- (nullable instancetype)initWithBytes:(const void *)buffer length:(NSUInteger)length description:(id<TIOLayerDescription>)description {
    assert([description isKindOfClass:TIOVectorLayerDescription.class]);
    
    TIODataDequantizer dequantizer = ((TIOVectorLayerDescription*)description).dequantizer;
    
    if ( description.isQuantized && dequantizer != nil ) {
        return [self initWithFloat:dequantizer(((uint8_t *)buffer)[0])];
    } else if ( description.isQuantized && dequantizer == nil ) {
        return [self initWithUnsignedChar:((uint8_t *)buffer)[0]];
    } else {
        return [self initWithFloat:((float_t *)buffer)[0]];
    }
}

- (void)getBytes:(void *)buffer length:(NSUInteger)length description:(id<TIOLayerDescription>)description {
    assert([description isKindOfClass:TIOVectorLayerDescription.class]);
    
    TIODataQuantizer quantizer = ((TIOVectorLayerDescription*)description).quantizer;
    
    if ( description.isQuantized && quantizer != nil ) {
        ((uint8_t *)buffer)[0] = quantizer(self.floatValue);
    } else if ( description.isQuantized && quantizer == nil ) {
        ((uint8_t *)buffer)[0] = self.unsignedCharValue;
    } else {
        ((float_t *)buffer)[0] = self.floatValue;
    }
}

@end
