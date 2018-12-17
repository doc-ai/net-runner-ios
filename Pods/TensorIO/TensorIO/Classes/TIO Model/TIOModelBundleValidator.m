//
//  TIOModelBundleValidator.m
//  TensorIO
//
//  Created by Philip Dow on 9/12/18.
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

#import "TIOModelBundleValidator.h"

#import "TIOModelBundle.h"

// MARK: - Errors

static NSString * const TIOModelBundleValidatorErrorDomain = @"ai.doc.tensorio.model-bundle-validator";

static const NSUInteger TIOMalformedJSONErrorCode = 300;
static const NSUInteger TIOInvalidFilepathErrorCode = 301;
static const NSUInteger TIOInvalidExtensionErrorCode = 302;
static const NSUInteger TIONoModelJSONFileErrorCode = 303;
static const NSUInteger TIOMissingPropertyErrorCode = 304;
static const NSUInteger TIOZeroInputsErrorCode = 305;
static const NSUInteger TIOMissingInputPropertyErrorCode = 306;

static const NSUInteger TIOInputShapeMustBeArrayErrorCode = 307;
static const NSUInteger TIOInputShapeMustHaveEntriesErrorCode = 308;
static const NSUInteger TIOInputShapeMustHaveNumericEntriesErrorCode = 309;
static const NSUInteger TIOInputTypeMustConformErrorCode = 310;
static const NSUInteger TIOArrayInputHasUnusedKeysErrorCode = 311;
static const NSUInteger TIOArrayInputQuantizeIsEmptyErrorCode = 312;
static const NSUInteger TIOArrayInputQuantizeHasUnusedKeysErrorCode = 313;
static const NSUInteger TIOArrayInputQuantizeMustHaveCorectKeysErrorCode = 314;
static const NSUInteger TIOArrayInputQuantizeMustHaveStandardOrScaleAndBiasKeysErrorCode = 315;
static const NSUInteger TIOArrayInputStandardQuantizeMustConformErrorCode = 316;
static const NSUInteger TIOArrayInputQuantizeScaleAndBiasMustBeNumericErrorCode = 317;
static const NSUInteger TIOArrayInputQuantizeMustHaveBothScaleAndBiasKeysErrorCode = 318;
static const NSUInteger TIOImageInputHasUnusedKeysErrorCode = 319;
static const NSUInteger TIOImageInputNormalizeIsEmptyErrorCode = 320;
static const NSUInteger TIOImageInputNormalizeHasUnusedKeysErrorCode = 321;
static const NSUInteger TIOImageInputNormalizeMustHaveCorectKeysErrorCode = 322;
static const NSUInteger TIOImageInputNormalizeMustHaveStandardOrScaleAndBiasKeysErrorCode = 323;
static const NSUInteger TIOImageInputStandardNormalizeMustConformErrorCode = 324;
static const NSUInteger TIOImageInputNormalizeMustHaveBothScaleAndBiasKeysErrorCode = 325;
static const NSUInteger TIOImageInputNormalizeScaleMustBeNumericErrorCode = 326;
static const NSUInteger TIOImageInputNormalizeBiasMustBeDictionaryErrorCode = 327;
static const NSUInteger TIOImageInputNormalizeBiasHasUnusedKeysErrorCode = 328;
static const NSUInteger TIOImageInputNormalizeBiasIsEmptyErrorCode = 329;
static const NSUInteger TIOImageInputNormalizeBiasMustHaveCorectKeysErrorCode = 330;
static const NSUInteger TIOImageInputNormalizeBiasMustBeNumericValuesErrorCode = 331;
static const NSUInteger TIOImageInputFormatNotValidErrorCode = 332;

static const NSUInteger TIOZeroOutputsErrorCode = 400;
static const NSUInteger TIOMissingOutputPropertyErrorCode = 401;
static const NSUInteger TIOOutputShapeMustBeArrayErrorCode = 402;
static const NSUInteger TIOOutputShapeMustHaveEntriesErrorCode = 403;
static const NSUInteger TIOOutputShapeMustHaveNumericEntriesErrorCode = 404;
static const NSUInteger TIOOutputTypeMustConformErrorCode = 405;
static const NSUInteger TIOArrayOutputHasUnusedKeysErrorCode = 406;
static const NSUInteger TIOArrayOutputDequantizeIsEmptyErrorCode = 407;
static const NSUInteger TIOArrayOutputDequantizeHasUnusedKeysErrorCode = 408;
static const NSUInteger TIOArrayOutputDequantizeMustHaveCorectKeysErrorCode = 409;
static const NSUInteger TIOArrayOutputDequantizeMustHaveStandardOrScaleAndBiasKeysErrorCode = 410;
static const NSUInteger TIOArrayOutputStandardDequantizeMustConformErrorCode = 411;
static const NSUInteger TIOArrayOutputDequantizeScaleAndBiasMustBeNumericErrorCode = 412;
static const NSUInteger TIOArrayOutputDequantizeMustHaveBothScaleAndBiasKeysErrorCode = 413;
static const NSUInteger TIOImageOutputHasUnusedKeysErrorCode = 414;
static const NSUInteger TIOImageOutputDenormalizeIsEmptyErrorCode = 415;
static const NSUInteger TIOImageOutputDenormalizeHasUnusedKeysErrorCode = 416;
static const NSUInteger TIOImageOutputDenormalizeMustHaveCorectKeysErrorCode = 417;
static const NSUInteger TIOImageOutputDenormalizeMustHaveStandardOrScaleAndBiasKeysErrorCode = 418;
static const NSUInteger TIOImageOutputStandardDenormalizeMustConformErrorCode = 419;
static const NSUInteger TIOImageOutputDenormalizeMustHaveBothScaleAndBiasKeysErrorCode = 420;
static const NSUInteger TIOImageOutputDenormalizeScaleMustBeNumericErrorCode = 421;
static const NSUInteger TIOImageOutputDenormalizeBiasMustBeDictionaryErrorCode = 422;
static const NSUInteger TIOImageOutputDenormalizeBiasHasUnusedKeysErrorCode = 423;
static const NSUInteger TIOImageOutputDenormalizeBiasIsEmptyErrorCode = 424;
static const NSUInteger TIOImageOutputDenormalizeBiasMustHaveCorectKeysErrorCode = 425;
static const NSUInteger TIOImageOutputDenormalizeBiasMustBeNumericValuesErrorCode = 426;
static const NSUInteger TIOImageOutputFormatNotValidErrorCode = 427;

static const NSUInteger TIOModelHasUnusedKeysErrorCode = 500;
static const NSUInteger TIOModelMissingPropertyErrorCode = 501;
static const NSUInteger TIOModelFileDoesNotExistsErrorCode = 502;
static const NSUInteger TIOLabelsFileDoesNotExistErrorCode = 503;

static NSError * TIOMalformedJSONError(void);
static NSError * TIOInvalidFilepathError(NSString * path);
static NSError * TIOInvalidExtensionError(NSString * path);
static NSError * TIONoModelJSONFileError(void);
static NSError * TIOMissingPropertyError(NSString * property);
static NSError * TIOZeroInputsError(void);
static NSError * TIOMissingInputPropertyError(NSString * property);

static NSError * TIOInputShapeMustBeArrayError(void);
static NSError * TIOInputShapeMustHaveEntriesError(void);
static NSError * TIOInputShapeMustHaveNumericEntriesError(void);
static NSError * TIOInputTypeMustConformError(void);
static NSError * TIOArrayInputHasUnusedKeysError(void);
static NSError * TIOArrayInputQuantizeIsEmptyError(void);
static NSError * TIOArrayInputQuantizeHasUnusedKeysError(void);
static NSError * TIOArrayInputQuantizeMustHaveCorectKeysError(void);
static NSError * TIOArrayInputQuantizeMustHaveStandardOrScaleAndBiasKeysError(void);
static NSError * TIOArrayInputStandardQuantizeMustConformError(void);
static NSError * TIOArrayInputQuantizeScaleAndBiasMustBeNumericError(void);
static NSError * TIOArrayInputQuantizeMustHaveBothScaleAndBiasKeysError(void);
static NSError * TIOImageInputHasUnusedKeysError(void);
static NSError * TIOImageInputNormalizeIsEmptyError(void);
static NSError * TIOImageInputNormalizeHasUnusedKeysError(void);
static NSError * TIOImageInputNormalizeMustHaveCorectKeysError(void);
static NSError * TIOImageInputNormalizeMustHaveStandardOrScaleAndBiasKeysError(void);
static NSError * TIOImageInputStandardNormalizeMustConformError(void);
static NSError * TIOImageInputNormalizeMustHaveBothScaleAndBiasKeysError(void);
static NSError * TIOImageInputNormalizeScaleMustBeNumericError(void);
static NSError * TIOImageInputNormalizeBiasMustBeDictionaryError(void);
static NSError * TIOImageInputNormalizeBiasHasUnusedKeysError(void);
static NSError * TIOImageInputNormalizeBiasIsEmptyError(void);
static NSError * TIOImageInputNormalizeBiasMustHaveCorectKeysError(void);
static NSError * TIOImageInputNormalizeBiasMustBeNumericValuesError(void);
static NSError * TIOImageInputFormatNotValidError(void);

