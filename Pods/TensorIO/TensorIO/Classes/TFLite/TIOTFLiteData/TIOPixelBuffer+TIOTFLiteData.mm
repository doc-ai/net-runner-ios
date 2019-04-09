//
//  TIOPixelBuffer+TIOTFLiteData.mm
//  TensorIO
//
//  Created by Phil Dow on 4/8/19.
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

#import "TIOPixelBuffer+TIOTFLiteData.h"

#import "TIOPixelBufferLayerDescription.h"
#import "TIOPixelBufferToTensorHelpers.h"
#import "TIOVisionPipeline.h"

@interface TIOPixelBuffer (TIOTFLiteData_Protected)

@property (readwrite) CVPixelBufferRef transformedPixelBuffer;

@end

@implementation TIOPixelBuffer (TIOTFLiteData)

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
    
    CVPixelBufferRef pixelBuffer = self.pixelBuffer;
    CGImagePropertyOrientation orientation = self.orientation;
    
    CVPixelBufferRef transformedPixelBuffer;
    
    int width = (int)CVPixelBufferGetWidth(pixelBuffer);
    int height = (int)CVPixelBufferGetHeight(pixelBuffer);
    OSType pixelFormat = CVPixelBufferGetPixelFormatType(pixelBuffer);
    
    if ( width == pixelBufferDescription.shape.width
        && height == pixelBufferDescription.shape.height
        && pixelFormat == pixelBufferDescription.pixelFormat
        && orientation == kCGImagePropertyOrientationUp ) {
        transformedPixelBuffer = pixelBuffer;
    } else {
        TIOVisionPipeline *pipeline = [[TIOVisionPipeline alloc] initWithTIOPixelBufferDescription:pixelBufferDescription];
        transformedPixelBuffer = [pipeline transform:self.pixelBuffer orientation:self.orientation];
    }
    
    CVPixelBufferRetain(transformedPixelBuffer);
    self.transformedPixelBuffer = transformedPixelBuffer;
    
    if ( description.isQuantized ) {
        TIOCopyCVPixelBufferToTensor(
            transformedPixelBuffer,
            (uint8_t *)buffer,
            pixelBufferDescription.shape,
            pixelBufferDescription.normalizer
        );
    } else {
        TIOCopyCVPixelBufferToTensor(
            transformedPixelBuffer,
            (float_t *)buffer,
            pixelBufferDescription.shape,
            pixelBufferDescription.normalizer
        );
    }
}

@end
