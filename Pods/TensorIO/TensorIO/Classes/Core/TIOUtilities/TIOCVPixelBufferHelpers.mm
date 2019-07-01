//
//  TIOCVPixelBufferHelpers.mm
//  TensorIO
//
//  Created by Philip Dow on 7/3/18.
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

//
//  Converting 4 channels to 3:
//
//  === To RGB ===
//
//  ARGB : RGB : vImageConvert_ARGB8888toRGB888
//  BGRA : RGB : vImageConvert_BGRA8888toRGB888
//
//  === To BGR ===
//
//  ARGB : BGR : None, have vImageConvert_RGBA8888toRGB888 instead. weird
//  BGRA : BGR : vImageConvert_BGRA8888toBGR888
//
//  Converting 3 channels to 3, (RGB <-> BGR):
//  None
//
//  Converting 4 channels to 4: (ARGB <-> BGRA):
//  None

#import "TIOCVPixelBufferHelpers.h"

/**
 * Release callback to free the bytes used by a pixel buffer
 */

void TIOCVPixelBufferCreateWithBytesReleaseCallback(void *releaseRefCon, const void *baseAddress) {
    if (baseAddress != NULL) { free((void *)baseAddress); }
}

CVPixelBufferRef TIOCVPixelBufferCopy(CVPixelBufferRef pixelBuffer) {
    CVPixelBufferLockBaseAddress(pixelBuffer, kNilOptions);
    
    int bufferWidth = (int)CVPixelBufferGetWidth(pixelBuffer);
    int bufferHeight = (int)CVPixelBufferGetHeight(pixelBuffer);
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(pixelBuffer);
    OSType format = CVPixelBufferGetPixelFormatType(pixelBuffer);
    unsigned char *baseAddress = (unsigned char *)CVPixelBufferGetBaseAddress(pixelBuffer);
    
    // Create new pixel buffer
    
    CVPixelBufferRef pixelBufferCopy = NULL;
    
    CVReturn status = CVPixelBufferCreate(
        kCFAllocatorDefault,
        bufferWidth,
        bufferHeight,
        format,
        NULL,
        &pixelBufferCopy);
    
    // Error handling
    
    if ( status != kCVReturnSuccess || pixelBufferCopy == NULL ) {
        CVPixelBufferUnlockBaseAddress(pixelBuffer, kNilOptions);
        return NULL;
    }
    
    // Copy source to destination
    
    CVPixelBufferLockBaseAddress(pixelBufferCopy, kNilOptions);
    unsigned char *copyBaseAddress = (unsigned char *)CVPixelBufferGetBaseAddress(pixelBufferCopy);
    
    memcpy(copyBaseAddress, baseAddress, bufferHeight * bytesPerRow);
    
    // Clean up
    
    CVPixelBufferUnlockBaseAddress(pixelBufferCopy, kNilOptions);
    CVPixelBufferUnlockBaseAddress(pixelBuffer, kNilOptions);
    
    return pixelBufferCopy;
}

CVPixelBufferRef TIOCVPixelBufferRotate(CVPixelBufferRef pixelBuffer, TIOCVPixelBufferCounterclockwiseRotation rotation) {
    CVPixelBufferLockBaseAddress(pixelBuffer, kNilOptions);
    
    const OSType pixelFormat = CVPixelBufferGetPixelFormatType(pixelBuffer);
    const size_t sourceRowBytes = (int)CVPixelBufferGetBytesPerRow(pixelBuffer);
    const int bufferWidth = (int)CVPixelBufferGetWidth(pixelBuffer);
    const int bufferHeight = (int)CVPixelBufferGetHeight(pixelBuffer);
    
    // Prepare source image buffer from input pixel buffer
    
    unsigned char* sourceBaseAddr = (unsigned char *)(CVPixelBufferGetBaseAddress(pixelBuffer));
    
    vImage_Buffer srcImageBuffer = {
        .width = (vImagePixelCount)bufferWidth,
        .height = (vImagePixelCount)bufferHeight,
        .rowBytes = sourceRowBytes,
        .data = sourceBaseAddr,
    };
    
    // Prepare destination image buffer with new block of memory
    
    unsigned char *destData = (unsigned char *)malloc(bufferHeight*sourceRowBytes);
    const size_t destRowBytes = bufferHeight * ( sourceRowBytes / bufferWidth );
    const int destBufferWidth = bufferHeight;
    const int destBufferHeight = bufferWidth;
    const uint8_t bgColor[4] = {0, 0, 0, 0};
    
    vImage_Buffer destImageBuffer = {
        .width = (vImagePixelCount)destBufferWidth,
        .height = (vImagePixelCount)destBufferHeight,
        .rowBytes = destRowBytes,
        .data = destData,
    };
    
    // Apply rotation
    
    vImage_Error err = vImageRotate90_ARGB8888(
        &srcImageBuffer,
        &destImageBuffer,
        rotation,
        bgColor,
        kvImageNoFlags
    );
    
    // Unlock source pixel buffer, we are done with it
    
    CVPixelBufferUnlockBaseAddress(pixelBuffer, kNilOptions);
    
    // Error handling
    
    if (err != kvImageNoError) {
        NSLog(@"vImage_Error: %ld", err);
        return NULL;
    }
    
    // Create new pixel buffer from image buffer
    
    CVPixelBufferRef destPixelBuffer;
    
    CVReturn status = CVPixelBufferCreateWithBytes(
        NULL,
        destBufferWidth,
        destBufferHeight,
        pixelFormat,
        destData,
        destRowBytes,
        TIOCVPixelBufferCreateWithBytesReleaseCallback,
        NULL,
        NULL,
        &destPixelBuffer
    );
    
    if (status != kCVReturnSuccess) {
        NSLog(@"Error creating destination pixel buffer");
        free(destData);
        return NULL;
    }
    
    return destPixelBuffer;
}