static NSError * TIOZeroOutputsError(void);
static NSError * TIOMissingOutputPropertyError(NSString * property);
static NSError * TIOOutputShapeMustBeArrayError(void);
static NSError * TIOOutputShapeMustHaveEntriesError(void);
static NSError * TIOOutputShapeMustHaveNumericEntriesError(void);
static NSError * TIOOutputTypeMustConformError(void);
static NSError * TIOArrayOutputHasUnusedKeysError(void);
static NSError * TIOArrayOutputDequantizeIsEmptyError(void);
static NSError * TIOArrayOutputDequantizeHasUnusedKeysError(void);
static NSError * TIOArrayOutputDequantizeMustHaveCorectKeysError(void);
static NSError * TIOArrayOutputDequantizeMustHaveStandardOrScaleAndBiasKeysError(void);
static NSError * TIOArrayOutputStandardDequantizeMustConformError(void);
static NSError * TIOArrayOutputDequantizeScaleAndBiasMustBeNumericError(void);
static NSError * TIOArrayOutputDequantizeMustHaveBothScaleAndBiasKeysError(void);
static NSError * TIOImageOutputHasUnusedKeysError(void);
static NSError * TIOImageOutputDenormalizeIsEmptyError(void);
static NSError * TIOImageOutputDenormalizeHasUnusedKeysError(void);
static NSError * TIOImageOutputDenormalizeMustHaveCorectKeysError(void);
static NSError * TIOImageOutputDenormalizeMustHaveStandardOrScaleAndBiasKeysError(void);
static NSError * TIOImageOutputStandardDenormalizeMustConformError(void);
static NSError * TIOImageOutputDenormalizeMustHaveBothScaleAndBiasKeysError(void);
static NSError * TIOImageOutputDenormalizeScaleMustBeNumericError(void);
static NSError * TIOImageOutputDenormalizeBiasMustBeDictionaryError(void);
static NSError * TIOImageOutputDenormalizeBiasHasUnusedKeysError(void);
static NSError * TIOImageOutputDenormalizeBiasIsEmptyError(void);
static NSError * TIOImageOutputDenormalizeBiasMustHaveCorectKeysError(void);
static NSError * TIOImageOutputDenormalizeBiasMustBeNumericValuesError(void);
static NSError * TIOImageOutputFormatNotValidError(void);

static NSError * TIOModelHasUnusedKeysError(void);
static NSError * TIOModelMissingPropertyError(NSString * property);
static NSError * TIOModelFileDoesNotExistsError(NSString *filename);
static NSError * TIOLabelsFileDoesNotExistError(NSString *filename);

// MARK: -

@implementation TIOModelBundleValidator

- (instancetype)initWithModelBundleAtPath:(NSString*)path {
    if (self = [super init]) {
        _path = path;
    }
    return self;
}

// MARK: - Validation

- (BOOL)validate:(NSError**)error {
    return [self validate:nil error:error];
}

- (BOOL)validate:(_Nullable TIOModelBundleValidationBlock)customValidator error:(NSError**)error {
    
    NSFileManager *fm = [NSFileManager defaultManager];
    BOOL isDirectory;
    
    // Validate path
    
    if ( ![fm fileExistsAtPath:self.path isDirectory:&isDirectory] || !isDirectory ) {
        *error = TIOInvalidFilepathError(self.path);
        return NO;
    }
    
    // Validate bundle structure
    
    if ( ![self.path.pathExtension isEqualToString:kTFModelBundleExtension] ) {
        *error = TIOInvalidExtensionError(self.path);
        return NO;
    }
    
    if ( ![fm fileExistsAtPath:[self JSONPath] isDirectory:&isDirectory] || isDirectory ) {
        *error = TIONoModelJSONFileError();
        return NO;
    }
    
    // Validate if JSON can be read
    
    NSDictionary *JSON = [self loadJSON];
    
    if ( JSON == nil ) {
        *error = TIOMalformedJSONError();
        return NO;
    }
    
    // Cache the JSON
    
    _JSON = JSON;
    
    // Validate basic bundle properties
    
    if ( ![self validateBundleProperties:JSON error:error] ) {
        return NO;
    }
    
    // Validate model
    
    if ( ![self validateModelProperties:JSON[@"model"] error:error] ) {
        return NO;
    }
    
    // Validate inputs
    
    if ( ![self validateInputs:JSON[@"inputs"] error:error] ) {
        return NO;
    }
    
    // Validate outputs
    
    if ( ![self validateOutputs:JSON[@"outputs"] error:error] ) {
        return NO;
    }
    
    // Validate assets
    
    if ( ![self validateAssets:JSON error:error] ) {
        return NO;
    }
    
    // Custom validator
    
    if ( customValidator != nil && ![self validateCustomValidator:JSON validator:customValidator error:error] ) {
        return NO;
    }
    
    return YES;
}

- (BOOL)validateBundleProperties:(NSDictionary*)JSON error:(NSError**)error {
    
    // Validate presence of basic bundle properties
    
    if ( JSON[@"name"] == nil || ![JSON[@"name"] isKindOfClass:[NSString class]] ) {
        *error = TIOMissingPropertyError(@"name");
        return NO;
    }
    
    if ( JSON[@"details"] == nil || ![JSON[@"details"] isKindOfClass:[NSString class]] ) {
        *error = TIOMissingPropertyError(@"details");
        return NO;
    }
    
    if ( JSON[@"id"] == nil || ![JSON[@"id"] isKindOfClass:[NSString class]] ) {
        *error = TIOMissingPropertyError(@"id");
        return NO;
    }
    
    if ( JSON[@"version"] == nil || ![JSON[@"version"] isKindOfClass:[NSString class]] ) {
        *error = TIOMissingPropertyError(@"version");
        return NO;
    }
    
    if ( JSON[@"author"] == nil || ![JSON[@"author"] isKindOfClass:[NSString class]] ) {
        *error = TIOMissingPropertyError(@"author");
        return NO;
    }
    
    if ( JSON[@"license"] == nil || ![JSON[@"license"] isKindOfClass:[NSString class]] ) {
        *error = TIOMissingPropertyError(@"license");
        return NO;
    }
    
    if ( JSON[@"model"] == nil || ![JSON[@"model"] isKindOfClass:[NSDictionary class]] ) {
        *error = TIOMissingPropertyError(@"model");
        return NO;
    }
    
    if ( JSON[@"inputs"] == nil || ![JSON[@"inputs"] isKindOfClass:[NSArray class]] ) {
        *error = TIOMissingPropertyError(@"inputs");
        return NO;
    }
    
    if ( JSON[@"outputs"] == nil || ![JSON[@"outputs"] isKindOfClass:[NSArray class]] ) {
        *error = TIOMissingPropertyError(@"outputs");
        return NO;
    }
    
    return YES;
}

- (BOOL)validateModelProperties:(NSDictionary*)JSON error:(NSError**)error {
    
    NSArray *validKeys = @[
        @"quantized",
        @"file",
        @"class",
        @"type"
    ];
    
    NSArray *allKeys = JSON.allKeys;
    NSMutableSet *actualKeys = [NSMutableSet setWithArray:allKeys];
    
    for ( NSString *key in validKeys ) {
        [actualKeys removeObject:key];
    }
    
    if ( actualKeys.count != 0 ) {
        // unused keys error
        *error = TIOModelHasUnusedKeysError();
        return NO;
    }
    
    if ( ![allKeys containsObject:@"file"] || ![JSON[@"file"] isKindOfClass:[NSString class]] || [JSON[@"file"] length] == 0 ) {
        *error = TIOModelMissingPropertyError(@"file");
        return NO;
    }
    
    if ( ![allKeys containsObject:@"quantized"] || ![JSON[@"quantized"] isKindOfClass:[NSNumber class]] ) {
        *error = TIOModelMissingPropertyError(@"quantized");
        return NO;
    }
    
    return YES;
}

- (BOOL)validateAssets:(NSDictionary*)JSON error:(NSError**)error {
    NSFileManager *fm = NSFileManager.defaultManager;
    
    // validate model file
    
    NSString *modelFilename = JSON[@"model"][@"file"];
    NSString *modelFilepath = [self.path stringByAppendingPathComponent:modelFilename];
    
    if ( ![fm fileExistsAtPath:modelFilepath] ) {
        *error = TIOModelFileDoesNotExistsError(modelFilename);
        return NO;
    }
    
    // validate any labels that appear in outputs
    
    for ( NSDictionary *output in JSON[@"outputs"] ) {
        NSString *labelsFilename = output[@"labels"];
        if ( labelsFilename == nil ) {
            break;
        }
        
        NSString *labelsFilepath = [[self.path stringByAppendingPathComponent:kTFModelAssetsDirectory] stringByAppendingPathComponent:labelsFilename];
        
        if ( ![fm fileExistsAtPath:labelsFilepath] ) {
            *error = TIOLabelsFileDoesNotExistError(labelsFilename);
            return NO;
        }
    }
    
    return YES;
}

// Ooof. Would love a little DSL that let's me specify all this

