//
//  TIOVisionPipeline.mm
//  TensorIO
//
//  Created by Philip Dow on 7/11/18.
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

#import "TIOVisionPipeline.h"

#import "TIOModel.h"
#import "TIOCVPixelBufferHelpers.h"
#import "TIOObjcDefer.h"
#import "TIOPixelBufferLayerDescription.h"

@implementation TIOVisionPipeline

- (instancetype)initWithTIOPixelBufferDescription:(TIOPixelBufferLayerDescription *)pixelBufferDescription {
    if (self = [super init]) {
        _pixelBufferDescription = pixelBufferDescription;
    }
    return self;
}

- (nullable CVPixelBufferRef)transform:(CVPixelBufferRef)pixelBuffer orientation:(CGImagePropertyOrientation)orientation {
    CVPixelBufferRef resizedPixelBuffer = NULL;
    CVPixelBufferRef rotatedPixelBuffer = NULL;
    CVPixelBufferRef formattedPixelBuffer = NULL;
    
    // Resize pixel buffer
    // :: pixelBuffer -> resizedPixelBuffer
    
    const size_t srcWidth = CVPixelBufferGetWidth(pixelBuffer);
    const size_t srcHeight = CVPixelBufferGetHeight(pixelBuffer);
    const size_t dstWidth = self.pixelBufferDescription.imageVolume.width;
    const size_t dstHeight = self.pixelBufferDescription.imageVolume.height;
    
    if (srcWidth != dstWidth || srcHeight != dstHeight) {
        resizedPixelBuffer = TIOCVPixelBufferResizeToSquare(pixelBuffer, CGSizeMake(dstWidth, dstHeight));
    } else {
        resizedPixelBuffer = pixelBuffer;
        CVPixelBufferRetain(resizedPixelBuffer);
    }
    
    // Error handling and cleanup
    
    if (resizedPixelBuffer == NULL) {
        NSLog(@"Unable to resize pixel buffer");
        return NULL;
    }
    
    tio_defer_block {
        CVPixelBufferRelease(resizedPixelBuffer);
    };
    
    // Rotate pixel buffer
    // :: resizedPixelBuffer -> rotatedPixelBuffer
    
    switch (orientation) {
    case kCGImagePropertyOrientationUp:
        rotatedPixelBuffer = resizedPixelBuffer;
        CVPixelBufferRetain(rotatedPixelBuffer);
        break;
    case kCGImagePropertyOrientationRight:
        rotatedPixelBuffer = TIOCVPixelBufferRotate(resizedPixelBuffer, Rotate270Degrees);
        break;
    case kCGImagePropertyOrientationDown:
        rotatedPixelBuffer = TIOCVPixelBufferRotate(resizedPixelBuffer, Rotate180Degrees);
        break;
    case kCGImagePropertyOrientationLeft:
        rotatedPixelBuffer = TIOCVPixelBufferRotate(resizedPixelBuffer, Rotate90Degrees);
        break;
    default:
        NSLog(@"Unknown orientation, assuming kCGImagePropertyOrientationUp, reported: %d", orientation);
        rotatedPixelBuffer = resizedPixelBuffer;
        CVPixelBufferRetain(rotatedPixelBuffer);
        break;
    }
    
    // Error handling and cleanup
    
    if (rotatedPixelBuffer == NULL) {
        NSLog(@"Unable to rotate pixel buffer");
        return NULL;
    }
    
    tio_defer_block {
        CVPixelBufferRelease(rotatedPixelBuffer);
    };
    
    // Convert pixel buffer to ARGB
    // :: rotatedPixelBuffer ->formattedPixelBuffer
    
    const OSType srcFormat = CVPixelBufferGetPixelFormatType(rotatedPixelBuffer);
    const OSType dstFormat = self.pixelBufferDescription.pixelFormat;
    
    assert(srcFormat == kCVPixelFormatType_32BGRA || srcFormat == kCVPixelFormatType_32ARGB);
    
    if (srcFormat == kCVPixelFormatType_32BGRA && dstFormat == kCVPixelFormatType_32ARGB ) {
        formattedPixelBuffer = TIOCVPixelBufferCreateARGBFromBGRA(rotatedPixelBuffer);
    } else if (srcFormat == kCVPixelFormatType_32ARGB && dstFormat == kCVPixelFormatType_32BGRA) {
        formattedPixelBuffer = TIOCVPixelBufferCreateBGRAFromARGB(rotatedPixelBuffer);
    } else {
        formattedPixelBuffer = rotatedPixelBuffer;
        CVPixelBufferRetain(formattedPixelBuffer);
    }
    
    // Error handling and cleanup
    
    if (formattedPixelBuffer == NULL) {
        NSLog(@"Unable to convert pixel buffer format");
        return NULL;
    }
    
    tio_defer_block {
        CFAutorelease(formattedPixelBuffer);
    };
    
    // Return the formatted pixel buffer
    
    return formattedPixelBuffer;
}

@end
