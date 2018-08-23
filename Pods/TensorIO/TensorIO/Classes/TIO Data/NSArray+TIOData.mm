//
//  NSArray+TIOData.mm
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

#import "NSArray+TIOData.h"

#import "TIOVectorLayerDescription.h"

@implementation NSArray (TIOData)

- (nullable instancetype)initWithBytes:(const void *)bytes length:(NSUInteger)length description:(id<TIOLayerDescription>)description {
    assert([description isKindOfClass:TIOVectorLayerDescription.class]);
    
    TIODataDequantizer dequantizer = ((TIOVectorLayerDescription*)description).dequantizer;
    NSMutableArray *array = NSMutableArray.array;
    
    if ( description.isQuantized ) {
        if ( dequantizer != nil ) {
            for ( NSUInteger i = 0; i < length; i++ ) {
                [array addObject:@(dequantizer(((uint8_t *)bytes)[i]))];
            }
        } else {
            for ( NSUInteger i = 0; i < length; i++ ) {
                [array addObject:@(((uint8_t *)bytes)[i])];
            }
        }
    } else {
        for ( NSUInteger i = 0; i < length; i++ ) {
            [array addObject:@(((float_t *)bytes)[i])];
        }
    }
    
    return [self initWithArray:array];
}

- (void)getBytes:(void *)buffer length:(NSUInteger)length description:(id<TIOLayerDescription>)description {
    assert([description isKindOfClass:TIOVectorLayerDescription.class]);

    TIODataQuantizer quantizer = ((TIOVectorLayerDescription*)description).quantizer;

    if ( description.isQuantized ) {
        if ( quantizer != nil ) {
            for ( NSInteger i = 0; i < self.count; i++ ) {
                ((uint8_t *)buffer)[i] = quantizer(((NSNumber*)self[i]).floatValue);
            }
        } else {
            for ( NSInteger i = 0; i < self.count; i++ ) {
                ((uint8_t *)buffer)[i] = ((NSNumber*)self[i]).charValue;
            }
        }
    } else {
        for ( NSInteger i = 0; i < self.count; i++ ) {
            ((float_t *)buffer)[i] = ((NSNumber*)self[i]).floatValue;
        }
    }
}

@end
