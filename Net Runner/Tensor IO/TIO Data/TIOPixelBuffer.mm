//
//  TIOPixelBuffer.m
//  Net Runner Parser
//
//  Created by Philip Dow on 8/3/18.
//  Copyright © 2018 doc.ai. All rights reserved.
//

#import "TIOPixelBuffer.h"

#import "TIOPixelBufferDescription.h"
#import "VisionPipeline.h"

@implementation TIOPixelBuffer

- (instancetype)initWithPixelBuffer:(CVPixelBufferRef)pixelBuffer orientation:(CGImagePropertyOrientation)orientation {
    if (self = [super init]) {
        _orientation = orientation;
        _pixelBuffer = pixelBuffer;
        CVPixelBufferRetain(_pixelBuffer);
    }
    return self;
}

- (void)dealloc {
    CVPixelBufferRelease(_pixelBuffer);
    CVPixelBufferRelease(_transformedPixelBuffer);
}

- (nullable instancetype)initWithBytes:(const void *)bytes length:(NSUInteger)length description:(id<TIODataDescription>)description {
    
    TIOPixelBufferDescription *pixelBufferDescription = (TIOPixelBufferDescription*)description;
    CVPixelBufferRef pixelBuffer = NULL;
    CVReturn result;
    
    if ( description.isQuantized ) {
        result = CVPixelBufferCreateFromTensor(
            &pixelBuffer,
            (uint8_t *)bytes,
            pixelBufferDescription.shape,
            pixelBufferDescription.pixelFormat,
            pixelBufferDescription.denormalizer
        );
    } else {
        result = CVPixelBufferCreateFromTensor(
            &pixelBuffer,
            (float_t *)bytes,
            pixelBufferDescription.shape,
            pixelBufferDescription.pixelFormat,
            pixelBufferDescription.denormalizer
        );
    }
    
    if ( result != kCVReturnSuccess ) {
        NSLog(@"There was a problem creating the pixel buffer from the tensor");
        return nil;
    }
    
    return [self initWithPixelBuffer:pixelBuffer orientation:kCGImagePropertyOrientationUp];
}

- (void)getBytes:(void *)buffer length:(NSUInteger)length description:(id<TIODataDescription>)description {
    assert([description isKindOfClass:TIOPixelBufferDescription.class]);
    
    TIOPixelBufferDescription *pixelBufferDescription = (TIOPixelBufferDescription*)description;
    
    // If the pixel buffer is already the right size, format, and orientation simpy copy it to the tensor.
    // Otherwise, run it through the vision pipeline
    
    int width = (int)CVPixelBufferGetWidth(_pixelBuffer);
    int height = (int)CVPixelBufferGetHeight(_pixelBuffer);
    OSType pixelFormat = CVPixelBufferGetPixelFormatType(_pixelBuffer);
    
    if ( width == pixelBufferDescription.shape.width
        && height == pixelBufferDescription.shape.height
        && pixelFormat == pixelBufferDescription.pixelFormat
        && _orientation == kCGImagePropertyOrientationUp ) {
        _transformedPixelBuffer = _pixelBuffer;
    } else {
        VisionPipeline *pipeline = [[VisionPipeline alloc] initWithTIOPixelBufferDescription:pixelBufferDescription];
        _transformedPixelBuffer = [pipeline transform:self.pixelBuffer orientation:self.orientation];
    }
    
    CVPixelBufferRetain(_transformedPixelBuffer);
    
    if ( description.isQuantized ) {
        CVPixelBufferCopyToTensor(
            _transformedPixelBuffer,
            (uint8_t *)buffer,
            pixelBufferDescription.shape,
            pixelBufferDescription.normalizer
        );
    } else {
        CVPixelBufferCopyToTensor(
            _transformedPixelBuffer,
            (float_t *)buffer,
            pixelBufferDescription.shape,
            pixelBufferDescription.normalizer
        );
    }
}

@end