- (BOOL)validateInputs:(NSArray*)JSON error:(NSError**)error {
    
    if ( JSON.count == 0 ) {
        *error = TIOZeroInputsError();
        return NO;
    }
    
    for ( NSDictionary *input in JSON ) {
        
        // basic properties
        
        if ( input[@"name"] == nil ) {
            *error = TIOMissingInputPropertyError(@"name");
            return NO;
        }
        
        if ( input[@"shape"] == nil ) {
            *error = TIOMissingInputPropertyError(@"shape");
            return NO;
        }
        
        if ( input[@"type"] == nil ) {
            *error = TIOMissingInputPropertyError(@"type");
            return NO;
        }
        
        // shape validation
        
        if ( ![input[@"shape"] isKindOfClass:[NSArray class]] ) {
            *error = TIOInputShapeMustBeArrayError();
            return NO;
        }
        
        if ( ((NSArray*)input[@"shape"]).count == 0 ) {
            *error = TIOInputShapeMustHaveEntriesError();
            return NO;
        }
        
        for ( id el in (NSArray*)input[@"shape"] ) {
            if ( ![el isKindOfClass:[NSNumber class]] ) {
                *error = TIOInputShapeMustHaveNumericEntriesError();
                return NO;
            }
        }
        
        // type validation
        
        if ( ![input[@"type"] isKindOfClass:[NSString class]] || !([input[@"type"] isEqualToString:@"array"] || [input[@"type"] isEqualToString:@"image"]) ) {
            *error = TIOInputTypeMustConformError();
            return NO;
        }
        
        // type:array validation
        
        if ( [input[@"type"] isEqualToString:@"array"] ) {
            
            // keys validation
            
            NSMutableSet *keys = [NSMutableSet setWithArray:input.allKeys];
            [keys removeObject:@"name"];
            [keys removeObject:@"type"];
            [keys removeObject:@"shape"];
            [keys removeObject:@"quantize"];
            
            if ( keys.count != 0 ) {
                *error = TIOArrayInputHasUnusedKeysError();
                return NO;
            }
            
            // quantize validation
            
            if ( input[@"quantize"] != nil ) {
                
                // keys validation
                
                {
                    NSMutableSet *keys = [NSMutableSet setWithArray:[input[@"quantize"] allKeys]];
                    [keys removeObject:@"standard"];
                    [keys removeObject:@"scale"];
                    [keys removeObject:@"bias"];
                    
                    if ( keys.count != 0 ) {
                        *error = TIOArrayInputQuantizeHasUnusedKeysError();
                        return NO;
                    }
                }
                
                NSSet *keys = [NSSet setWithArray:[input[@"quantize"] allKeys]];
                
                if ( keys.count == 0 ) {
                    *error = TIOArrayInputQuantizeIsEmptyError();
                    return NO;
                }
                
                if ( ![keys containsObject:@"standard"] && ![keys containsObject:@"scale"] && ![keys containsObject:@"bias"] ) {
                    *error = TIOArrayInputQuantizeMustHaveCorectKeysError();
                    return NO;
                }
                
                // standard validation
                
                if ( [keys containsObject:@"standard"] && ([keys containsObject:@"scale"] || [keys containsObject:@"bias"]) ) {
                    *error = TIOArrayInputQuantizeMustHaveStandardOrScaleAndBiasKeysError();
                    return NO;
                }
                
                if ( [keys containsObject:@"standard"] ) {
                    NSArray *values = @[
                        @"[-1,1]",
                        @"[0,1]"
                    ];
                    
                    if ( ![input[@"quantize"][@"standard"] isKindOfClass:[NSString class]] || ![values containsObject:input[@"quantize"][@"standard"]] ) {
                        *error = TIOArrayInputStandardQuantizeMustConformError();
                        return NO;
                    }
                }
                
                // scale and bias validation
                
                if ( ([keys containsObject:@"scale"] && ![keys containsObject:@"bias"]) || ([keys containsObject:@"bias"] && ![keys containsObject:@"scale"]) ) {
                    *error = TIOArrayInputQuantizeMustHaveBothScaleAndBiasKeysError();
                    return NO;
                }
                
                if ( [keys containsObject:@"scale"] && ![input[@"quantize"][@"scale"] isKindOfClass:[NSNumber class]] ) {
                    *error = TIOArrayInputQuantizeScaleAndBiasMustBeNumericError();
                    return NO;
                }
                
                if ( [keys containsObject:@"bias"] && ![input[@"quantize"][@"bias"] isKindOfClass:[NSNumber class]] ) {
                    *error = TIOArrayInputQuantizeScaleAndBiasMustBeNumericError();
                    return NO;
                }
                
            } // end quantize validation
            
        } // end type:array validation
        
        // type:image validation
        
        if ( [input[@"type"] isEqualToString:@"image"] ) {
            
            // keys validation
            
            NSMutableSet *keys = [NSMutableSet setWithArray:input.allKeys];
            [keys removeObject:@"name"];
            [keys removeObject:@"type"];
            [keys removeObject:@"shape"];
            [keys removeObject:@"normalize"];
            [keys removeObject:@"format"];
            
            if ( keys.count != 0 ) {
                *error = TIOImageInputHasUnusedKeysError();
                return NO;
            }
            
            // format validation
            
            NSArray *formats = @[
                @"RGB",
                @"BGR"
            ];
            
            if ( input[@"format"] == nil  || ![input[@"format"] isKindOfClass:[NSString class]] || ![formats containsObject:input[@"format"]] ) {
                *error = TIOImageInputFormatNotValidError();
                return NO;
            }
            
            // normalize validation
            
            if ( input[@"normalize"] != nil ) {
                
                // keys validation
                
                {
                    NSMutableSet *keys = [NSMutableSet setWithArray:[input[@"normalize"] allKeys]];
                    [keys removeObject:@"standard"];
                    [keys removeObject:@"scale"];
                    [keys removeObject:@"bias"];
                    
                    if ( keys.count != 0 ) {
                        *error = TIOImageInputNormalizeHasUnusedKeysError();
                        return NO;
                    }
                }
                
                NSSet *keys = [NSSet setWithArray:[input[@"normalize"] allKeys]];
                
                if ( keys.count == 0 ) {
                    *error = TIOImageInputNormalizeIsEmptyError();
                    return NO;
                }
                
                if ( ![keys containsObject:@"standard"] && ![keys containsObject:@"scale"] && ![keys containsObject:@"bias"] ) {
                    *error = TIOImageInputNormalizeMustHaveCorectKeysError();
                    return NO;
                }
                
                // standard validation
                
                if ( [keys containsObject:@"standard"] && ([keys containsObject:@"scale"] || [keys containsObject:@"bias"]) ) {
                    *error = TIOImageInputNormalizeMustHaveStandardOrScaleAndBiasKeysError();
                    return NO;
                }
                
                if ( [keys containsObject:@"standard"] ) {
                    NSArray *values = @[
                        @"[-1,1]",
                        @"[0,1]"
                    ];
                    
                    if ( ![input[@"normalize"][@"standard"] isKindOfClass:[NSString class]] || ![values containsObject:input[@"normalize"][@"standard"]] ) {
                        *error = TIOImageInputStandardNormalizeMustConformError();
                        return NO;
                    }
                }
                
                // scale and bias validation
                
                if ( ([keys containsObject:@"scale"] && ![keys containsObject:@"bias"]) || ([keys containsObject:@"bias"] && ![keys containsObject:@"scale"]) ) {
                    *error = TIOImageInputNormalizeMustHaveBothScaleAndBiasKeysError();
                    return NO;
                }
                
                if ( [keys containsObject:@"scale"] && ![input[@"normalize"][@"scale"] isKindOfClass:[NSNumber class]] ) {
                    *error = TIOImageInputNormalizeScaleMustBeNumericError();
                    return NO;
                }
                
                if ( [keys containsObject:@"bias"] ) {
                    
                    if ( ![input[@"normalize"][@"bias"] isKindOfClass:[NSDictionary class]] ) {
                        *error = TIOImageInputNormalizeBiasMustBeDictionaryError();
                        return NO;
                    }
                    
                    {
                        NSMutableSet *biasKeys = [NSMutableSet setWithArray:[input[@"normalize"][@"bias"] allKeys]];
                        [biasKeys removeObject:@"r"];
                        [biasKeys removeObject:@"g"];
                        [biasKeys removeObject:@"b"];
                        
                        if ( biasKeys.count != 0 ) {
                            *error = TIOImageInputNormalizeBiasHasUnusedKeysError();
                            return NO;
                        }
                    }
                    
                    NSSet *biasKeys = [NSSet setWithArray:[input[@"normalize"][@"bias"] allKeys]];
                
                    if ( biasKeys.count == 0 ) {
                        *error = TIOImageInputNormalizeBiasIsEmptyError();
                        return NO;
                    }
                    
                    if ( ![biasKeys containsObject:@"r"] || ![biasKeys containsObject:@"g"] || ![biasKeys containsObject:@"g"] ) {
                        *error = TIOImageInputNormalizeBiasMustHaveCorectKeysError();
                        return NO;
                    }
                    
                    if (   ![input[@"normalize"][@"bias"][@"r"] isKindOfClass:[NSNumber class]]
                        || ![input[@"normalize"][@"bias"][@"g"] isKindOfClass:[NSNumber class]]
                        || ![input[@"normalize"][@"bias"][@"g"] isKindOfClass:[NSNumber class]] ) {
                        *error = TIOImageInputNormalizeBiasMustBeNumericValuesError();
                        return NO;
                    }
                    
                } // end bias validation
                
            } // end normalize validation
        
        } // end type:image validation
        
    } // end for loop
    
    return YES;
}