CVPixelBufferRef TIOCVPixelBufferCreateBGRAFromARGB(CVPixelBufferRef pixelBuffer) {
    // Feels like there should be an accelerate function that does this
    // Destination format is kCVPixelFormatType_32BGRA
    
    const OSType pixelFormat = CVPixelBufferGetPixelFormatType(pixelBuffer);
    const int bytesPerRow = (int)CVPixelBufferGetBytesPerRow(pixelBuffer);
    const int bufferWidth = (int)CVPixelBufferGetWidth(pixelBuffer);
    const int bufferHeight = (int)CVPixelBufferGetHeight(pixelBuffer);
    const int imageChannels = 4; // by definition (ARGB)
    
    assert( pixelFormat == kCVPixelFormatType_32ARGB );
    
    // Prepare destination pixel buffer
    
    CVPixelBufferRef destPixelBuffer;
    CVReturn status;
    
    status = CVPixelBufferCreate(
        kCFAllocatorDefault,
        bufferWidth,
        bufferHeight,
        kCVPixelFormatType_32BGRA,
        NULL,
        &destPixelBuffer
    );
    
    // Error handling
    
    if ( status != kCVReturnSuccess ) {
        NSLog(@"Unable to create destination pixel buffer, status: %u", status);
        return NULL;
    }
    
    // Debugging pixel buffer row padding
    
    const int destBytesPerRow = (int)CVPixelBufferGetBytesPerRow(destPixelBuffer);
    const int destBufferWidth = (int)CVPixelBufferGetWidth(destPixelBuffer);
    
#ifdef DEBUG
    
    if ( bytesPerRow != bufferWidth * imageChannels ) {
        NSLog(@"bytes per row is not equal to buffer width * number of channels: %ul, %ul",
                bytesPerRow, bufferWidth * imageChannels);
    }
    
    if ( destBytesPerRow != destBufferWidth * imageChannels ) {
        NSLog(@"dest bytes per row is not equal to buffer width * number of channels: %ul, %ul",
                destBytesPerRow, destBufferWidth * imageChannels);
    }
    
    if ( destBytesPerRow != bytesPerRow ) {
        NSLog(@"dest bytes per row is not equal to source bytes per row: %ul, %ul",
                destBytesPerRow, bytesPerRow);
    }
    
#endif

    // Copy pixels, reversing order
    
    CVPixelBufferLockBaseAddress(pixelBuffer, kNilOptions);
    CVPixelBufferLockBaseAddress(destPixelBuffer, kNilOptions);
    
    unsigned char* in = (unsigned char *)CVPixelBufferGetBaseAddress(pixelBuffer);
    unsigned char* out = (unsigned char *)CVPixelBufferGetBaseAddress(destPixelBuffer);

    for (int y = 0; y < bufferHeight; y++) {
        for (int x = 0; x < bufferWidth; x++) {
            unsigned char* inPixel = in + (y * bytesPerRow) + (x * imageChannels);
            unsigned char* outPixel = out + (y * destBytesPerRow) + (x * imageChannels);
            
            outPixel[0] = inPixel[3]; // blue
            outPixel[1] = inPixel[2]; // green
            outPixel[2] = inPixel[1]; // red
            outPixel[3] = inPixel[0]; // alpha
        }
    }

    CVPixelBufferUnlockBaseAddress(pixelBuffer, kNilOptions);
    CVPixelBufferUnlockBaseAddress(destPixelBuffer, kNilOptions);
    
    return destPixelBuffer;
}

