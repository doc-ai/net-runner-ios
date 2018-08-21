//
//  NSData+TIOData.m
//  TensorIO
//
//  Created by Philip Dow on 8/3/18.
//  Copyright © 2018 doc.ai. All rights reserved.
//

#import "NSData+TIOData.h"

#import "TIOVectorLayerDescription.h"

@implementation NSData (TIOData)

// TODO: quantize and dequantize bytes

- (nullable instancetype)initWithBytes:(const void *)bytes length:(NSUInteger)length description:(id<TIOLayerDescription>)description {
    assert([description isKindOfClass:TIOVectorLayerDescription.class]);
    
    TIODataDequantizer dequantizer = ((TIOVectorLayerDescription*)description).dequantizer;
    
    if ( description.isQuantized && dequantizer ) {
        assert(NO);
        return nil;
    } else {
        return [[NSData alloc] initWithBytes:bytes length:length];
    }
}

- (void)getBytes:(void *)buffer length:(NSUInteger)length description:(id<TIOLayerDescription>)description {
    assert([description isKindOfClass:TIOVectorLayerDescription.class]);
    
    TIODataQuantizer quantizer = ((TIOVectorLayerDescription*)description).quantizer;
    
    if ( description.isQuantized && quantizer ) {
        assert(NO);
        return;
    } else {
        [self getBytes:buffer length:length];
    }
}

@end