- (BOOL)validateOutputs:(NSArray*)JSON error:(NSError**)error {
    
    if ( JSON.count == 0 ) {
        *error = TIOZeroOutputsError();
        return NO;
    }
    
    for ( NSDictionary *output in JSON ) {
        
        // basic properties
        
        if ( output[@"name"] == nil ) {
            *error = TIOMissingOutputPropertyError(@"name");
            return NO;
        }
        
        if ( output[@"shape"] == nil ) {
            *error = TIOMissingOutputPropertyError(@"shape");
            return NO;
        }
        
        if ( output[@"type"] == nil ) {
            *error = TIOMissingOutputPropertyError(@"type");
            return NO;
        }
        
        // shape validation
        
        if ( ![output[@"shape"] isKindOfClass:[NSArray class]] ) {
            *error = TIOOutputShapeMustBeArrayError();
            return NO;
        }
        
        if ( ((NSArray*)output[@"shape"]).count == 0 ) {
            *error = TIOOutputShapeMustHaveEntriesError();
            return NO;
        }
        
        for ( id el in (NSArray*)output[@"shape"] ) {
            if ( ![el isKindOfClass:[NSNumber class]] ) {
                *error = TIOOutputShapeMustHaveNumericEntriesError();
                return NO;
            }
        }
        
        // type validation
        
        if ( ![output[@"type"] isKindOfClass:[NSString class]] || !([output[@"type"] isEqualToString:@"array"] || [output[@"type"] isEqualToString:@"image"]) ) {
            *error = TIOOutputTypeMustConformError();
            return NO;
        }
        
        if ( [output[@"type"] isEqualToString:@"array"] ) {
            // type:array validation
            
            // keys validation
            
            NSMutableSet *keys = [NSMutableSet setWithArray:output.allKeys];
            [keys removeObject:@"name"];
            [keys removeObject:@"type"];
            [keys removeObject:@"shape"];
            [keys removeObject:@"dequantize"];
            [keys removeObject:@"labels"];
            
            if ( keys.count != 0 ) {
                *error = TIOArrayOutputHasUnusedKeysError();
                return NO;
            }
            
            // dequantize validation
            
            if ( output[@"dequantize"] != nil ) {
                
                // keys validation
                
                {
                    NSMutableSet *keys = [NSMutableSet setWithArray:[output[@"dequantize"] allKeys]];
                    [keys removeObject:@"standard"];
                    [keys removeObject:@"scale"];
                    [keys removeObject:@"bias"];
                    
                    if ( keys.count != 0 ) {
                        *error = TIOArrayOutputDequantizeHasUnusedKeysError();
                        return NO;
                    }
                }
                
                NSSet *keys = [NSSet setWithArray:[output[@"dequantize"] allKeys]];
                
                if ( keys.count == 0 ) {
                    *error = TIOArrayOutputDequantizeIsEmptyError();
                    return NO;
                }
                
                if ( ![keys containsObject:@"standard"] && ![keys containsObject:@"scale"] && ![keys containsObject:@"bias"] ) {
                    *error = TIOArrayOutputDequantizeMustHaveCorectKeysError();
                    return NO;
                }
                
                // standard validation
                
                if ( [keys containsObject:@"standard"] && ([keys containsObject:@"scale"] || [keys containsObject:@"bias"]) ) {
                    *error = TIOArrayOutputDequantizeMustHaveStandardOrScaleAndBiasKeysError();
                    return NO;
                }
                
                if ( [keys containsObject:@"standard"] ) {
                    NSArray *values = @[
                        @"[-1,1]",
                        @"[0,1]"
                    ];
                    
                    if ( ![output[@"dequantize"][@"standard"] isKindOfClass:[NSString class]] || ![values containsObject:output[@"dequantize"][@"standard"]] ) {
                        *error = TIOArrayOutputStandardDequantizeMustConformError();
                        return NO;
                    }
                }
                
                // scale and bias validation
                
                if ( ([keys containsObject:@"scale"] && ![keys containsObject:@"bias"]) || ([keys containsObject:@"bias"] && ![keys containsObject:@"scale"]) ) {
                    *error = TIOArrayOutputDequantizeMustHaveBothScaleAndBiasKeysError();
                    return NO;
                }
                
                if ( [keys containsObject:@"scale"] && ![output[@"dequantize"][@"scale"] isKindOfClass:[NSNumber class]] ) {
                    *error = TIOArrayOutputDequantizeScaleAndBiasMustBeNumericError();
                    return NO;
                }
                
                if ( [keys containsObject:@"bias"] && ![output[@"dequantize"][@"bias"] isKindOfClass:[NSNumber class]] ) {
                    *error = TIOArrayOutputDequantizeScaleAndBiasMustBeNumericError();
                    return NO;
                }
                
            } // end dequantize validation
            
        } // end type:array validation
        
        // type:image validation
        
        if ( [output[@"type"] isEqualToString:@"image"] ) {
            
            // keys validation
            
            NSMutableSet *keys = [NSMutableSet setWithArray:output.allKeys];
            [keys removeObject:@"name"];
            [keys removeObject:@"type"];
            [keys removeObject:@"shape"];
            [keys removeObject:@"denormalize"];
            [keys removeObject:@"format"];
            [keys removeObject:@"labels"];
            
            if ( keys.count != 0 ) {
                *error = TIOImageOutputHasUnusedKeysError();
                return NO;
            }
            
            // format validation
            
            NSArray *formats = @[
                @"RGB",
                @"BGR"
            ];
            
            if ( output[@"format"] == nil  || ![output[@"format"] isKindOfClass:[NSString class]] || ![formats containsObject:output[@"format"]] ) {
                *error = TIOImageOutputFormatNotValidError();
                return NO;
            }
            
            // normalize validation
            
            if ( output[@"denormalize"] != nil ) {
                
                // keys validation
                
                {
                    NSMutableSet *keys = [NSMutableSet setWithArray:[output[@"denormalize"] allKeys]];
                    [keys removeObject:@"standard"];
                    [keys removeObject:@"scale"];
                    [keys removeObject:@"bias"];
                    
                    if ( keys.count != 0 ) {
                        *error = TIOImageOutputDenormalizeHasUnusedKeysError();
                        return NO;
                    }
                }
                
                NSSet *keys = [NSSet setWithArray:[output[@"denormalize"] allKeys]];
                
                if ( keys.count == 0 ) {
                    *error = TIOImageOutputDenormalizeIsEmptyError();
                    return NO;
                }
                
                if ( ![keys containsObject:@"standard"] && ![keys containsObject:@"scale"] && ![keys containsObject:@"bias"] ) {
                    *error = TIOImageOutputDenormalizeMustHaveCorectKeysError();
                    return NO;
                }
                
                // standard validation
                
                if ( [keys containsObject:@"standard"] && ([keys containsObject:@"scale"] || [keys containsObject:@"bias"]) ) {
                    *error = TIOImageOutputDenormalizeMustHaveStandardOrScaleAndBiasKeysError();
                    return NO;
                }
                
                if ( [keys containsObject:@"standard"] ) {
                    NSArray *values = @[
                        @"[-1,1]",
                        @"[0,1]"
                    ];
                    
                    if ( ![output[@"denormalize"][@"standard"] isKindOfClass:[NSString class]] || ![values containsObject:output[@"denormalize"][@"standard"]] ) {
                        *error = TIOImageOutputStandardDenormalizeMustConformError();
                        return NO;
                    }
                }
                
                // scale and bias validation
                
                if ( ([keys containsObject:@"scale"] && ![keys containsObject:@"bias"]) || ([keys containsObject:@"bias"] && ![keys containsObject:@"scale"]) ) {
                    *error = TIOImageOutputDenormalizeMustHaveBothScaleAndBiasKeysError();
                    return NO;
                }
                
                if ( [keys containsObject:@"scale"] && ![output[@"denormalize"][@"scale"] isKindOfClass:[NSNumber class]] ) {
                    *error = TIOImageOutputDenormalizeScaleMustBeNumericError();
                    return NO;
                }
                
                if ( [keys containsObject:@"bias"] ) {
                    
                    if ( ![output[@"denormalize"][@"bias"] isKindOfClass:[NSDictionary class]] ) {
                        *error = TIOImageOutputDenormalizeBiasMustBeDictionaryError();
                        return NO;
                    }
                    
                    {
                        NSMutableSet *biasKeys = [NSMutableSet setWithArray:[output[@"denormalize"][@"bias"] allKeys]];
                        [biasKeys removeObject:@"r"];
                        [biasKeys removeObject:@"g"];
                        [biasKeys removeObject:@"b"];
                        
                        if ( biasKeys.count != 0 ) {
                            *error = TIOImageOutputDenormalizeBiasHasUnusedKeysError();
                            return NO;
                        }
                    }
                    
                    NSSet *biasKeys = [NSSet setWithArray:[output[@"denormalize"][@"bias"] allKeys]];
                
                    if ( biasKeys.count == 0 ) {
                        *error = TIOImageOutputDenormalizeBiasIsEmptyError();
                        return NO;
                    }
                    
                    if ( ![biasKeys containsObject:@"r"] || ![biasKeys containsObject:@"g"] || ![biasKeys containsObject:@"g"] ) {
                        *error = TIOImageOutputDenormalizeBiasMustHaveCorectKeysError();
                        return NO;
                    }
                    
                    if (   ![output[@"denormalize"][@"bias"][@"r"] isKindOfClass:[NSNumber class]]
                        || ![output[@"denormalize"][@"bias"][@"g"] isKindOfClass:[NSNumber class]]
                        || ![output[@"denormalize"][@"bias"][@"g"] isKindOfClass:[NSNumber class]] ) {
                        *error = TIOImageOutputDenormalizeBiasMustBeNumericValuesError();
                        return NO;
                    }
                    
                } // end bias validation
                
            } // end normalize validation
        
        } // end type:image validation
        
    } // end for loop
    
    return YES;
}

