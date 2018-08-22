//
//  TIOModelOptions.mm
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

#import "TIOModelOptions.h"

AVCaptureDevicePosition TIOModelOptionsAVCaptureDevicePositionFromString(NSString * _Nullable descriptor) {
    if ( [descriptor isEqualToString:@"front"] ) {
        return AVCaptureDevicePositionFront;
    } else if ( [descriptor isEqualToString:@"back"] ) {
        return AVCaptureDevicePositionBack;
    } else {
        return AVCaptureDevicePositionUnspecified;
    }
}

@implementation TIOModelOptions

- (instancetype)initWithDevicePosition:(AVCaptureDevicePosition)devicePosition {
    if (self = [super init]) {
        _devicePosition = devicePosition;
    }
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary*)dictionary {
    if ( dictionary == nil ) {
        return [self initWithDevicePosition:AVCaptureDevicePositionUnspecified];
    } else {
        return [self initWithDevicePosition:TIOModelOptionsAVCaptureDevicePositionFromString(dictionary[@"device_position"])];
    }
}

- (instancetype)init {
    return [self initWithDictionary:nil];
}

@end