CVPixelBufferRef TIOCVPixelBufferCreateARGBFromBGRA(CVPixelBufferRef pixelBuffer) {
    // Feels like there should be an accelerate function that does this
    // Destination format is kCVPixelFormatType_32ARGB
    
    const OSType pixelFormat = CVPixelBufferGetPixelFormatType(pixelBuffer);
    const int bytesPerRow = (int)CVPixelBufferGetBytesPerRow(pixelBuffer);
    const int bufferWidth = (int)CVPixelBufferGetWidth(pixelBuffer);
    const int bufferHeight = (int)CVPixelBufferGetHeight(pixelBuffer);
    const int imageChannels = 4; // by definition (BGRA)
    
    assert( pixelFormat == kCVPixelFormatType_32BGRA);
    
    // Prepare destination pixel buffer
    
    CVPixelBufferRef destPixelBuffer;
    CVReturn status;
    
    status = CVPixelBufferCreate(
        kCFAllocatorDefault,
        bufferWidth,
        bufferHeight,
        kCVPixelFormatType_32ARGB,
        NULL,
        &destPixelBuffer
    );
    
    // Error handling
    
    if ( status != kCVReturnSuccess ) {
        NSLog(@"Unable to create destination pixel buffer, status: %u", status);
        return NULL;
    }
    
    // Debugging pixel buffer row padding
    
    const int destBytesPerRow = (int)CVPixelBufferGetBytesPerRow(destPixelBuffer);
    const int destBufferWidth = (int)CVPixelBufferGetWidth(destPixelBuffer);
    
#ifdef DEBUG
    
    if ( bytesPerRow != bufferWidth * imageChannels ) {
        NSLog(@"bytes per row is not equal to buffer width * number of channels: %ul, %ul",
                bytesPerRow, bufferWidth * imageChannels);
    }
    
    if ( destBytesPerRow != destBufferWidth * imageChannels ) {
        NSLog(@"dest bytes per row is not equal to buffer width * number of channels: %ul, %ul",
                destBytesPerRow, destBufferWidth * imageChannels);
    }
    
    if ( destBytesPerRow != bytesPerRow ) {
        NSLog(@"dest bytes per row is not equal to source bytes per row: %ul, %ul",
                destBytesPerRow, bytesPerRow);
    }
    
#endif
    
    // Copy pixels, reversing order
    
    CVPixelBufferLockBaseAddress(pixelBuffer, kNilOptions);
    CVPixelBufferLockBaseAddress(destPixelBuffer, kNilOptions);
    
    unsigned char* in = (unsigned char *)CVPixelBufferGetBaseAddress(pixelBuffer);
    unsigned char* out = (unsigned char *)CVPixelBufferGetBaseAddress(destPixelBuffer);
    
    for (int y = 0; y < bufferHeight; y++) {
        for (int x = 0; x < bufferWidth; x++) {
            unsigned char* inPixel = in + (y * bytesPerRow) + (x * imageChannels);
            unsigned char* outPixel = out + (y * destBytesPerRow) + (x * imageChannels);
            
            outPixel[0] = inPixel[3]; // alpha
            outPixel[1] = inPixel[2]; // red
            outPixel[2] = inPixel[1]; // green
            outPixel[3] = inPixel[0]; // blue
        }
    }
    
    CVPixelBufferUnlockBaseAddress(pixelBuffer, kNilOptions);
    CVPixelBufferUnlockBaseAddress(destPixelBuffer, kNilOptions);
    
    return destPixelBuffer;
}

