//
//  ImageInputPreviewView.h
//  Net Runner
//
//  Created by Philip Dow on 7/16/18.
//  Copyright © 2018 doc.ai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ImageInputPreviewView : UIView

/**
 * You may set the pixelBuffer on a thread other than the main thread
 */

@property (nonatomic) CVPixelBufferRef pixelBuffer;

/**
 * Determines if the alpha channel is displayed alongside the RGB buffers
 */

@property (nonatomic) BOOL showsAlphaChannel;

/**
 * The pixel format of the channes being previewed.
 * Must be `kCVPixelFormatType_32BGRA` or `kCVPixelFormatType_32ARGB`
 */

@property (nonatomic) OSType pixelFormat;

@end

NS_ASSUME_NONNULL_END