- (BOOL)validateCustomValidator:(NSDictionary*)JSON validator:(TIOModelBundleValidationBlock)customValidator error:(NSError**)error {
    return customValidator(self.path, JSON, error);
}

// MARK: - Utilities

- (NSString*)JSONPath {
    return [self.path stringByAppendingPathComponent:kTFModelInfoFile];
}

- (NSDictionary*)loadJSON {
    NSString *path = [self JSONPath];
    NSData *data = [NSData dataWithContentsOfFile:path];
    
    NSError *JSONError;
    NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:data options:0 error:&JSONError];

    if ( JSON == nil ) {
        NSLog(@"Error reading json file at path %@, error %@", path, JSONError);
        return nil;
    }
    
    return JSON;
}

@end

// MARK: - Errors

static NSError * TIOInvalidFilepathError(NSString * path) {
    return [NSError errorWithDomain:TIOModelBundleValidatorErrorDomain code:TIOInvalidFilepathErrorCode userInfo:@{
        NSLocalizedDescriptionKey: [NSString stringWithFormat:@"No .tfbundle directory exists at path, %@", path],
        NSLocalizedRecoverySuggestionErrorKey: @"Make sure a .tfbundle directory is the root directory"
    }];
}

static NSError * TIOInvalidExtensionError(NSString * path) {
    return [NSError errorWithDomain:TIOModelBundleValidatorErrorDomain code:TIOInvalidExtensionErrorCode userInfo:@{
        NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Dirctory exists at path but does not have a .tfbundle extension, %@", path],
        NSLocalizedRecoverySuggestionErrorKey: @"Add the .tfbundle extension to the root directory"
    }];
}

static NSError * TIONoModelJSONFileError(void) {
    return [NSError errorWithDomain:TIOModelBundleValidatorErrorDomain code:TIONoModelJSONFileErrorCode userInfo:@{
        NSLocalizedDescriptionKey: [NSString stringWithFormat:@"No model.json file found"],
        NSLocalizedRecoverySuggestionErrorKey: @"Ensure the root .tfbundle directory contains a model.json file"
    }];
}

static NSError * TIOMalformedJSONError(void) {
    return [NSError errorWithDomain:TIOModelBundleValidatorErrorDomain code:TIOMalformedJSONErrorCode userInfo:@{
        NSLocalizedDescriptionKey: [NSString stringWithFormat:@"The model.json file could not be read"],
        NSLocalizedRecoverySuggestionErrorKey: @"Make sure that model.json contains valid json"
    }];
}

static NSError * TIOMissingPropertyError(NSString * property) {
    return [NSError errorWithDomain:TIOModelBundleValidatorErrorDomain code:TIOMissingPropertyErrorCode userInfo:@{
        NSLocalizedDescriptionKey: [NSString stringWithFormat:@"The model.json file is missing the %@ property", property],
        NSLocalizedRecoverySuggestionErrorKey: @"Ensure that model.json contains the %@ property and that it is a valid value"
    }];
}

// MARK: - Input Errors

static NSError * TIOZeroInputsError(void) {
    return [NSError errorWithDomain:TIOModelBundleValidatorErrorDomain code:TIOZeroInputsErrorCode userInfo:@{
        NSLocalizedDescriptionKey: [NSString stringWithFormat:@"The model.json file has zero inputs"],
        NSLocalizedRecoverySuggestionErrorKey: @"Ensure that model.json contains at least one input and that it is a valid value"
    }];
}

static NSError * TIOMissingInputPropertyError(NSString * property) {
    return [NSError errorWithDomain:TIOModelBundleValidatorErrorDomain code:TIOMissingInputPropertyErrorCode userInfo:@{
        NSLocalizedDescriptionKey: [NSString stringWithFormat:@"An inputs fields in the model.json file is missing the %@ property", property],
        NSLocalizedRecoverySuggestionErrorKey: @"Ensure that every inputs field in model.json contains the %@ property and that it is a valid value"
    }];
}

static NSError * TIOInputShapeMustBeArrayError(void) {
    return [NSError errorWithDomain:TIOModelBundleValidatorErrorDomain code:TIOInputShapeMustBeArrayErrorCode userInfo:@{
        NSLocalizedDescriptionKey: [NSString stringWithFormat:@"An inputs.shape field in the model.json file is not an array"],
        NSLocalizedRecoverySuggestionErrorKey: @"Ensure that every inputs.shape field in model.json is an array with one or more numeric values"
    }];
}

static NSError * TIOInputShapeMustHaveEntriesError(void) {
    return [NSError errorWithDomain:TIOModelBundleValidatorErrorDomain code:TIOInputShapeMustHaveEntriesErrorCode userInfo:@{
        NSLocalizedDescriptionKey: [NSString stringWithFormat:@"An inputs.shape field in the model.json file is empty"],
        NSLocalizedRecoverySuggestionErrorKey: @"Ensure that every inputs.shape field in model.json is an array with one or more numeric values"
    }];
}

static NSError * TIOInputShapeMustHaveNumericEntriesError(void) {
    return [NSError errorWithDomain:TIOModelBundleValidatorErrorDomain code:TIOInputShapeMustHaveNumericEntriesErrorCode userInfo:@{
        NSLocalizedDescriptionKey: [NSString stringWithFormat:@"An inputs.shape field in the model.json file contains non-numeric values"],
        NSLocalizedRecoverySuggestionErrorKey: @"Ensure that every inputs.shape field in model.json is an array with only numeric values"
    }];
}

static NSError * TIOInputTypeMustConformError(void) {
    return [NSError errorWithDomain:TIOModelBundleValidatorErrorDomain code:TIOInputTypeMustConformErrorCode userInfo:@{
        NSLocalizedDescriptionKey: [NSString stringWithFormat:@"An inputs.type field in the model.json file is invalid"],
        NSLocalizedRecoverySuggestionErrorKey: @"Ensure that every inputs.type field in model.json is either \"array\" or \"image\""
    }];
}

static NSError * TIOArrayInputHasUnusedKeysError(void) {
    return [NSError errorWithDomain:TIOModelBundleValidatorErrorDomain code:TIOArrayInputHasUnusedKeysErrorCode userInfo:@{
        NSLocalizedDescriptionKey: [NSString stringWithFormat:@"An inputs array type field in the model.json file has unused keys"],
        NSLocalizedRecoverySuggestionErrorKey: @"Ensure that every inputs array type field in model.json has only name, type, shape, and and optional quantize keys"
    }];
}

static NSError * TIOArrayInputQuantizeIsEmptyError(void) {
    return [NSError errorWithDomain:TIOModelBundleValidatorErrorDomain code:TIOArrayInputQuantizeIsEmptyErrorCode userInfo:@{
        NSLocalizedDescriptionKey: [NSString stringWithFormat:@"An inputs.quantize field in the model.json file is empty"],
        NSLocalizedRecoverySuggestionErrorKey: @"Ensure that every inputs.quantize field in model.json has a standard or scale and bias keys"
    }];
}

static NSError * TIOArrayInputQuantizeHasUnusedKeysError(void) {
    return [NSError errorWithDomain:TIOModelBundleValidatorErrorDomain code:TIOArrayInputQuantizeHasUnusedKeysErrorCode userInfo:@{
        NSLocalizedDescriptionKey: [NSString stringWithFormat:@"An inputs.quantize field in the model.json file has unused keys"],
        NSLocalizedRecoverySuggestionErrorKey: @"Ensure that every inputs.quantize field in model.json has only standard or scale and bias keys"
    }];
}

static NSError * TIOArrayInputQuantizeMustHaveCorectKeysError(void) {
    return [NSError errorWithDomain:TIOModelBundleValidatorErrorDomain code:TIOArrayInputQuantizeMustHaveCorectKeysErrorCode userInfo:@{
        NSLocalizedDescriptionKey: [NSString stringWithFormat:@"An inputs.quantize field is missing valid keys"],
        NSLocalizedRecoverySuggestionErrorKey: @"Ensure that every inputs.quantize field in model.json has only standard or scale and bias keys"
    }];
}