CVReturn TIOCVPixelBufferCopySeparateChannels(
    CVPixelBufferRef pixelBuffer,
    CVPixelBufferRef _Nullable * _Nonnull channel0Buffer,
    CVPixelBufferRef _Nullable * _Nonnull channel1Buffer,
    CVPixelBufferRef _Nullable * _Nonnull channel2Buffer,
    CVPixelBufferRef _Nullable * _Nonnull channel3Buffer) {
    
    // TODO: Use Accelerate functions to extract channels to planar format:
    // vImageConvert_ARGB8888toPlanar8
    // vImageConvert_XRGB8888ToPlanar8
    // vImageConvert_BGRX8888ToPlanar8
    // Then create Pixel Buffers from CVPixelBufferCreateWithPlanarBytes
    
    const OSType pixelFormat = CVPixelBufferGetPixelFormatType(pixelBuffer);
    const int bytesPerRow = (int)CVPixelBufferGetBytesPerRow(pixelBuffer);
    const int bufferWidth = (int)CVPixelBufferGetWidth(pixelBuffer);
    const int bufferHeight = (int)CVPixelBufferGetHeight(pixelBuffer);
    const int imageChannels = 4;
    
    assert(pixelFormat == kCVPixelFormatType_32ARGB ||
           pixelFormat == kCVPixelFormatType_32BGRA);
    
    // Prepare channel buffers
    
    const OSType channelFormat = kCVPixelFormatType_32ARGB;
    
    CVPixelBufferRef channel0;
    CVPixelBufferRef channel1;
    CVPixelBufferRef channel2;
    CVPixelBufferRef channel3;
    
    CVReturn status0;
    CVReturn status1;
    CVReturn status2;
    CVReturn status3;
    
    status0 = CVPixelBufferCreate(
        kCFAllocatorDefault,
        bufferWidth,
        bufferHeight,
        channelFormat,
        NULL,
        &channel0
    );
    
    status1 = CVPixelBufferCreate(
        kCFAllocatorDefault,
        bufferWidth,
        bufferHeight,
        channelFormat,
        NULL,
        &channel1
    );
    
    status2 = CVPixelBufferCreate(
        kCFAllocatorDefault,
        bufferWidth,
        bufferHeight,
        channelFormat,
        NULL,
        &channel2
    );
    
    status3 = CVPixelBufferCreate(
        kCFAllocatorDefault,
        bufferWidth,
        bufferHeight,
        channelFormat,
        NULL,
        &channel3
    );
    
    if ( status0 != kCVReturnSuccess
      || status1 != kCVReturnSuccess
      || status2 != kCVReturnSuccess
      || status3 != kCVReturnSuccess ) {
        CVPixelBufferRelease(channel0);
        CVPixelBufferRelease(channel1);
        CVPixelBufferRelease(channel2);
        CVPixelBufferRelease(channel3);
        return kCVReturnError;
    }
    
    // Debugging pixel buffer row padding
    
    const int destBytesPerRow = (int)CVPixelBufferGetBytesPerRow(channel0);
    const int destBufferWidth = (int)CVPixelBufferGetWidth(channel0);
    
#ifdef DEBUG
    
    if ( bytesPerRow != bufferWidth * imageChannels ) {
        NSLog(@"bytes per row is not equal to buffer width * number of channels: %ul, %ul",
                bytesPerRow, bufferWidth * imageChannels);
    }
    
    if ( destBytesPerRow != destBufferWidth * imageChannels ) {
        NSLog(@"dest bytes per row is not equal to buffer width * number of channels: %ul, %ul",
                destBytesPerRow, destBufferWidth * imageChannels);
    }
    
    if ( destBytesPerRow != bytesPerRow ) {
        NSLog(@"dest bytes per row is not equal to source bytes per row: %ul, %ul",
                destBytesPerRow, bytesPerRow);
    }
    
#endif
    
    // Copy individual channels into new pixel buffers
    
    CVPixelBufferLockBaseAddress(pixelBuffer, kNilOptions);
    CVPixelBufferLockBaseAddress(channel0, kNilOptions);
    CVPixelBufferLockBaseAddress(channel1, kNilOptions);
    CVPixelBufferLockBaseAddress(channel2, kNilOptions);
    CVPixelBufferLockBaseAddress(channel3, kNilOptions);
    
    unsigned char* in = (unsigned char *)CVPixelBufferGetBaseAddress(pixelBuffer);
    unsigned char* out0 = (unsigned char *)CVPixelBufferGetBaseAddress(channel0);
    unsigned char* out1 = (unsigned char *)CVPixelBufferGetBaseAddress(channel1);
    unsigned char* out2 = (unsigned char *)CVPixelBufferGetBaseAddress(channel2);
    unsigned char* out3 = (unsigned char *)CVPixelBufferGetBaseAddress(channel3);
    
    for (int y = 0; y < bufferHeight; y++) {
        for (int x = 0; x < bufferWidth; x++) {
            unsigned char* inPixel = in + (y * bytesPerRow) + (x * imageChannels);
            unsigned char* outPixel0 = out0 + (y * destBytesPerRow) + (x * imageChannels);
            unsigned char* outPixel1 = out1 + (y * destBytesPerRow) + (x * imageChannels);
            unsigned char* outPixel2 = out2 + (y * destBytesPerRow) + (x * imageChannels);
            unsigned char* outPixel3 = out3 + (y * destBytesPerRow) + (x * imageChannels);
    
            // Alpha channel is channel 0 (out is ARGB)
            
            outPixel0[0] = outPixel1[0] = outPixel2[0] = outPixel3[0] = 255;
            
            // Copy channels 0,1,2,3 into every channel of dest 0,1,2,3 respectively,
            // producing a 3 channel grayscale image from a single source channel
            // What we don't know is if source is ARGB or BGRA, but this will visually tell us
            
            outPixel0[1] = outPixel0[2] = outPixel0[3] = inPixel[0];
            outPixel1[1] = outPixel1[2] = outPixel1[3] = inPixel[1];
            outPixel2[1] = outPixel2[2] = outPixel2[3] = inPixel[2];
            outPixel3[1] = outPixel3[2] = outPixel3[3] = inPixel[3];
        }
    }

    CVPixelBufferUnlockBaseAddress(pixelBuffer, kNilOptions);
    CVPixelBufferUnlockBaseAddress(channel0, kNilOptions);
    CVPixelBufferUnlockBaseAddress(channel1, kNilOptions);
    CVPixelBufferUnlockBaseAddress(channel2, kNilOptions);
    CVPixelBufferUnlockBaseAddress(channel3, kNilOptions);
    
    *channel0Buffer = channel0;
    *channel1Buffer = channel1;
    *channel2Buffer = channel2;
    *channel3Buffer = channel3;
    
    return kCVReturnSuccess;
}

