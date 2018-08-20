//
//  TIOVisionModelHelpers.mm
//  TensorIO
//
//  Created by Philip Dow on 7/12/18.
//  Copyright © 2018 doc.ai. All rights reserved.
//

#import "TIOVisionModelHelpers.h"

// MARK: - Image Volume

const TIOImageVolume kTIOImageVolumeInvalid = {
    .width      = 0,
    .height     = 0,
    .channels   = 0
};

BOOL TIOImageVolumesEqual(const TIOImageVolume& a, const TIOImageVolume& b) {
    return a.width == b.width
        && a.height == b.height
        && a.channels == b.channels;
}
