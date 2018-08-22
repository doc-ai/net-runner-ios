//
//  ImageInputPreviewView.h
//  Net Runner
//
//  Created by Philip Dow on 7/16/18.
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
