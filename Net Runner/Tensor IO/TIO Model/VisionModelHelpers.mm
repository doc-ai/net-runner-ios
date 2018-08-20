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

// MARK: - Pixel Format

const OSType PixelFormatTypeInvalid = 'NULL';

// MARK: - Initialization Helpers

ImageVolume ImageVolumeForShape(NSArray<NSNumber*> *shape) {
    
    if ( shape == nil ) {
        NSLog(@"Expected input.shape array field in model.json, none found");
        return kImageVolumeInvalid;
    }

    if ( shape.count != 3 ) {
        NSLog(@"Expected shape with three elements, actual count is %lu", (unsigned long)shape.count);
        return kImageVolumeInvalid;
    }

    return {
        .width = (int)shape[0].integerValue,
        .height = (int)shape[1].integerValue,
        .channels = (int)shape[2].integerValue
    };
}

OSType PixelFormatForString(NSString* string) {
    
    if ( string == nil ) {
        NSLog(@"Expected input.format string in model.json, none found");
        return PixelFormatTypeInvalid;
    }
    else if ( [string isEqualToString:@"RGB"] ) {
        return kCVPixelFormatType_32ARGB;
    }
    else if ([string isEqualToString:@"BGR"] ) {
        return kCVPixelFormatType_32BGRA;
    }
    else {
        NSLog(@"expected input.format string to be 'RGB' or 'BGR', actual value is %@", string);
        return PixelFormatTypeInvalid;
    }
}

// The presence of a normalizer overrides scale and bias preferences
// Would like to return a tuple here

PixelNormalization PixelNormalizationForDictionary(NSDictionary *dict) {
    NSString *normalizerString = dict[@"normalize"];
    NSNumber *scaleNumber = dict[@"scale"];
    NSDictionary *biases = dict[@"bias"];
    
    if ( normalizerString != nil ) {
        if ( [normalizerString isEqualToString:@"[0,1]"] ) {
            return kPixelNormalizationZeroToOne;
        }
        else if ( [normalizerString isEqualToString:@"[-1,1]"] ) {
            return kPixelNormalizationNegativeOneToOne;
        }
        else {
            return kPixelNormalizationInvalid;
        }
    }
    else if ( scaleNumber == nil && biases == nil ) {
        return kPixelNormalizationNone;
    }
    else {
        float_t scale = scaleNumber != nil
            ? [scaleNumber floatValue]
            : 1.0;
        float_t redBias = biases != nil
            ? [biases[@"r"] floatValue]
            : 0.0;
        float_t greenBias = biases != nil
            ? [biases[@"g"] floatValue]
            : 0.0;
        float_t blueBias = biases != nil
            ? [biases[@"b"] floatValue]
            : 0.0;
        
        return {
            .scale = scale,
            .redBias = redBias,
            .greenBias = greenBias,
            .blueBias = blueBias
        };
    }
}

PixelNormalizer _Nullable PixelNormalizerForDictionary(NSDictionary *dict) {
    NSString *normalizerString = dict[@"normalize"];
    NSNumber *scaleNumber = dict[@"scale"];
    NSDictionary *biases = dict[@"bias"];
    
    if ( normalizerString != nil ) {
        if ( [normalizerString isEqualToString:@"[0,1]"] ) {
            return PixelNormalizerZeroToOne();
        }
        else if ( [normalizerString isEqualToString:@"[-1,1]"] ) {
            return PixelNormalizerNegativeOneToOne();
        }
        else {
            NSLog(@"Expected input.normalizer string to be '[0,1]' or '[-1,1]', actual value is %@", normalizerString);
            return nil;
        }
    }
    else if ( scaleNumber == nil && biases == nil ) {
        return PixelNormalizerNone();
    }
    else {
        float_t scale = scaleNumber != nil
            ? [scaleNumber floatValue]
            : 1.0;
        float_t redBias = biases != nil
            ? [biases[@"r"] floatValue]
            : 0.0;
        float_t greenBias = biases != nil
            ? [biases[@"g"] floatValue]
            : 0.0;
        float_t blueBias = biases != nil
            ? [biases[@"b"] floatValue]
            : 0.0;
        
        PixelNormalization normalization = {
            .scale = scale,
            .redBias = redBias,
            .greenBias = greenBias,
            .blueBias = blueBias
        };
        
        if ( (redBias == greenBias) && (redBias == blueBias) ) {
            return PixelNormalizerSingleBias(normalization);
        } else {
            return PixelNormalizerPerChannelBias(normalization);
        }
    }
}

// The presence of a deormalizer overrides scale and bias preferences
// Would like to return a tuple here

PixelDenormalization PixelDenormalizationForDictionary(NSDictionary *dict) {
    NSString *normalizerString = dict[@"denormalize"];
    NSNumber *scaleNumber = dict[@"scale"];
    NSDictionary *biases = dict[@"bias"];
    
    if ( normalizerString != nil ) {
        if ( [normalizerString isEqualToString:@"[0,1]"] ) {
            return kPixelDenormalizationZeroToOne;
        }
        else if ( [normalizerString isEqualToString:@"[-1,1]"] ) {
            return kPixelDenormalizationNegativeOneToOne;
        }
        else {
            return kPixelDenormalizationInvalid;
        }
    }
    else if ( scaleNumber == nil && biases == nil ) {
        return kPixelDenormalizationNone;
    }
    else {
        float_t scale = scaleNumber != nil
            ? [scaleNumber floatValue]
            : 1.0;
        float_t redBias = biases != nil
            ? [biases[@"r"] floatValue]
            : 0.0;
        float_t greenBias = biases != nil
            ? [biases[@"g"] floatValue]
            : 0.0;
        float_t blueBias = biases != nil
            ? [biases[@"b"] floatValue]
            : 0.0;
        
        return {
            .scale = scale,
            .redBias = redBias,
            .greenBias = greenBias,
            .blueBias = blueBias
        };
    }
}

PixelDenormalizer _Nullable PixelDenormalizerForDictionary(NSDictionary *dict) {
    NSString *normalizerString = dict[@"denormalize"];
    NSNumber *scaleNumber = dict[@"scale"];
    NSDictionary *biases = dict[@"bias"];
    
    if ( normalizerString != nil ) {
        if ( [normalizerString isEqualToString:@"[0,1]"] ) {
            return PixelDenormalizerZeroToOne();
        }
        else if ( [normalizerString isEqualToString:@"[-1,1]"] ) {
            return PixelDenormalizerNegativeOneToOne();
        }
        else {
            NSLog(@"Expected input.denormalizer string to be '[0,1]' or '[-1,1]', actual value is %@", normalizerString);
            return nil;
        }
    }
    else if ( scaleNumber == nil && biases == nil ) {
        return PixelDenormalizerNone();
    }
    else {
        float_t scale = scaleNumber != nil
            ? [scaleNumber floatValue]
            : 1.0;
        float_t redBias = biases != nil
            ? [biases[@"r"] floatValue]
            : 0.0;
        float_t greenBias = biases != nil
            ? [biases[@"g"] floatValue]
            : 0.0;
        float_t blueBias = biases != nil
            ? [biases[@"b"] floatValue]
            : 0.0;
        
        PixelNormalization normalization = {
            .scale = scale,
            .redBias = redBias,
            .greenBias = greenBias,
            .blueBias = blueBias
        };
        
        if ( (redBias == greenBias) && (redBias == blueBias) ) {
            return PixelDenormalizerSingleBias(normalization);
        } else {
            return PixelDenormalizerPerChannelBias(normalization);
        }
    }
}
