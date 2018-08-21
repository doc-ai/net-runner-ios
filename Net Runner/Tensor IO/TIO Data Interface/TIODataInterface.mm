//
//  TIODataInterface.m
//  TensorIO
//
//  Created by Philip Dow on 8/3/18.
//  Copyright © 2018 doc.ai. All rights reserved.
//

#import "TIODataInterface.h"

#import "TIOPixelBufferDescription.h"
#import "TIOVectorLayerDescription.h"

typedef enum : NSUInteger {
    TIODataInterfaceTypePixelBuffer,
    TIODataInterfaceTypeVector,
} TIODataInterfaceType;

@implementation TIODataInterface {
    TIODataInterfaceType _type;
}

- (instancetype)initWithName:(NSString*)name isInput:(BOOL)isInput pixelBufferDescription:(TIOPixelBufferDescription*)pixelBufferDescription {
    if ( self = [super init] ) {
        _name = name;
        _input = isInput;
        _type = TIODataInterfaceTypePixelBuffer;
        _dataDescription = pixelBufferDescription;
    }
    return self;
}

- (instancetype)initWithName:(NSString*)name isInput:(BOOL)isInput vectorDescription:(TIOVectorLayerDescription*)vectorDescription {
    if ( self = [super init] ) {
        _name = name;
        _input = isInput;
        _type = TIODataInterfaceTypeVector;
        _dataDescription = vectorDescription;
    }
    return self;
}

- (void)matchCasePixelBuffer:(TIOPixelBufferMatcher)pixelBufferMatcher caseVector:(TIOVectorMatcher)vectorMatcher {
    
    switch ( _type ) {
    case TIODataInterfaceTypePixelBuffer:
        pixelBufferMatcher((TIOPixelBufferDescription*)_dataDescription);
        break;
    case TIODataInterfaceTypeVector:
        vectorMatcher((TIOVectorLayerDescription*)_dataDescription);
        break;
    }
}

@end
