//
//  NSArray+TIOTFLiteData.mm
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

#import "NSArray+TIOTFLiteData.h"

#import "TIOVectorLayerDescription.h"

@implementation NSArray (TIOTFLiteData)

- (nullable instancetype)initWithBytes:(const void *)bytes description:(id<TIOLayerDescription>)description {
    assert([description isKindOfClass:TIOVectorLayerDescription.class]);
    
    TIODataDequantizer dequantizer = ((TIOVectorLayerDescription *)description).dequantizer;
    NSUInteger length = ((TIOVectorLayerDescription *)description).length;
    NSMutableArray *array = NSMutableArray.array;
    
    if ( description.isQuantized && dequantizer != nil ) {
        for ( NSUInteger i = 0; i < length; i++ ) {
            [array addObject:@(dequantizer(((uint8_t *)bytes)[i]))];
        }
    } else if ( description.isQuantized && dequantizer == nil ) {
        for ( NSUInteger i = 0; i < length; i++ ) {
            [array addObject:@(((uint8_t *)bytes)[i])];
        }
    } else {
        for ( NSUInteger i = 0; i < length; i++ ) {
            [array addObject:@(((float_t *)bytes)[i])];
        }
    }
    
    return [self initWithArray:array];
}

- (void)getBytes:(void *)buffer description:(id<TIOLayerDescription>)description {
    assert([description isKindOfClass:TIOVectorLayerDescription.class]);

    TIODataQuantizer quantizer = ((TIOVectorLayerDescription *)description).quantizer;

    if ( description.isQuantized && quantizer != nil ) {
        for ( NSInteger i = 0; i < self.count; i++ ) {
            ((uint8_t *)buffer)[i] = quantizer(((NSNumber *)self[i]).floatValue);
        }
    } else  if ( description.isQuantized && quantizer == nil ) {
        for ( NSInteger i = 0; i < self.count; i++ ) {
            ((uint8_t *)buffer)[i] = ((NSNumber *)self[i]).unsignedCharValue;
        }
    } else {
        for ( NSInteger i = 0; i < self.count; i++ ) {
            ((float_t *)buffer)[i] = ((NSNumber *)self[i]).floatValue;
        }
    }
}

@end