static NSError * TIOArrayInputQuantizeMustHaveStandardOrScaleAndBiasKeysError(void) {
    return [NSError errorWithDomain:TIOModelBundleValidatorErrorDomain code:TIOArrayInputQuantizeMustHaveStandardOrScaleAndBiasKeysErrorCode userInfo:@{
        NSLocalizedDescriptionKey: [NSString stringWithFormat:@"An inputs.quantize field is missing the valid keys"],
        NSLocalizedRecoverySuggestionErrorKey: @"Ensure that every inputs.quantize field in model.json has only standard or scale and bias keys"
    }];
}

static NSError * TIOArrayInputStandardQuantizeMustConformError(void) {
    return [NSError errorWithDomain:TIOModelBundleValidatorErrorDomain code:TIOArrayInputStandardQuantizeMustConformErrorCode userInfo:@{
        NSLocalizedDescriptionKey: [NSString stringWithFormat:@"An inputs.quantize.standard field has an invalid value"],
        NSLocalizedRecoverySuggestionErrorKey: @"Ensure that every inputs.quantize.standard field in model.json is either \"[0,1]\" or \"[-1,1]\""
    }];
}

static NSError * TIOArrayInputQuantizeScaleAndBiasMustBeNumericError(void) {
    return [NSError errorWithDomain:TIOModelBundleValidatorErrorDomain code:TIOArrayInputQuantizeScaleAndBiasMustBeNumericErrorCode userInfo:@{
        NSLocalizedDescriptionKey: [NSString stringWithFormat:@"An inputs.quantize.scale or inputs.quantize.bias field has an invalid value"],
        NSLocalizedRecoverySuggestionErrorKey: @"Ensure that every inputs.quantize.scale and inputs.quantize.bias fields in model.json is a numeric value"
    }];
}

static NSError * TIOArrayInputQuantizeMustHaveBothScaleAndBiasKeysError(void) {
    return [NSError errorWithDomain:TIOModelBundleValidatorErrorDomain code:TIOArrayInputQuantizeMustHaveBothScaleAndBiasKeysErrorCode userInfo:@{
        NSLocalizedDescriptionKey: [NSString stringWithFormat:@"An inputs.quantize field has either standard or bias keys but not both"],
        NSLocalizedRecoverySuggestionErrorKey: @"Ensure that every inputs.quantize field in model.json has either standard or scale and bias keys"
    }];
}

static NSError * TIOImageInputHasUnusedKeysError(void) {
    return [NSError errorWithDomain:TIOModelBundleValidatorErrorDomain code:TIOImageInputHasUnusedKeysErrorCode userInfo:@{
        NSLocalizedDescriptionKey: [NSString stringWithFormat:@"An inputs image type field in the model.json file has unused keys"],
        NSLocalizedRecoverySuggestionErrorKey: @"Ensure that every inputs image type field in model.json has only name, type, shape, and normalize keys"
    }];
}

static NSError * TIOImageInputNormalizeIsEmptyError(void) {
    return [NSError errorWithDomain:TIOModelBundleValidatorErrorDomain code:TIOImageInputNormalizeIsEmptyErrorCode userInfo:@{
        NSLocalizedDescriptionKey: [NSString stringWithFormat:@"An inputs.normalize field in the model.json file is empty"],
        NSLocalizedRecoverySuggestionErrorKey: @"Ensure that every inputs.normalize field in model.json has a standard or scale and bias keys"
    }];
}

static NSError * TIOImageInputNormalizeHasUnusedKeysError(void) {
    return [NSError errorWithDomain:TIOModelBundleValidatorErrorDomain code:TIOImageInputNormalizeHasUnusedKeysErrorCode userInfo:@{
        NSLocalizedDescriptionKey: [NSString stringWithFormat:@"An inputs.normalize image type field in the model.json file has unused keys"],
        NSLocalizedRecoverySuggestionErrorKey: @"Ensure that every inputs.normalize image type field in model.json has only name, type, shape, and normalize keys"
    }];
}

static NSError * TIOImageInputNormalizeMustHaveCorectKeysError(void) {
    return [NSError errorWithDomain:TIOModelBundleValidatorErrorDomain code:TIOImageInputNormalizeMustHaveCorectKeysErrorCode userInfo:@{
        NSLocalizedDescriptionKey: [NSString stringWithFormat:@"An inputs.normalize field is missing valid keys"],
        NSLocalizedRecoverySuggestionErrorKey: @"Ensure that every inputs.normalize field in model.json has only standard or scale and bias keys"
    }];
}

static NSError * TIOImageInputNormalizeMustHaveStandardOrScaleAndBiasKeysError(void) {
    return [NSError errorWithDomain:TIOModelBundleValidatorErrorDomain code:TIOImageInputNormalizeMustHaveStandardOrScaleAndBiasKeysErrorCode userInfo:@{
        NSLocalizedDescriptionKey: [NSString stringWithFormat:@"An inputs.normalize field is missing the valid keys"],
        NSLocalizedRecoverySuggestionErrorKey: @"Ensure that every inputs.normalize field in model.json has only standard or scale and bias keys"
    }];
}

static NSError * TIOImageInputStandardNormalizeMustConformError(void) {
    return [NSError errorWithDomain:TIOModelBundleValidatorErrorDomain code:TIOImageInputStandardNormalizeMustConformErrorCode userInfo:@{
        NSLocalizedDescriptionKey: [NSString stringWithFormat:@"An inputs.normalize.standard field has an invalid value"],
        NSLocalizedRecoverySuggestionErrorKey: @"Ensure that every inputs.normalize.standard field in model.json is either \"[0,1]\" or \"[-1,1]\""
    }];
}

static NSError * TIOImageInputNormalizeMustHaveBothScaleAndBiasKeysError(void) {
    return [NSError errorWithDomain:TIOModelBundleValidatorErrorDomain code:TIOImageInputNormalizeMustHaveBothScaleAndBiasKeysErrorCode userInfo:@{
        NSLocalizedDescriptionKey: [NSString stringWithFormat:@"An inputs.normalize field has either standard or bias keys but not both"],
        NSLocalizedRecoverySuggestionErrorKey: @"Ensure that every inputs.normalize field in model.json has either standard or scale and bias keys"
    }];
}

static NSError * TIOImageInputNormalizeScaleMustBeNumericError(void) {
    return [NSError errorWithDomain:TIOModelBundleValidatorErrorDomain code:TIOImageInputNormalizeScaleMustBeNumericErrorCode userInfo:@{
        NSLocalizedDescriptionKey: [NSString stringWithFormat:@"An inputs.quantize.scale field has an invalid value"],
        NSLocalizedRecoverySuggestionErrorKey: @"Ensure that every inputs.quantize.scale field in model.json is a numeric value"
    }];
}

static NSError * TIOImageInputNormalizeBiasMustBeDictionaryError(void) {
    return [NSError errorWithDomain:TIOModelBundleValidatorErrorDomain code:TIOImageInputNormalizeBiasMustBeDictionaryErrorCode userInfo:@{
        NSLocalizedDescriptionKey: [NSString stringWithFormat:@"An inputs.quantize.bias field has an invalid value"],
        NSLocalizedRecoverySuggestionErrorKey: @"Ensure that every inputs.quantize.bias field in model.json is a dictionary with r, g, and b numeric values"
    }];
}

static NSError * TIOImageInputNormalizeBiasHasUnusedKeysError(void) {
    return [NSError errorWithDomain:TIOModelBundleValidatorErrorDomain code:TIOImageInputNormalizeBiasHasUnusedKeysErrorCode userInfo:@{
        NSLocalizedDescriptionKey: [NSString stringWithFormat:@"An inputs.quantize.bias field has unused keys"],
        NSLocalizedRecoverySuggestionErrorKey: @"Ensure that every inputs.quantize.bias field in model.json is a dictionary with r, g, and b numeric values"
    }];
}

static NSError * TIOImageInputNormalizeBiasIsEmptyError(void) {
    return [NSError errorWithDomain:TIOModelBundleValidatorErrorDomain code:TIOImageInputNormalizeBiasIsEmptyErrorCode userInfo:@{
        NSLocalizedDescriptionKey: [NSString stringWithFormat:@"An inputs.quantize.bias field is empty"],
        NSLocalizedRecoverySuggestionErrorKey: @"Ensure that every inputs.quantize.bias field in model.json is a dictionary with r, g, and b numeric values"
    }];
}

static NSError * TIOImageInputNormalizeBiasMustHaveCorectKeysError(void) {
    return [NSError errorWithDomain:TIOModelBundleValidatorErrorDomain code:TIOImageInputNormalizeBiasMustHaveCorectKeysErrorCode userInfo:@{
        NSLocalizedDescriptionKey: [NSString stringWithFormat:@"An inputs.quantize.bias field has incorrect values"],
        NSLocalizedRecoverySuggestionErrorKey: @"Ensure that every inputs.quantize.bias field in model.json is a dictionary with r, g, and b numeric values"
    }];
}

