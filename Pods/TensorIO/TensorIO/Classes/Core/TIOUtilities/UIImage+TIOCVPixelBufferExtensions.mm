//
//  UIImage+TIOCVPixelBufferExtensions.mm
//  TensorIO
//
//  Created by Philip Dow on 7/6/18.
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

#import "UIImage+TIOCVPixelBufferExtensions.h"
#import "TIOObjcDefer.h"

@implementation UIImage (CVPixelBuffer)

- (nullable instancetype)initWithPixelBuffer:(CVPixelBufferRef)pixelBuffer {
    if (pixelBuffer == NULL) {
        return nil;
    }
    
    CGImageRef imageRef;
    VTCreateCGImageFromCVPixelBuffer(pixelBuffer, nil, &imageRef);
    if (imageRef == NULL) {
        return nil;
    }
    
    UIImage *image = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    return image;
}

- (nullable instancetype)initWithPixelBuffer:(CVPixelBufferRef)pixelBuffer scale:(CGFloat)scale orientation:(UIImageOrientation)orientation {
    if (pixelBuffer == NULL) {
        return nil;
    }
    
    CGImageRef imageRef;
    VTCreateCGImageFromCVPixelBuffer(pixelBuffer, nil, &imageRef);
    if (imageRef == NULL) {
        return nil;
    }
    
    UIImage *image = [UIImage imageWithCGImage:imageRef scale:scale orientation:orientation];
    CGImageRelease(imageRef);
    return image;
}

// MARK: -

- (nullable CVPixelBufferRef)pixelBuffer {
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    CVPixelBufferRef pixelBuffer = [self pixelBuffer:kCVPixelFormatType_32ARGB colorSpace:colorSpace alphaInfo:kCGImageAlphaNoneSkipFirst];
    
    CGColorSpaceRelease(colorSpace);
    
    return pixelBuffer;
    
    // kCVPixelFormatType_32ARGB // kCGImageAlphaNoneSkipFirst
    // kCVPixelFormatType_32BGRA // kCGImageAlphaNoneSkipLast
    
    // Note that using the kCVPixelFormatType_32BGRA/kCGImageAlphaNoneSkipLast pair doesn't really seem to work
    // The alpha is correctly moved to the last channel with kCVPixelFormatType_32BGRA, but the first channels are still organized as RGB
    // Possibly because of the use of CGColorSpaceCreateDeviceRGB
}

- (nullable CVPixelBufferRef)pixelBuffer:(OSType)format colorSpace:(CGColorSpaceRef)colorSpace alphaInfo:(CGImageAlphaInfo)alphaInfo {
    CVPixelBufferRef pixelBuffer;
    
    // Create pixel buffer
    
    CGFloat width = self.size.width;
    CGFloat height = self.size.height;
    
    NSDictionary *attrs = @{
        (NSString*)kCVPixelBufferCGImageCompatibilityKey: @(YES),
        (NSString*)kCVPixelBufferCGBitmapContextCompatibilityKey: @(YES)
    };
    
    CVReturn status = CVPixelBufferCreate(
        kCFAllocatorDefault,
        (int)width,
        (int)height,
        format,
        (__bridge CFDictionaryRef)attrs,
        &pixelBuffer
    );
    
    if ( status != kCVReturnSuccess ) {
        return nil;
    }
    
    tio_defer_block {
        CFAutorelease(pixelBuffer);
    };
    
    // Prepare a bitmap context for the buffer
    
    CVPixelBufferLockBaseAddress(pixelBuffer, kNilOptions);
    
    unsigned char* addr = (unsigned char*)(CVPixelBufferGetBaseAddress(pixelBuffer));
    const int bytesPerRow = (int)CVPixelBufferGetBytesPerRow(pixelBuffer);
    
    CGContextRef context = CGBitmapContextCreate(
        addr,
        (int)width,
        (int)height,
        8,
        bytesPerRow,
        colorSpace,
        alphaInfo
    );
    
    if ( context == NULL ) {
        CVPixelBufferUnlockBaseAddress(pixelBuffer, kNilOptions);
        return nil;
    }
    
    UIGraphicsPushContext(context);
    
    CGContextTranslateCTM(context, 0, height);
    CGContextScaleCTM(context, 1, -1);
    
    [self drawInRect:CGRectMake(0, 0, width, height)];
    
    UIGraphicsPopContext();
    
    CGContextRelease(context);
    CVPixelBufferUnlockBaseAddress(pixelBuffer, kNilOptions);
    
    return pixelBuffer;
}

@end
