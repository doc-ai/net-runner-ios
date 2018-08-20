//
//  TIOModelOptions.h
//  Net Runner
//
//  Created by Philip Dow on 7/28/18.
//  Copyright © 2018 doc.ai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

AVCaptureDevicePosition TIOModelOptionsAVCaptureDevicePositionFromString(NSString * _Nullable descriptor);

@interface TIOModelOptions : NSObject

/**
 * Preferred device position.
 *
 * If the device position is unspecified at initialization, `AVCaptureDevicePositionUnspecified` will be used,
 * which will then typically default to the back facing camera.
 */

@property (readonly) AVCaptureDevicePosition devicePosition;

/**
 * Designated initializer.
 */

- (instancetype)initWithDevicePosition:(AVCaptureDevicePosition)devicePosition NS_DESIGNATED_INITIALIZER;

/**
 * Convenience initializer used when reading from a TIOModelBundle.
 */

- (instancetype)initWithDictionary:(nullable NSDictionary*)dictionary;

@end

NS_ASSUME_NONNULL_END