static NSError * TIOImageInputNormalizeBiasMustBeNumericValuesError(void) {
    return [NSError errorWithDomain:TIOModelBundleValidatorErrorDomain code:TIOImageInputNormalizeBiasMustBeNumericValuesErrorCode userInfo:@{
        NSLocalizedDescriptionKey: [NSString stringWithFormat:@"An inputs.quantize.bias field has incorrect values"],
        NSLocalizedRecoverySuggestionErrorKey: @"Ensure that every inputs.quantize.bias field in model.json is a dictionary with r, g, and b numeric values"
    }];
}

static NSError * TIOImageInputFormatNotValidError(void) {
    return [NSError errorWithDomain:TIOModelBundleValidatorErrorDomain code:TIOImageInputFormatNotValidErrorCode userInfo:@{
        NSLocalizedDescriptionKey: [NSString stringWithFormat:@"An image type inputs.format field is missing or has an invalid value"],
        NSLocalizedRecoverySuggestionErrorKey: @"Ensure that every image type inputs.format field in model.json is either \"RGB\" or \"BRG\""
    }];
}

// MARK: - Output Errors

static NSError * TIOZeroOutputsError(void) {
    return [NSError errorWithDomain:TIOModelBundleValidatorErrorDomain code:TIOZeroOutputsErrorCode userInfo:@{
        NSLocalizedDescriptionKey: [NSString stringWithFormat:@"The model.json file has zero outputs"],
        NSLocalizedRecoverySuggestionErrorKey: @"Ensure that model.json contains at least one output and that it is a valid value"
    }];
}

static NSError * TIOMissingOutputPropertyError(NSString * property) {
    return [NSError errorWithDomain:TIOModelBundleValidatorErrorDomain code:TIOMissingOutputPropertyErrorCode userInfo:@{
        NSLocalizedDescriptionKey: [NSString stringWithFormat:@"An outputs fields in the model.json file is missing the %@ property", property],
        NSLocalizedRecoverySuggestionErrorKey: @"Ensure that every outputs field in model.json contains the %@ property and that it is a valid value"
    }];
}

static NSError * TIOOutputShapeMustBeArrayError(void) {
    return [NSError errorWithDomain:TIOModelBundleValidatorErrorDomain code:TIOOutputShapeMustBeArrayErrorCode userInfo:@{
        NSLocalizedDescriptionKey: [NSString stringWithFormat:@"An outputs.shape field in the model.json file is not an array"],
        NSLocalizedRecoverySuggestionErrorKey: @"Ensure that every outputs.shape field in model.json is an array with one or more numeric values"
    }];
}

static NSError * TIOOutputShapeMustHaveEntriesError(void) {
    return [NSError errorWithDomain:TIOModelBundleValidatorErrorDomain code:TIOOutputShapeMustHaveEntriesErrorCode userInfo:@{
        NSLocalizedDescriptionKey: [NSString stringWithFormat:@"An outputs.shape field in the model.json file is empty"],
        NSLocalizedRecoverySuggestionErrorKey: @"Ensure that every outputs.shape field in model.json is an array with one or more numeric values"
    }];
}

static NSError * TIOOutputShapeMustHaveNumericEntriesError(void) {
    return [NSError errorWithDomain:TIOModelBundleValidatorErrorDomain code:TIOOutputShapeMustHaveNumericEntriesErrorCode userInfo:@{
        NSLocalizedDescriptionKey: [NSString stringWithFormat:@"An outputs.shape field in the model.json file contains non-numeric values"],
        NSLocalizedRecoverySuggestionErrorKey: @"Ensure that every outputs.shape field in model.json is an array with only numeric values"
    }];
}

static NSError * TIOOutputTypeMustConformError(void) {
    return [NSError errorWithDomain:TIOModelBundleValidatorErrorDomain code:TIOOutputTypeMustConformErrorCode userInfo:@{
        NSLocalizedDescriptionKey: [NSString stringWithFormat:@"An outputs.type field in the model.json file is invalid"],
        NSLocalizedRecoverySuggestionErrorKey: @"Ensure that every outputs.type field in model.json is either \"array\" or \"image\""
    }];
}

static NSError * TIOArrayOutputHasUnusedKeysError(void) {
    return [NSError errorWithDomain:TIOModelBundleValidatorErrorDomain code:TIOArrayOutputHasUnusedKeysErrorCode userInfo:@{
        NSLocalizedDescriptionKey: [NSString stringWithFormat:@"An outputs array type field in the model.json file has unused keys"],
        NSLocalizedRecoverySuggestionErrorKey: @"Ensure that every outputs array type field in model.json has only name, type, shape, and a labels key with an optional dequantize key"
    }];
}

static NSError * TIOArrayOutputDequantizeIsEmptyError(void) {
    return [NSError errorWithDomain:TIOModelBundleValidatorErrorDomain code:TIOArrayOutputDequantizeIsEmptyErrorCode userInfo:@{
        NSLocalizedDescriptionKey: [NSString stringWithFormat:@"An outputs.quantize field in the model.json file is empty"],
        NSLocalizedRecoverySuggestionErrorKey: @"Ensure that every outputs.quantize field in model.json has a standard or scale and bias keys"
    }];
}

static NSError * TIOArrayOutputDequantizeHasUnusedKeysError(void) {
    return [NSError errorWithDomain:TIOModelBundleValidatorErrorDomain code:TIOArrayOutputDequantizeHasUnusedKeysErrorCode userInfo:@{
        NSLocalizedDescriptionKey: [NSString stringWithFormat:@"An outputs.quantize field in the model.json file has unused keys"],
        NSLocalizedRecoverySuggestionErrorKey: @"Ensure that every outputs.quantize field in model.json has only standard or scale and bias keys"
    }];
}

static NSError * TIOArrayOutputDequantizeMustHaveCorectKeysError(void) {
    return [NSError errorWithDomain:TIOModelBundleValidatorErrorDomain code:TIOArrayOutputDequantizeMustHaveCorectKeysErrorCode userInfo:@{
        NSLocalizedDescriptionKey: [NSString stringWithFormat:@"An outputs.quantize field is missing valid keys"],
        NSLocalizedRecoverySuggestionErrorKey: @"Ensure that every outputs.quantize field in model.json has only standard or scale and bias keys"
    }];
}

static NSError * TIOArrayOutputDequantizeMustHaveStandardOrScaleAndBiasKeysError(void) {
    return [NSError errorWithDomain:TIOModelBundleValidatorErrorDomain code:TIOArrayOutputDequantizeMustHaveStandardOrScaleAndBiasKeysErrorCode userInfo:@{
        NSLocalizedDescriptionKey: [NSString stringWithFormat:@"An outputs.quantize field is missing the valid keys"],
        NSLocalizedRecoverySuggestionErrorKey: @"Ensure that every outputs.quantize field in model.json has only standard or scale and bias keys"
    }];
}

static NSError * TIOArrayOutputStandardDequantizeMustConformError(void) {
    return [NSError errorWithDomain:TIOModelBundleValidatorErrorDomain code:TIOArrayOutputStandardDequantizeMustConformErrorCode userInfo:@{
        NSLocalizedDescriptionKey: [NSString stringWithFormat:@"An outputs.quantize.standard field has an invalid value"],
        NSLocalizedRecoverySuggestionErrorKey: @"Ensure that every outputs.quantize.standard field in model.json is either \"[0,1]\" or \"[-1,1]\""
    }];
}

static NSError * TIOArrayOutputDequantizeScaleAndBiasMustBeNumericError(void) {
    return [NSError errorWithDomain:TIOModelBundleValidatorErrorDomain code:TIOArrayOutputDequantizeScaleAndBiasMustBeNumericErrorCode userInfo:@{
        NSLocalizedDescriptionKey: [NSString stringWithFormat:@"An outputs.quantize.scale or outputs.quantize.bias field has an invalid value"],
        NSLocalizedRecoverySuggestionErrorKey: @"Ensure that every outputs.quantize.scale and outputs.quantize.bias fields in model.json is a numeric value"
    }];
}

static NSError * TIOArrayOutputDequantizeMustHaveBothScaleAndBiasKeysError(void) {
    return [NSError errorWithDomain:TIOModelBundleValidatorErrorDomain code:TIOArrayOutputDequantizeMustHaveBothScaleAndBiasKeysErrorCode userInfo:@{
        NSLocalizedDescriptionKey: [NSString stringWithFormat:@"An outputs.quantize field has either standard or bias keys but not both"],
        NSLocalizedRecoverySuggestionErrorKey: @"Ensure that every outputs.quantize field in model.json has either standard or scale and bias keys"
    }];
}

static NSError * TIOImageOutputHasUnusedKeysError(void) {
    return [NSError errorWithDomain:TIOModelBundleValidatorErrorDomain code:TIOImageOutputHasUnusedKeysErrorCode userInfo:@{
        NSLocalizedDescriptionKey: [NSString stringWithFormat:@"An outputs image type field in the model.json file has unused keys"],
        NSLocalizedRecoverySuggestionErrorKey: @"Ensure that every outputs image type field in model.json has only name, type, shape, and normalize keys"
    }];
}

