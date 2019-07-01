//
//  TIOVectorLayerDescription.mm
//  TensorIO
//
//  Created by Philip Dow on 8/5/18.
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

#import "TIOVectorLayerDescription.h"
#import "NSArray+TIOExtensions.h"

@implementation TIOVectorLayerDescription

- (instancetype)initWithShape:(NSArray<NSNumber*>*)shape
    batched:(BOOL)batched
    dtype:(TIODataType)dtype
    labels:(nullable NSArray<NSString*>*)labels
    quantized:(BOOL)quantized
    quantizer:(nullable TIODataQuantizer)quantizer
    dequantizer:(TIODataDequantizer)dequantizer {
    
    if (self=[super init]) {
        _shape = shape;
        _batched = batched;
        _dtype = dtype;
        _labels = labels.copy;
        _quantized = quantized;
        _quantizer = quantizer;
        _dequantizer = dequantizer;
        
        _length = ABS(shape.product);
    }
    return self;
}

- (BOOL)isLabeled {
    return self.labels != nil && self.labels.count != 0;
}

- (NSDictionary<NSString*,NSNumber*>*)labeledValues:(TIOVector *)vector {
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
