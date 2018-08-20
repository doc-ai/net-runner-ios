//
//  VisionModelHelpers.mm
//  Net Runner
//
//  Created by Philip Dow on 7/12/18.
//  Copyright © 2018 doc.ai. All rights reserved.
//

#import "VisionModelHelpers.h"

// MARK: - Image Volume

const ImageVolume kImageVolumeInvalid = {
    .width      = 0,
    .height     = 0,
    .channels   = 0
};

BOOL ImageVolumesEqual(const ImageVolume& a, const ImageVolume& b) {
    return a.width == b.width
        && a.height == b.height
        && a.channels == b.channels;
}