static NSError * TIOImageOutputDenormalizeIsEmptyError(void) {
    return [NSError errorWithDomain:TIOModelBundleValidatorErrorDomain code:TIOImageOutputDenormalizeIsEmptyErrorCode userInfo:@{
        NSLocalizedDescriptionKey: [NSString stringWithFormat:@"An outputs.normalize field in the model.json file is empty"],
        NSLocalizedRecoverySuggestionErrorKey: @"Ensure that every outputs.normalize field in model.json has a standard or scale and bias keys"
    }];
}

static NSError * TIOImageOutputDenormalizeHasUnusedKeysError(void) {
    return [NSError errorWithDomain:TIOModelBundleValidatorErrorDomain code:TIOImageOutputDenormalizeHasUnusedKeysErrorCode userInfo:@{
        NSLocalizedDescriptionKey: [NSString stringWithFormat:@"An outputs.normalize image type field in the model.json file has unused keys"],
        NSLocalizedRecoverySuggestionErrorKey: @"Ensure that every outputs.normalize image type field in model.json has only name, type, shape, and normalize keys"
    }];
}

static NSError * TIOImageOutputDenormalizeMustHaveCorectKeysError(void) {
    return [NSError errorWithDomain:TIOModelBundleValidatorErrorDomain code:TIOImageOutputDenormalizeMustHaveCorectKeysErrorCode userInfo:@{
        NSLocalizedDescriptionKey: [NSString stringWithFormat:@"An outputs.normalize field is missing valid keys"],
        NSLocalizedRecoverySuggestionErrorKey: @"Ensure that every outputs.normalize field in model.json has only standard or scale and bias keys"
    }];
}

static NSError * TIOImageOutputDenormalizeMustHaveStandardOrScaleAndBiasKeysError(void) {
    return [NSError errorWithDomain:TIOModelBundleValidatorErrorDomain code:TIOImageOutputDenormalizeMustHaveStandardOrScaleAndBiasKeysErrorCode userInfo:@{
        NSLocalizedDescriptionKey: [NSString stringWithFormat:@"An outputs.normalize field is missing the valid keys"],
        NSLocalizedRecoverySuggestionErrorKey: @"Ensure that every outputs.normalize field in model.json has only standard or scale and bias keys"
    }];
}

static NSError * TIOImageOutputStandardDenormalizeMustConformError(void) {
    return [NSError errorWithDomain:TIOModelBundleValidatorErrorDomain code:TIOImageOutputStandardDenormalizeMustConformErrorCode userInfo:@{
        NSLocalizedDescriptionKey: [NSString stringWithFormat:@"An outputs.normalize.standard field has an invalid value"],
        NSLocalizedRecoverySuggestionErrorKey: @"Ensure that every outputs.normalize.standard field in model.json is either \"[0,1]\" or \"[-1,1]\""
    }];
}

static NSError * TIOImageOutputDenormalizeMustHaveBothScaleAndBiasKeysError(void) {
    return [NSError errorWithDomain:TIOModelBundleValidatorErrorDomain code:TIOImageOutputDenormalizeMustHaveBothScaleAndBiasKeysErrorCode userInfo:@{
        NSLocalizedDescriptionKey: [NSString stringWithFormat:@"An outputs.normalize field has either standard or bias keys but not both"],
        NSLocalizedRecoverySuggestionErrorKey: @"Ensure that every outputs.normalize field in model.json has either standard or scale and bias keys"
    }];
}

static NSError * TIOImageOutputDenormalizeScaleMustBeNumericError(void) {
    return [NSError errorWithDomain:TIOModelBundleValidatorErrorDomain code:TIOImageOutputDenormalizeScaleMustBeNumericErrorCode userInfo:@{
        NSLocalizedDescriptionKey: [NSString stringWithFormat:@"An outputs.quantize.scale field has an invalid value"],
        NSLocalizedRecoverySuggestionErrorKey: @"Ensure that every outputs.quantize.scale field in model.json is a numeric value"
    }];
}

static NSError * TIOImageOutputDenormalizeBiasMustBeDictionaryError(void) {
    return [NSError errorWithDomain:TIOModelBundleValidatorErrorDomain code:TIOImageOutputDenormalizeBiasMustBeDictionaryErrorCode userInfo:@{
        NSLocalizedDescriptionKey: [NSString stringWithFormat:@"An outputs.quantize.bias field has an invalid value"],
        NSLocalizedRecoverySuggestionErrorKey: @"Ensure that every outputs.quantize.bias field in model.json is a dictionary with r, g, and b numeric values"
    }];
}

static NSError * TIOImageOutputDenormalizeBiasHasUnusedKeysError(void) {
    return [NSError errorWithDomain:TIOModelBundleValidatorErrorDomain code:TIOImageOutputDenormalizeBiasHasUnusedKeysErrorCode userInfo:@{
        NSLocalizedDescriptionKey: [NSString stringWithFormat:@"An outputs.quantize.bias field has unused keys"],
        NSLocalizedRecoverySuggestionErrorKey: @"Ensure that every outputs.quantize.bias field in model.json is a dictionary with r, g, and b numeric values"
    }];
}

static NSError * TIOImageOutputDenormalizeBiasIsEmptyError(void) {
    return [NSError errorWithDomain:TIOModelBundleValidatorErrorDomain code:TIOImageOutputDenormalizeBiasIsEmptyErrorCode userInfo:@{
        NSLocalizedDescriptionKey: [NSString stringWithFormat:@"An outputs.quantize.bias field is empty"],
        NSLocalizedRecoverySuggestionErrorKey: @"Ensure that every outputs.quantize.bias field in model.json is a dictionary with r, g, and b numeric values"
    }];
}

static NSError * TIOImageOutputDenormalizeBiasMustHaveCorectKeysError(void) {
    return [NSError errorWithDomain:TIOModelBundleValidatorErrorDomain code:TIOImageOutputDenormalizeBiasMustHaveCorectKeysErrorCode userInfo:@{
        NSLocalizedDescriptionKey: [NSString stringWithFormat:@"An outputs.quantize.bias field has incorrect values"],
        NSLocalizedRecoverySuggestionErrorKey: @"Ensure that every outputs.quantize.bias field in model.json is a dictionary with r, g, and b numeric values"
    }];
}

static NSError * TIOImageOutputDenormalizeBiasMustBeNumericValuesError(void) {
    return [NSError errorWithDomain:TIOModelBundleValidatorErrorDomain code:TIOImageOutputDenormalizeBiasMustBeNumericValuesErrorCode userInfo:@{
        NSLocalizedDescriptionKey: [NSString stringWithFormat:@"An outputs.quantize.bias field has incorrect values"],
        NSLocalizedRecoverySuggestionErrorKey: @"Ensure that every outputs.quantize.bias field in model.json is a dictionary with r, g, and b numeric values"
    }];
}

static NSError * TIOImageOutputFormatNotValidError(void) {
    return [NSError errorWithDomain:TIOModelBundleValidatorErrorDomain code:TIOImageOutputFormatNotValidErrorCode userInfo:@{
        NSLocalizedDescriptionKey: [NSString stringWithFormat:@"An image type outputs.format field is missing or has an invalid value"],
        NSLocalizedRecoverySuggestionErrorKey: @"Ensure that every image type outputs.format field in model.json is either \"RGB\" or \"BRG\""
    }];
}

// MARK: - Model Errors

static NSError * TIOModelHasUnusedKeysError(void) {
    return [NSError errorWithDomain:TIOModelBundleValidatorErrorDomain code:TIOModelHasUnusedKeysErrorCode userInfo:@{
        NSLocalizedDescriptionKey: [NSString stringWithFormat:@"The model field has unused keys"],
        NSLocalizedRecoverySuggestionErrorKey: @"Ensure that the model field in model.json has a file and quantized entry and optionally a class and type entry"
    }];
}

static NSError * TIOModelMissingPropertyError(NSString * property) {
    return [NSError errorWithDomain:TIOModelBundleValidatorErrorDomain code:TIOModelMissingPropertyErrorCode userInfo:@{
        NSLocalizedDescriptionKey: [NSString stringWithFormat:@"The model field is missing the %@ property", property],
        NSLocalizedRecoverySuggestionErrorKey: @"Ensure that the model field in model.json contains the %@ property and that it is a valid value"
    }];
}

// MARK: - Assets Errors

static NSError * TIOModelFileDoesNotExistsError(NSString * filename) {
    return [NSError errorWithDomain:TIOModelBundleValidatorErrorDomain code:TIOModelFileDoesNotExistsErrorCode userInfo:@{
        NSLocalizedDescriptionKey: [NSString stringWithFormat:@"The model.file \"%@\" could not be found", filename],
        NSLocalizedRecoverySuggestionErrorKey: @"Ensure that the model.file value is the name of a file in the root bundle directory"
    }];
}

static NSError * TIOLabelsFileDoesNotExistError(NSString * filename) {
    return [NSError errorWithDomain:TIOModelBundleValidatorErrorDomain code:TIOLabelsFileDoesNotExistErrorCode userInfo:@{
        NSLocalizedDescriptionKey: [NSString stringWithFormat:@"The outputs.label file \"%@\" could not be found", filename],
        NSLocalizedRecoverySuggestionErrorKey: @"Ensure that the outputs.label file is the name of a file in the assets directory"
    }];
}
