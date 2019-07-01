//
//  TIOLayerInterface.mm
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

#import "TIOLayerInterface.h"

#import "TIOPixelBufferLayerDescription.h"
#import "TIOVectorLayerDescription.h"

typedef enum : NSUInteger {
    TIOLayerInterfaceTypePixelBuffer,
    TIOLayerInterfaceTypeVector,
} TIOLayerInterfaceType;

@implementation TIOLayerInterface {
    TIOLayerInterfaceType _type;
}

- (instancetype)initWithName:(NSString *)name isInput:(BOOL)isInput pixelBufferDescription:(TIOPixelBufferLayerDescription *)pixelBufferDescription {
    if ( self = [super init] ) {
        _name = name;
        _input = isInput;
        _type = TIOLayerInterfaceTypePixelBuffer;
        _dataDescription = pixelBufferDescription;
    }
    return self;
}

- (instancetype)initWithName:(NSString *)name isInput:(BOOL)isInput vectorDescription:(TIOVectorLayerDescription *)vectorDescription {
    if ( self = [super init] ) {
        _name = name;
        _input = isInput;
        _type = TIOLayerInterfaceTypeVector;
        _dataDescription = vectorDescription;
    }
    return self;
}

- (void)matchCasePixelBuffer:(TIOPixelBufferMatcher)pixelBufferMatcher caseVector:(TIOVectorMatcher)vectorMatcher {
    
    switch ( _type ) {
    case TIOLayerInterfaceTypePixelBuffer:
        pixelBufferMatcher((TIOPixelBufferLayerDescription *)_dataDescription);
        break;
    case TIOLayerInterfaceTypeVector:
        vectorMatcher((TIOVectorLayerDescription *)_dataDescription);
        break;
    }
}

@end
