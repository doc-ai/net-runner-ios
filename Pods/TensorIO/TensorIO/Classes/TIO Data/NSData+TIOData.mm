//
//  NSData+TIOData.mm
//  TensorIO
//
//  Created by Philip Dow on 8/3/18.
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

#import "NSData+TIOData.h"

#import "TIOVectorLayerDescription.h"

@implementation NSData (TIOData)

- (nullable instancetype)initWithBytes:(const void *)bytes length:(NSUInteger)length description:(id<TIOLayerDescription>)description {
    assert([description isKindOfClass:TIOVectorLayerDescription.class]);
    
    TIODataDequantizer dequantizer = ((TIOVectorLayerDescription*)description).dequantizer;
    
    if ( description.isQuantized && dequantizer != nil ) {
        size_t float_length = length * sizeof(float_t);
        float_t *buffer = (float_t *)malloc(float_length);
        for ( NSInteger i = 0; i < length; i++ ) {
            ((float_t *)buffer)[i] = dequantizer(((uint8_t *)bytes)[i]);
        }
        return [[NSData alloc] initWithBytes:buffer length:float_length];
    } else if ( description.isQuantized && dequantizer == nil ) {
        return [[NSData alloc] initWithBytes:bytes length:length];
    } else {
        return [[NSData alloc] initWithBytes:bytes length:length];
    }
}

- (void)getBytes:(void *)buffer length:(NSUInteger)length description:(id<TIOLayerDescription>)description {
    assert([description isKindOfClass:TIOVectorLayerDescription.class]);
    
    TIODataQuantizer quantizer = ((TIOVectorLayerDescription*)description).quantizer;
    
    if ( description.isQuantized && quantizer != nil ) {
        float_t *bytes = (float_t *)self.bytes;
        for ( NSInteger i = 0; i < length; i++ ) {
            ((uint8_t *)buffer)[i] = quantizer(bytes[i]);
        }
    } else if ( description.isQuantized && quantizer == nil ) {
        [self getBytes:buffer length:length];
    } else {
        [self getBytes:buffer length:length];
    }
}

@end
