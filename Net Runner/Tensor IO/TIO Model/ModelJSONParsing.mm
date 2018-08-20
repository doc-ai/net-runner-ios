//
//  ModelJSONParsing.m
//  Net Runner
//
//  Created by Philip Dow on 8/20/18.
//  Copyright © 2018 doc.ai. All rights reserved.
//

#import "ModelJSONParsing.h"

#import "NSArray+Extensions.h"
#import "ModelBundle.h"
#import "TIODataInterface.h"
#import "TIOPixelBufferDescription.h"
#import "TIOVectorDescription.h"

TIODataInterface * _Nullable TIOTFLiteModelParseTIOVectorDescription(NSDictionary *dict, BOOL isInput, BOOL quantized, ModelBundle *bundle) {
    NSArray<NSNumber*> *shape = dict[@"shape"];
    NSString *name = dict[@"name"];
    BOOL isOutput = !isInput;
    
    // Total Volume
    
    NSUInteger length = shape.product;

    // Labels

    NSMutableArray<NSString*> *labels = nil;

    if ( NSString *labelsFilename = dict[@"labels"] ) {
        labels = NSMutableArray.array;
        std::vector<std::string> labelVector;
        
        NSString *labelsPath = [bundle pathToAsset:labelsFilename];
        LoadLabels(labelsPath, &labelVector);
        
        for ( NSUInteger i = 0; i < labelVector.size(); i++ ) {
            NSString *label = [NSString stringWithUTF8String:labelVector[i].c_str()];
            [labels addObject:label];
        }
    }
    
    // Quantization
    // TODO: support quantization for inputs
    
    DataQuantizer quantizer;
    
    if ( isInput ) {
        quantizer = TIODataQuantizerNone();
    } else {
        quantizer = TIODataQuantizerNone();
    }
    
    // Dequantization
    
    DataDequantizer dequantizer;
    
    if ( isOutput ) {
        dequantizer = TIODataDequantizerForDict(dict);
    } else {
        dequantizer = TIODataDequantizerNone();
    }
    
    // Interface

    TIODataInterface *interface = [[TIODataInterface alloc] initWithName:name isInput:isInput vectorDescription:
        [[TIOVectorDescription alloc]
            initWithLength:length
            labels:labels
            quantized:quantized
            quantizer:quantizer
            dequantizer:dequantizer]];
    
    return interface;
}

TIODataInterface * _Nullable TIOTFLiteModelParseTIOPixelBufferDescription(NSDictionary *dict, BOOL isInput, BOOL quantized) {
    NSArray<NSNumber*> *shape = dict[@"shape"];
    NSString *name = dict[@"name"];
    BOOL isOutput = !isInput;
    
    // Image Volume
    
    ImageVolume imageVolume = ImageVolumeForShape(shape);
    
    if ( ImageVolumesEqual(imageVolume, kImageVolumeInvalid ) ) {
        NSLog(@"Expected dict.shape array field with three elements in model.json, found %@", dict[@"shape"]);
        return nil;
    }
    
    // Pixel Format

    OSType pixelFormat = PixelFormatForString(dict[@"format"]);

    if ( pixelFormat == PixelFormatTypeInvalid ) {
        NSLog(@"Expected dict.format string to be RGB or BGR in model.json, found %@", dict[@"format"]);
        return nil;
    }
    
    // Normalization
    
    PixelNormalization normalization;
    PixelNormalizer normalizer;
    
    if ( isInput ) {
        normalization = PixelNormalizationForDictionary(dict);
        normalizer = PixelNormalizerForDictionary(dict);

        if ( PixelNormalizationsEqual(normalization, kPixelNormalizationInvalid) ) {
            NSLog(@"Expected dict.normalizer string to be '[0,1]' or '[-1,1]', or scale and bias values, found normalization: %@, scale: %@, bias: %@", dict[@"normalize"], dict[@"scale"], dict[@"bias"]);
            return nil;
        }
    } else {
        normalization = kPixelNormalizationNone;
        normalizer = PixelNormalizerNone();
    }
    
    // Denormalization
    
    PixelDenormalization denormalization;
    PixelDenormalizer denormalizer;

    if ( isOutput ) {
        denormalization = PixelDenormalizationForDictionary(dict);
        denormalizer = PixelDenormalizerForDictionary(dict);
        
        if ( PixelDenormalizationsEqual(denormalization, kPixelDenormalizationInvalid) ) {
            NSLog(@"Expected dict.denormalizer string to be '[0,1]' or '[-1,1]', or scale and bias values, found denormalization: %@, scale: %@, bias: %@", dict[@"normalize"], dict[@"scale"], dict[@"bias"]);
            return nil;
        }
    } else {
        denormalization = kPixelDenormalizationNone;
        denormalizer = PixelDenormalizerNone();
    }

    // Description

    TIODataInterface *interface = [[TIODataInterface alloc] initWithName:name isInput:isInput pixelBufferDescription:
        [[TIOPixelBufferDescription alloc]
            initWithPixelFormat:pixelFormat
            shape:imageVolume
            normalization:normalization
            normalizer:normalizer
            denormalization:denormalization
            denormalizer:denormalizer
            quantized:quantized]];
    
    return interface;
}

_Nullable DataQuantizer TIODataQuantizerForDict(NSDictionary *dict) {
    // TODO: support data quantization
    return nil;
}

_Nullable DataDequantizer TIODataDequantizerForDict(NSDictionary *dict) {
    NSString *standard = dict[@"dequantize"][@"standard"];
    // TODO: support scale and bias
    // NSNumber *scale = dict[@"dequantize"][@"scale"];
    // NSNumber *bias = dict[@"dequantize"][@"bias"];
    
    if ( [standard isEqualToString:@"[0,1]"] ) {
        return DataDequantizerZeroToOne();
    }
    
    return nil;
}

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
    NSString *normalizerString = dict[@"normalize"][@"standard"];
    NSNumber *scaleNumber = dict[@"normalize"][@"scale"];
    NSDictionary *biases = dict[@"normalize"][@"bias"];
    
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
    NSString *normalizerString = dict[@"normalize"][@"standard"];
    NSNumber *scaleNumber = dict[@"normalize"][@"scale"];
    NSDictionary *biases = dict[@"normalize"][@"bias"];
    
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

// The presence of a denormalizer overrides scale and bias preferences
// Would like to return a tuple here

PixelDenormalization PixelDenormalizationForDictionary(NSDictionary *dict) {
    NSString *normalizerString = dict[@"denormalize"][@"standard"];
    NSNumber *scaleNumber = dict[@"denormalize"][@"scale"];
    NSDictionary *biases = dict[@"denormalize"][@"bias"];
    
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
    NSString *normalizerString = dict[@"denormalize"][@"standard"];
    NSNumber *scaleNumber = dict[@"denormalize"][@"scale"];
    NSDictionary *biases = dict[@"denormalize"][@"bias"];
    
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

// MARK: - Assets

void LoadLabels(NSString* labels_path, std::vector<std::string>* label_strings) {
    std::ifstream t;
    t.open([labels_path UTF8String]);
    std::string line;
    while (t) {
        std::getline(t, line);
        label_strings->push_back(line);
    }
    t.close();
}