CVPixelBufferRef TIOCVPixelBufferResizeToSquare(CVPixelBufferRef srcPixelBuffer, CGSize size) {
    CVPixelBufferLockBaseAddress(srcPixelBuffer, kNilOptions);
    
    OSType sourcePixelFormat = CVPixelBufferGetPixelFormatType(srcPixelBuffer);
    assert(sourcePixelFormat == kCVPixelFormatType_32ARGB ||
           sourcePixelFormat == kCVPixelFormatType_32BGRA);
    
    const int width = (int)CVPixelBufferGetWidth(srcPixelBuffer);
    const int height = (int)CVPixelBufferGetHeight(srcPixelBuffer);
    
    assert(size.width == size.height);
    assert(width >= size.width);
    assert(height >= size.height);
    
    // Calculate crop dimensions
    
    int cropX;
    int cropY;
    int cropWidth;
    int cropHeight;
    
    if ( height > width) {
        cropY = (height-width)/2;
        cropX = 0;
        cropHeight = width;
        cropWidth = width;
    } else {
        cropX = (width-height)/2;
        cropY = 0;
        cropHeight = height;
        cropWidth = height;
    }
    
    int destWidth = size.width;
    int destHeight = size.height;
    
    // Prepare source image buffer
    
    unsigned char* sourceBaseAddr = (unsigned char *)(CVPixelBufferGetBaseAddress(srcPixelBuffer));
    const int sourceRowBytes = (int)CVPixelBufferGetBytesPerRow(srcPixelBuffer);
    auto offset = cropY*sourceRowBytes + cropX*4;
    
    vImage_Buffer srcImageBuffer;
    
    srcImageBuffer.width = (vImagePixelCount)cropWidth;
    srcImageBuffer.height = (vImagePixelCount)cropHeight;
    srcImageBuffer.rowBytes = sourceRowBytes;
    srcImageBuffer.data = sourceBaseAddr + offset;
    
    // Prepare destination image buffer
    
    vImage_Buffer destImageBuffer;
    
    const int destRowBytes = 4*destWidth;
    unsigned char *destData = (unsigned char *)malloc(destHeight*destRowBytes);
    
    destImageBuffer.width = (vImagePixelCount)destWidth;
    destImageBuffer.height = (vImagePixelCount)destHeight;
    destImageBuffer.rowBytes = destRowBytes;
    destImageBuffer.data = destData;
    
    // Scale source into destination buffer
    
    auto error = vImageScale_ARGB8888(&srcImageBuffer, &destImageBuffer, NULL, 0);
    
    // Finished with the source pixel buffer, clean up
    
    CVPixelBufferUnlockBaseAddress(srcPixelBuffer, kNilOptions);
    
    // Error handling
    
    if (error != kvImageNoError) {
        NSLog(@"Error scaling pixel buffer");
        free(destData);
        return NULL;
    }
    
    // Create a new pixel buffer from the scaled image buffer
    
    CVPixelBufferRef destPixelBuffer;
    
    auto status = CVPixelBufferCreateWithBytes(
        NULL,
        destWidth,
        destHeight,
        sourcePixelFormat,
        destData,
        destRowBytes,
        TIOCVPixelBufferCreateWithBytesReleaseCallback,
        NULL,
        NULL,
        &destPixelBuffer
    );
    
    if (status != kCVReturnSuccess) {
        NSLog(@"Error creating destination pixel buffer");
        free(destData);
        return NULL;
    }
    
    return destPixelBuffer;
}
