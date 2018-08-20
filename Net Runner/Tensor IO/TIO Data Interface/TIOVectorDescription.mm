//
//  TIOVectorDescription.m
//  TensorIO
//
//  Created by Philip Dow on 8/5/18.
//  Copyright © 2018 doc.ai. All rights reserved.
//

#import "TIOVectorDescription.h"

@implementation TIOVectorDescription

- (instancetype)initWithLength:(NSUInteger)length labels:(nullable NSArray<NSString*>*)labels quantized:(BOOL)quantized quantizer:(nullable TIODataQuantizer)quantizer dequantizer:(TIODataDequantizer)dequantizer {
    if (self=[super init]) {
        _length = length;
        _labels = labels.copy;
        _quantized = quantized;
        _quantizer = quantizer;
        _dequantizer = dequantizer;
    }
    return self;
}

- (BOOL)isLabeled {
    return self.labels != nil && self.labels.count != 0;
}

- (NSDictionary<NSString*,NSNumber*>*)labeledValues:(TIOVector*)vector {
    assert(self.isLabeled);
    
    NSMutableDictionary<NSString*,NSNumber*> *labeledValues = NSMutableDictionary.dictionary;
    
    for ( NSUInteger i = 0; i < vector.count; i++ ) {
        NSString *key = self.labels[i];
        NSNumber *value = vector[i];
        labeledValues[key] = value;
    }
    
    return labeledValues.copy;
}

@end
