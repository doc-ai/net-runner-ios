//
//  TIOPixelBufferLayerDescription.mm
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

#import "TIOPixelBufferLayerDescription.h"

@implementation TIOPixelBufferLayerDescription

- (instancetype)initWithPixelFormat:(OSType)pixelFormat shape:(TIOImageVolume)shape batched:(BOOL)batched normalizer:(nullable TIOPixelNormalizer)normalizer denormalizer:(nullable TIOPixelDenormalizer)denormalizer quantized:(BOOL)quantized {
    if (self=[super init]) {
        _pixelFormat = pixelFormat;
        _shape = shape;
        _batched = batched;
        _normalizer = normalizer;
        _denormalizer = denormalizer;
        _quantized = quantized;
    }
    return self;
}

@end
