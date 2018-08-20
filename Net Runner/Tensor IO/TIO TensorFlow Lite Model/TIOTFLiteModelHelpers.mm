//
//  TIOTFLiteModelHelpers.cpp
//  Net Runner Parser
//
//  Created by Philip Dow on 8/7/18.
//  Copyright © 2018 doc.ai. All rights reserved.
//

#import "TIOTFLiteModelHelpers.h"

#import "NSArray+Extensions.h"
#import "ModelBundle.h"
#import "TIODataInterface.h"
#import "TIOPixelBufferDescription.h"
#import "TIOVectorDescription.h"

// MARK: - Parsing

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
