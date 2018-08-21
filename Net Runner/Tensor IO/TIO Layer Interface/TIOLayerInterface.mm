//
//  TIOLayerInterface.m
//  TensorIO
//
//  Created by Philip Dow on 8/3/18.
//  Copyright © 2018 doc.ai. All rights reserved.
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

- (instancetype)initWithName:(NSString*)name isInput:(BOOL)isInput pixelBufferDescription:(TIOPixelBufferLayerDescription*)pixelBufferDescription {
    if ( self = [super init] ) {
        _name = name;
        _input = isInput;
        _type = TIOLayerInterfaceTypePixelBuffer;
        _dataDescription = pixelBufferDescription;
    }
    return self;
}

- (instancetype)initWithName:(NSString*)name isInput:(BOOL)isInput vectorDescription:(TIOVectorLayerDescription*)vectorDescription {
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
        pixelBufferMatcher((TIOPixelBufferLayerDescription*)_dataDescription);
        break;
    case TIOLayerInterfaceTypeVector:
        vectorMatcher((TIOVectorLayerDescription*)_dataDescription);
        break;
    }
}

@end
