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
#import "TIOStringLayerDescription.h"

typedef enum : NSUInteger {
    TIOLayerInterfaceTypePixelBuffer,
    TIOLayerInterfaceTypeVector,
    TIOLayerInterfaceTypeString
} TIOLayerInterfaceType;

@implementation TIOLayerInterface {
    id<TIOLayerDescription> _layerDescription;
    TIOLayerInterfaceType _type;
}

- (instancetype)initWithName:(NSString *)name JSON:(nullable NSDictionary *)JSON mode:(TIOLayerInterfaceMode)mode pixelBufferDescription:(TIOPixelBufferLayerDescription *)pixelBufferDescription {
    if ( self = [super init] ) {
        _name = name;
        _JSON = JSON;
        _mode = mode;
        _type = TIOLayerInterfaceTypePixelBuffer;
        _layerDescription = pixelBufferDescription;
    }
    return self;
}

- (instancetype)initWithName:(NSString *)name JSON:(nullable NSDictionary *)JSON mode:(TIOLayerInterfaceMode)mode vectorDescription:(TIOVectorLayerDescription *)vectorDescription {
    if ( self = [super init] ) {
        _name = name;
        _JSON = JSON;
        _mode = mode;
        _type = TIOLayerInterfaceTypeVector;
        _layerDescription = vectorDescription;
    }
    return self;
}

- (instancetype)initWithName:(NSString *)name JSON:(nullable NSDictionary *)JSON mode:(TIOLayerInterfaceMode)mode stringDescription:(TIOStringLayerDescription *)stringDescription {
    if ( self = [super init] ) {
        _name = name;
        _JSON = JSON;
        _mode = mode;
        _type = TIOLayerInterfaceTypeString;
        _layerDescription = stringDescription;
    }
    return self;
}

// MARK: -

- (void)matchCasePixelBuffer:(TIOPixelBufferMatcher)pixelBufferMatcher caseVector:(TIOVectorMatcher)vectorMatcher caseString:(TIOStringMatcher)stringMatcher {
    switch ( _type ) {
    case TIOLayerInterfaceTypePixelBuffer:
        pixelBufferMatcher((TIOPixelBufferLayerDescription *)_layerDescription);
        break;
    case TIOLayerInterfaceTypeVector:
        vectorMatcher((TIOVectorLayerDescription *)_layerDescription);
        break;
    case TIOLayerInterfaceTypeString:
        stringMatcher((TIOStringLayerDescription *)_layerDescription);
        break;
    }
}

- (BOOL)isEqualToLayerInterface:(TIOLayerInterface *)otherLayerInterface {
    if ( self.JSON == nil || otherLayerInterface.JSON == nil ) {
        NSLog(@"Unable to compare interfaces because one or the other JSON value is nil");
        return NO;
    }
    
    return [self.JSON isEqualToDictionary:otherLayerInterface.JSON];
}

- (BOOL)isEqual:(id)object {
    if ( ![object isKindOfClass:TIOLayerInterface.class] ) {
        return NO;
    }
    
    return [self isEqualToLayerInterface:object];
}

@end
