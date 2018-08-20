//
//  TIOModelJSONParsing.m
//  Net Runner
//
//  Created by Philip Dow on 8/20/18.
//  Copyright © 2018 doc.ai. All rights reserved.
//

#import "TIOModelJSONParsing.h"

#import "NSArray+Extensions.h"
#import "TIOModelBundle.h"
#import "TIODataInterface.h"
#import "TIOPixelBufferDescription.h"
#import "TIOVectorDescription.h"

TIODataInterface * _Nullable TIOTFLiteModelParseTIOVectorDescription(NSDictionary *dict, BOOL isInput, BOOL quantized, TIOModelBundle *bundle) {
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
    
    TIODataQuantizer quantizer;
    
    if ( isInput ) {
        quantizer = TIODataQuantizerNone();
    } else {
        quantizer = TIODataQuantizerNone();
    }
    
    // Dequantization
    
    TIODataDequantizer dequantizer;
    
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
    
    TIOImageVolume imageVolume = TIOImageVolumeForShape(shape);
    
    if ( TIOImageVolumesEqual(imageVolume, kTIOImageVolumeInvalid ) ) {
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
    
    TIOPixelNormalization normalization;
    TIOPixelNormalizer normalizer;
    
    if ( isInput ) {
        normalization = TIOPixelNormalizationForDictionary(dict);
        normalizer = TIOPixelNormalizerForDictionary(dict);

        if ( TIOPixelNormalizationsEqual(normalization, kTIOPixelNormalizationInvalid) ) {
            NSLog(@"Expected dict.normalizer string to be '[0,1]' or '[-1,1]', or scale and bias values, found normalization: %@, scale: %@, bias: %@", dict[@"normalize"], dict[@"scale"], dict[@"bias"]);
            return nil;
        }
    } else {
        normalization = kTIOPixelNormalizationNone;
        normalizer = TIOPixelNormalizerNone();
    }
    
    // Denormalization
    
    TIOPixelDenormalization denormalization;
    TIOPixelDenormalizer denormalizer;

    if ( isOutput ) {
        denormalization = TIOPixelDenormalizationForDictionary(dict);
        denormalizer = TIOPixelDenormalizerForDictionary(dict);
        
        if ( TIOPixelDenormalizationsEqual(denormalization, kTIOPixelDenormalizationInvalid) ) {
            NSLog(@"Expected dict.denormalizer string to be '[0,1]' or '[-1,1]', or scale and bias values, found denormalization: %@, scale: %@, bias: %@", dict[@"normalize"], dict[@"scale"], dict[@"bias"]);
            return nil;
        }
    } else {
        denormalization = kTIOPixelDenormalizationNone;
        denormalizer = TIOPixelDenormalizerNone();
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

_Nullable TIODataQuantizer TIODataQuantizerForDict(NSDictionary *dict) {
    // TODO: support data quantization
    return nil;
}

_Nullable TIODataDequantizer TIODataDequantizerForDict(NSDictionary *dict) {
    NSString *standard = dict[@"dequantize"][@"standard"];
    // TODO: support scale and bias
    // NSNumber *scale = dict[@"dequantize"][@"scale"];
    // NSNumber *bias = dict[@"dequantize"][@"bias"];
    
    if ( [standard isEqualToString:@"[0,1]"] ) {
        return TIODataDequantizerZeroToOne();
    }
    
    return nil;
}

TIOImageVolume TIOImageVolumeForShape(NSArray<NSNumber*> *shape) {
    
    if ( shape == nil ) {
        NSLog(@"Expected input.shape array field in model.json, none found");
        return kTIOImageVolumeInvalid;
    }

    if ( shape.count != 3 ) {
        NSLog(@"Expected shape with three elements, actual count is %lu", (unsigned long)shape.count);
        return kTIOImageVolumeInvalid;
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

TIOPixelNormalization TIOPixelNormalizationForDictionary(NSDictionary *dict) {
    NSString *normalizerString = dict[@"normalize"][@"standard"];
    NSNumber *scaleNumber = dict[@"normalize"][@"scale"];
    NSDictionary *biases = dict[@"normalize"][@"bias"];
    
    if ( normalizerString != nil ) {
        if ( [normalizerString isEqualToString:@"[0,1]"] ) {
            return kTIOPixelNormalizationZeroToOne;
        }
        else if ( [normalizerString isEqualToString:@"[-1,1]"] ) {
            return kTIOPixelNormalizationNegativeOneToOne;
        }
        else {
            return kTIOPixelNormalizationInvalid;
        }
    }
    else if ( scaleNumber == nil && biases == nil ) {
        return kTIOPixelNormalizationNone;
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

TIOPixelNormalizer _Nullable TIOPixelNormalizerForDictionary(NSDictionary *dict) {
    NSString *normalizerString = dict[@"normalize"][@"standard"];
    NSNumber *scaleNumber = dict[@"normalize"][@"scale"];
    NSDictionary *biases = dict[@"normalize"][@"bias"];
    
    if ( normalizerString != nil ) {
        if ( [normalizerString isEqualToString:@"[0,1]"] ) {
            return TIOPixelNormalizerZeroToOne();
        }
        else if ( [normalizerString isEqualToString:@"[-1,1]"] ) {
            return TIOPixelNormalizerNegativeOneToOne();
        }
        else {
            NSLog(@"Expected input.normalizer string to be '[0,1]' or '[-1,1]', actual value is %@", normalizerString);
            return nil;
        }
    }
    else if ( scaleNumber == nil && biases == nil ) {
        return TIOPixelNormalizerNone();
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
        
        TIOPixelNormalization normalization = {
            .scale = scale,
            .redBias = redBias,
            .greenBias = greenBias,
            .blueBias = blueBias
        };
        
        if ( (redBias == greenBias) && (redBias == blueBias) ) {
            return TIOPixelNormalizerSingleBias(normalization);
        } else {
            return TIOPixelNormalizerPerChannelBias(normalization);
        }
    }
}

// The presence of a denormalizer overrides scale and bias preferences
// Would like to return a tuple here

TIOPixelDenormalization TIOPixelDenormalizationForDictionary(NSDictionary *dict) {
    NSString *normalizerString = dict[@"denormalize"][@"standard"];
    NSNumber *scaleNumber = dict[@"denormalize"][@"scale"];
    NSDictionary *biases = dict[@"denormalize"][@"bias"];
    
    if ( normalizerString != nil ) {
        if ( [normalizerString isEqualToString:@"[0,1]"] ) {
            return kTIOPixelDenormalizationZeroToOne;
        }
        else if ( [normalizerString isEqualToString:@"[-1,1]"] ) {
            return kTIOPixelDenormalizationNegativeOneToOne;
        }
        else {
            return kTIOPixelDenormalizationInvalid;
        }
    }
    else if ( scaleNumber == nil && biases == nil ) {
        return kTIOPixelDenormalizationNone;
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

TIOPixelDenormalizer _Nullable TIOPixelDenormalizerForDictionary(NSDictionary *dict) {
    NSString *normalizerString = dict[@"denormalize"][@"standard"];
    NSNumber *scaleNumber = dict[@"denormalize"][@"scale"];
    NSDictionary *biases = dict[@"denormalize"][@"bias"];
    
    if ( normalizerString != nil ) {
        if ( [normalizerString isEqualToString:@"[0,1]"] ) {
            return TIOPixelDenormalizerZeroToOne();
        }
        else if ( [normalizerString isEqualToString:@"[-1,1]"] ) {
            return TIOPixelDenormalizerNegativeOneToOne();
        }
        else {
            NSLog(@"Expected input.denormalizer string to be '[0,1]' or '[-1,1]', actual value is %@", normalizerString);
            return nil;
        }
    }
    else if ( scaleNumber == nil && biases == nil ) {
        return TIOPixelDenormalizerNone();
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
        
        TIOPixelNormalization normalization = {
            .scale = scale,
            .redBias = redBias,
            .greenBias = greenBias,
            .blueBias = blueBias
        };
        
        if ( (redBias == greenBias) && (redBias == blueBias) ) {
            return TIOPixelDenormalizerSingleBias(normalization);
        } else {
            return TIOPixelDenormalizerPerChannelBias(normalization);
        }
    }
}

// MARK: - Pixel Format

const OSType PixelFormatTypeInvalid = 'NULL';

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

