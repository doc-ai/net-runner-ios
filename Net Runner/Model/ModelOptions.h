//
//  ModelOptions.h
//  Net Runner
//
//  Created by Philip Dow on 7/28/18.
//  Copyright © 2018 doc.ai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

AVCaptureDevicePosition ModelOptionsAVCaptureDevicePositionFromString(NSString * _Nullable descriptor);

@interface ModelOptions : NSObject

/**
 * Preferred device position. If the device position is unspecified at initialization,
 * `AVCaptureDevicePositionUnspecified` will be used.
 */

@property (readonly) AVCaptureDevicePosition devicePosition;

/**
 * Designated initializer.
 */

- (instancetype)initWithDevicePosition:(AVCaptureDevicePosition)devicePosition;

/**
 * Convenience initializer used when reading from an ModelBundle.
 */

- (instancetype)initWithDictionary:(nullable NSDictionary*)dictionary;

@end

NS_ASSUME_NONNULL_END
