//
//  TIOPixelBuffer.mm
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

#import "TIOPixelBuffer.h"

#import "TIOPixelBufferLayerDescription.h"
#import "TIOVisionPipeline.h"

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

- (nullable instancetype)initWithBytes:(const void *)bytes length:(NSUInteger)length description:(id<TIOLayerDescription>)description {
    
    TIOPixelBufferLayerDescription *pixelBufferDescription = (TIOPixelBufferLayerDescription*)description;
    CVPixelBufferRef pixelBuffer = NULL;
    CVReturn result;
    
    if ( description.isQuantized ) {
        result = TIOCreateCVPixelBufferFromTensor(
            &pixelBuffer,
            (uint8_t *)bytes,
            pixelBufferDescription.shape,
            pixelBufferDescription.pixelFormat,
            pixelBufferDescription.denormalizer
        );
    } else {
        result = TIOCreateCVPixelBufferFromTensor(
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

- (void)getBytes:(void *)buffer length:(NSUInteger)length description:(id<TIOLayerDescription>)description {
    assert([description isKindOfClass:TIOPixelBufferLayerDescription.class]);
    
    TIOPixelBufferLayerDescription *pixelBufferDescription = (TIOPixelBufferLayerDescription*)description;
    
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
        TIOVisionPipeline *pipeline = [[TIOVisionPipeline alloc] initWithTIOPixelBufferDescription:pixelBufferDescription];
        _transformedPixelBuffer = [pipeline transform:self.pixelBuffer orientation:self.orientation];
    }
    
    CVPixelBufferRetain(_transformedPixelBuffer);
    
    if ( description.isQuantized ) {
        TIOCopyCVPixelBufferToTensor(
            _transformedPixelBuffer,
            (uint8_t *)buffer,
            pixelBufferDescription.shape,
            pixelBufferDescription.normalizer
        );
    } else {
        TIOCopyCVPixelBufferToTensor(
            _transformedPixelBuffer,
            (float_t *)buffer,
            pixelBufferDescription.shape,
            pixelBufferDescription.normalizer
        );
    }
}

@end
