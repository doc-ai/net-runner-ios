//
//  TIOModelOptions.h
//  TensorIO
//
//  Created by Philip Dow on 7/28/18.
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
