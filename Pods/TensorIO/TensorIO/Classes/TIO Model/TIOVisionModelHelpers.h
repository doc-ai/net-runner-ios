//
//  TIOVisionModelHelpers.h
//  TensorIO
//
//  Created by Philip Dow on 7/12/18.
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

#ifndef TIOVisionModelHelpers_h
#define TIOVisionModelHelpers_h

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

#import "TIOModel.h"
#import "TIOPixelNormalization.h"

NS_ASSUME_NONNULL_BEGIN

// MARK: - Image Volume

/**
 * Describes the input volume of a tensor that takes an image
 */

typedef struct TIOImageVolume {
    int height;
    int width;
    int channels;
} TIOImageVolume;

/**
 * No image volume, used to represent an error reading the image volume from the model.json file.
 */

extern const TIOImageVolume kTIOImageVolumeInvalid;

/**
 * Checks if two image volumes are equal.
 *
 * @param a The first image volume to compare.
 * @param b The second image volume to compare.
 *
 * @return BOOL `YES` if two image volumes are equal, `NO` otherwise.
 */

BOOL TIOImageVolumesEqual(TIOImageVolume a, TIOImageVolume b);

NS_ASSUME_NONNULL_END

#endif /* TIOVisionModelHelpers_h */
