//
//  NSData+TIOTFLiteData.mm
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

#import "NSData+TIOTFLiteData.h"

#import "TIOVectorLayerDescription.h"

@implementation NSData (TIOTFLiteData)

- (nullable instancetype)initWithBytes:(const void *)bytes description:(id<TIOLayerDescription>)description {
    assert([description isKindOfClass:TIOVectorLayerDescription.class]);
    
    TIODataDequantizer dequantizer = ((TIOVectorLayerDescription*)description).dequantizer;
    NSUInteger length = ((TIOVectorLayerDescription*)description).length;
    
    if ( description.isQuantized && dequantizer != nil ) {
        size_t dest_size = length * sizeof(float_t);
        float_t *buffer = (float_t *)malloc(dest_size);
        for ( NSInteger i = 0; i < length; i++ ) {
            ((float_t *)buffer)[i] = dequantizer(((uint8_t *)bytes)[i]);
        }
        NSData *data = [[NSData alloc] initWithBytes:buffer length:dest_size];
        free(buffer);
        return data;
    } else if ( description.isQuantized && dequantizer == nil ) {
        size_t dest_size = length * sizeof(uint8_t);
        return [[NSData alloc] initWithBytes:bytes length:dest_size];
    } else {
        size_t dest_size = length * sizeof(float_t);
        return [[NSData alloc] initWithBytes:bytes length:dest_size];
    }
}

- (void)getBytes:(void *)buffer description:(id<TIOLayerDescription>)description {
    assert([description isKindOfClass:TIOVectorLayerDescription.class]);
    
    TIODataQuantizer quantizer = ((TIOVectorLayerDescription*)description).quantizer;
    NSUInteger length = ((TIOVectorLayerDescription*)description).length;
    
    if ( description.isQuantized && quantizer != nil ) {
        float_t *bytes = (float_t *)self.bytes;
        for ( NSInteger i = 0; i < length; i++ ) {
            ((uint8_t *)buffer)[i] = quantizer(bytes[i]);
        }
    } else if ( description.isQuantized && quantizer == nil ) {
        size_t src_size = length * sizeof(uint8_t);
        [self getBytes:buffer length:src_size];
    } else {
        size_t src_size = length * sizeof(float_t);
        [self getBytes:buffer length:src_size];
    }
}

@end
