//
//  NSNumber+TIOData.m
//  TensorIO
//
//  Created by Philip Dow on 8/4/18.
//  Copyright © 2018 doc.ai. All rights reserved.
//

#import "NSNumber+TIOData.h"

#import "TIOVectorLayerDescription.h"

@implementation NSNumber (TIOData)

- (nullable instancetype)initWithBytes:(const void *)buffer length:(NSUInteger)length description:(id<TIOLayerDescription>)description {
    assert([description isKindOfClass:TIOVectorLayerDescription.class]);
    
    TIODataDequantizer dequantizer = ((TIOVectorLayerDescription*)description).dequantizer;
    
    if ( description.isQuantized ) {
        if ( dequantizer != nil ) {
            return [self initWithFloat:dequantizer(((uint8_t *)buffer)[0])];
        } else {
            return [self initWithChar:((uint8_t *)buffer)[0]];
        }
    } else {
        return [self initWithFloat:((float_t *)buffer)[0]];
    }
}

- (void)getBytes:(void *)buffer length:(NSUInteger)length description:(id<TIOLayerDescription>)description {
    assert([description isKindOfClass:TIOVectorLayerDescription.class]);
    
    TIODataQuantizer quantizer = ((TIOVectorLayerDescription*)description).quantizer;
    
    if ( description.isQuantized ) {
        if ( quantizer != nil ) {
            ((uint8_t *)buffer)[0] = quantizer(self.floatValue);
        } else {
            ((uint8_t *)buffer)[0] = self.charValue;
        }
    } else {
        ((float_t *)buffer)[0] = self.floatValue;
    }
}

@end
