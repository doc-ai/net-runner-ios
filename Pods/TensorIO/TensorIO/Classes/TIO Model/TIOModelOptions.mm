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

static NSString * const TIOModelOptionOutputFormatNone = @"";

AVCaptureDevicePosition TIOModelOptionsAVCaptureDevicePositionFromString(NSString * _Nullable descriptor) {
    if ( [descriptor isEqualToString:@"front"] ) {
        return AVCaptureDevicePositionFront;
    } else if ( [descriptor isEqualToString:@"back"] ) {
        return AVCaptureDevicePositionBack;
    } else {
        return AVCaptureDevicePositionUnspecified;
    }
}

NSString * TIOModelOptionsOutputFormatFromString(NSString * _Nullable descriptor) {
    if ( descriptor == nil ) {
        return TIOModelOptionOutputFormatNone;
    } else {
        return descriptor;
    }
}

@implementation TIOModelOptions

- (instancetype)initWithDevicePosition:(AVCaptureDevicePosition)devicePosition outputFormat:(NSString*)outputFormat {
    if (self = [super init]) {
        _devicePosition = devicePosition;
        _outputFormat = outputFormat;
    }
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary*)dictionary {
    AVCaptureDevicePosition devicePosition;
    NSString *outputFormat;
    
    if ( dictionary == nil ) {
        devicePosition = AVCaptureDevicePositionUnspecified;
        outputFormat = TIOModelOptionOutputFormatNone;
    } else {
        devicePosition = TIOModelOptionsAVCaptureDevicePositionFromString(dictionary[@"device_position"]);
        outputFormat = TIOModelOptionsOutputFormatFromString(dictionary[@"output_format"]);
    }
    
    return [self initWithDevicePosition:devicePosition outputFormat:outputFormat];
}

- (instancetype)init {
    return [self initWithDictionary:nil];
}

@end
