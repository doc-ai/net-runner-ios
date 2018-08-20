//
//  TIOModelOptions.m
//  TensorIO
//
//  Created by Philip Dow on 7/28/18.
//  Copyright © 2018 doc.ai. All rights reserved.
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
