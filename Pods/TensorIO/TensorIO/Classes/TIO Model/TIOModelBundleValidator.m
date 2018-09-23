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

@implementation TIOModelBundleValidator

- (instancetype)initWithModelBundleAtPath:(NSString*)path {
    if (self = [super init]) {
        _path = path;
    }
    return self;
}

// MARK: - Errors

- (NSError*)invalidFilepathError {
    return [NSError errorWithDomain:@"doc.ai.tensorio" code:301 userInfo:@{
        NSLocalizedDescriptionKey: [NSString stringWithFormat:@"No .tfbundle directory exists at path, %@", self.path],
        NSLocalizedRecoverySuggestionErrorKey: @"Make sure a .tfbundle directory is the root directory"
    }];
}

- (NSError*)invalidExtensionError {
    return [NSError errorWithDomain:@"doc.ai.tensorio" code:302 userInfo:@{
        NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Dirctory exists at path but does not have a .tfbundle extension, %@", self.path],
        NSLocalizedRecoverySuggestionErrorKey: @"Add the .tfbundle extension to the root directory"
    }];
}

- (NSError*)noModelJSONFileError {
    return [NSError errorWithDomain:@"doc.ai.tensorio" code:303 userInfo:@{
        NSLocalizedDescriptionKey: [NSString stringWithFormat:@"No model.json file found"],
        NSLocalizedRecoverySuggestionErrorKey: @"Ensure the root .tfbundle directory contains a model.json file"
    }];
}

- (NSError*)malformedJSONError {
    return [NSError errorWithDomain:@"doc.ai.tensorio" code:300 userInfo:@{
        NSLocalizedDescriptionKey: [NSString stringWithFormat:@"The model.json file could not be read"],
        NSLocalizedRecoverySuggestionErrorKey: @"Make sure that model.json contains valid json"
    }];
}

- (NSError*)missingPropertyError:(NSString*)property {
    return [NSError errorWithDomain:@"doc.ai.tensorio" code:304 userInfo:@{
        NSLocalizedDescriptionKey: [NSString stringWithFormat:@"The model.json file is missing the %@ property", property],
        NSLocalizedRecoverySuggestionErrorKey: @"Ensure that model.json contains the %@ property and that it is a valid value"
    }];
}

// MARK: - Input Errors

- (NSError*)zeroInputsError {
    return [NSError errorWithDomain:@"doc.ai.tensorio" code:305 userInfo:@{
        NSLocalizedDescriptionKey: [NSString stringWithFormat:@"The model.json file has zero inputs"],
        NSLocalizedRecoverySuggestionErrorKey: @"Ensure that model.json contains at least one input and that it is a valid value"
    }];
}

- (NSError*)missingInputPropertyError:(NSString*)property {
    return [NSError errorWithDomain:@"doc.ai.tensorio" code:306 userInfo:@{
        NSLocalizedDescriptionKey: [NSString stringWithFormat:@"An inputs fields in the model.json file is missing the %@ property", property],
        NSLocalizedRecoverySuggestionErrorKey: @"Ensure that every inputs field in model.json contains the %@ property and that it is a valid value"
    }];
}

- (NSError*)inputShapeMustBeArrayError {
    return [NSError errorWithDomain:@"doc.ai.tensorio" code:307 userInfo:@{
        NSLocalizedDescriptionKey: [NSString stringWithFormat:@"An inputs.shape field in the model.json file is not an array"],
        NSLocalizedRecoverySuggestionErrorKey: @"Ensure that every inputs.shape field in model.json is an array with one or more numeric values"
    }];
}

- (NSError*)inputShapeMustHaveEntriesError {
    return [NSError errorWithDomain:@"doc.ai.tensorio" code:308 userInfo:@{
        NSLocalizedDescriptionKey: [NSString stringWithFormat:@"An inputs.shape field in the model.json file is empty"],
        NSLocalizedRecoverySuggestionErrorKey: @"Ensure that every inputs.shape field in model.json is an array with one or more numeric values"
    }];
}

- (NSError*)inputShapeMustHaveNumericEntriesError {
    return [NSError errorWithDomain:@"doc.ai.tensorio" code:309 userInfo:@{
        NSLocalizedDescriptionKey: [NSString stringWithFormat:@"An inputs.shape field in the model.json file contains non-numeric values"],
        NSLocalizedRecoverySuggestionErrorKey: @"Ensure that every inputs.shape field in model.json is an array with only numeric values"
    }];
}

- (NSError*)inputTypeMustConformError {
    return [NSError errorWithDomain:@"doc.ai.tensorio" code:310 userInfo:@{
        NSLocalizedDescriptionKey: [NSString stringWithFormat:@"An inputs.type field in the model.json file is invalid"],
        NSLocalizedRecoverySuggestionErrorKey: @"Ensure that every inputs.type field in model.json is either \"array\" or \"image\""
    }];
}

- (NSError*)arrayInputHasUnusedKeysError {
    return [NSError errorWithDomain:@"doc.ai.tensorio" code:311 userInfo:@{
        NSLocalizedDescriptionKey: [NSString stringWithFormat:@"An inputs array type field in the model.json file has unused keys"],
        NSLocalizedRecoverySuggestionErrorKey: @"Ensure that every inputs array type field in model.json has only name, type, shape, and and optional quantize keys"
    }];
}

- (NSError*)arrayInputQuantizeIsEmptyError {
    return [NSError errorWithDomain:@"doc.ai.tensorio" code:312 userInfo:@{
        NSLocalizedDescriptionKey: [NSString stringWithFormat:@"An inputs.quantize field in the model.json file is empty"],
        NSLocalizedRecoverySuggestionErrorKey: @"Ensure that every inputs.quantize field in model.json has a standard or scale and bias keys"
    }];
}

- (NSError*)arrayInputQuantizeHasUnusedKeysError {
    return [NSError errorWithDomain:@"doc.ai.tensorio" code:313 userInfo:@{
        NSLocalizedDescriptionKey: [NSString stringWithFormat:@"An inputs.quantize field in the model.json file has unused keys"],
        NSLocalizedRecoverySuggestionErrorKey: @"Ensure that every inputs.quantize field in model.json has only standard or scale and bias keys"
    }];
}

- (NSError*)arrayInputQuantizeMustHaveCorectKeysError {
    return [NSError errorWithDomain:@"doc.ai.tensorio" code:314 userInfo:@{
        NSLocalizedDescriptionKey: [NSString stringWithFormat:@"An inputs.quantize field is missing valid keys"],
        NSLocalizedRecoverySuggestionErrorKey: @"Ensure that every inputs.quantize field in model.json has only standard or scale and bias keys"
    }];
}

- (NSError*)arrayInputQuantizeMustHaveStandardOrScaleAndBiasKeysError {
    return [NSError errorWithDomain:@"doc.ai.tensorio" code:315 userInfo:@{
        NSLocalizedDescriptionKey: [NSString stringWithFormat:@"An inputs.quantize field is missing the valid keys"],
        NSLocalizedRecoverySuggestionErrorKey: @"Ensure that every inputs.quantize field in model.json has only standard or scale and bias keys"
    }];
}

- (NSError*)arrayInputStandardQuantizeMustConformError {
    return [NSError errorWithDomain:@"doc.ai.tensorio" code:316 userInfo:@{
        NSLocalizedDescriptionKey: [NSString stringWithFormat:@"An inputs.quantize.standard field has an invalid value"],
        NSLocalizedRecoverySuggestionErrorKey: @"Ensure that every inputs.quantize.standard field in model.json is either \"[0,1]\" or \"[-1,1]\""
    }];
}

- (NSError*)arrayInputQuantizeScaleAndBiasMustBeNumericError {
    return [NSError errorWithDomain:@"doc.ai.tensorio" code:317 userInfo:@{
        NSLocalizedDescriptionKey: [NSString stringWithFormat:@"An inputs.quantize.scale or inputs.quantize.bias field has an invalid value"],
        NSLocalizedRecoverySuggestionErrorKey: @"Ensure that every inputs.quantize.scale and inputs.quantize.bias fields in model.json is a numeric value"
    }];
}

- (NSError*)arrayInputQuantizeMustHaveBothScaleAndBiasKeysError {
    return [NSError errorWithDomain:@"doc.ai.tensorio" code:317 userInfo:@{
        NSLocalizedDescriptionKey: [NSString stringWithFormat:@"An inputs.quantize field has either standard or bias keys but not both"],
        NSLocalizedRecoverySuggestionErrorKey: @"Ensure that every inputs.quantize field in model.json has either standard or scale and bias keys"
    }];
}

- (NSError*)imageInputHasUnusedKeysError {
    return [NSError errorWithDomain:@"doc.ai.tensorio" code:318 userInfo:@{
        NSLocalizedDescriptionKey: [NSString stringWithFormat:@"An inputs image type field in the model.json file has unused keys"],
        NSLocalizedRecoverySuggestionErrorKey: @"Ensure that every inputs image type field in model.json has only name, type, shape, and normalize keys"
    }];
}

- (NSError*)imageInputNormalizeIsEmptyError {
    return [NSError errorWithDomain:@"doc.ai.tensorio" code:319 userInfo:@{
        NSLocalizedDescriptionKey: [NSString stringWithFormat:@"An inputs.normalize field in the model.json file is empty"],
        NSLocalizedRecoverySuggestionErrorKey: @"Ensure that every inputs.normalize field in model.json has a standard or scale and bias keys"
    }];
}

- (NSError*)imageInputNormalizeHasUnusedKeysError {
    return [NSError errorWithDomain:@"doc.ai.tensorio" code:320 userInfo:@{
        NSLocalizedDescriptionKey: [NSString stringWithFormat:@"An inputs.normalize image type field in the model.json file has unused keys"],
        NSLocalizedRecoverySuggestionErrorKey: @"Ensure that every inputs.normalize image type field in model.json has only name, type, shape, and normalize keys"
    }];
}

- (NSError*)imageInputNormalizeMustHaveCorectKeysError {
    return [NSError errorWithDomain:@"doc.ai.tensorio" code:321 userInfo:@{
        NSLocalizedDescriptionKey: [NSString stringWithFormat:@"An inputs.normalize field is missing valid keys"],
        NSLocalizedRecoverySuggestionErrorKey: @"Ensure that every inputs.normalize field in model.json has only standard or scale and bias keys"
    }];
}

- (NSError*)imageInputNormalizeMustHaveStandardOrScaleAndBiasKeysError {
    return [NSError errorWithDomain:@"doc.ai.tensorio" code:322 userInfo:@{
        NSLocalizedDescriptionKey: [NSString stringWithFormat:@"An inputs.normalize field is missing the valid keys"],
        NSLocalizedRecoverySuggestionErrorKey: @"Ensure that every inputs.normalize field in model.json has only standard or scale and bias keys"
    }];
}

- (NSError*)imageInputStandardNormalizeMustConformError {
    return [NSError errorWithDomain:@"doc.ai.tensorio" code:323 userInfo:@{
        NSLocalizedDescriptionKey: [NSString stringWithFormat:@"An inputs.normalize.standard field has an invalid value"],
        NSLocalizedRecoverySuggestionErrorKey: @"Ensure that every inputs.normalize.standard field in model.json is either \"[0,1]\" or \"[-1,1]\""
    }];
}

- (NSError*)imageInputNormalizeMustHaveBothScaleAndBiasKeysError {
    return [NSError errorWithDomain:@"doc.ai.tensorio" code:324 userInfo:@{
        NSLocalizedDescriptionKey: [NSString stringWithFormat:@"An inputs.normalize field has either standard or bias keys but not both"],
        NSLocalizedRecoverySuggestionErrorKey: @"Ensure that every inputs.normalize field in model.json has either standard or scale and bias keys"
    }];
}

- (NSError*)imageInputNormalizeScaleMustBeNumericError {
    return [NSError errorWithDomain:@"doc.ai.tensorio" code:325 userInfo:@{
        NSLocalizedDescriptionKey: [NSString stringWithFormat:@"An inputs.quantize.scale field has an invalid value"],
        NSLocalizedRecoverySuggestionErrorKey: @"Ensure that every inputs.quantize.scale field in model.json is a numeric value"
    }];
}

- (NSError*)imageInputNormalizeBiasMustBeDictionaryError {
    return [NSError errorWithDomain:@"doc.ai.tensorio" code:326 userInfo:@{
        NSLocalizedDescriptionKey: [NSString stringWithFormat:@"An inputs.quantize.bias field has an invalid value"],
        NSLocalizedRecoverySuggestionErrorKey: @"Ensure that every inputs.quantize.bias field in model.json is a dictionary with r, g, and b numeric values"
    }];
}

- (NSError*)imageInputNormalizeBiasHasUnusedKeysError {
    return [NSError errorWithDomain:@"doc.ai.tensorio" code:327 userInfo:@{
        NSLocalizedDescriptionKey: [NSString stringWithFormat:@"An inputs.quantize.bias field has unused keys"],
        NSLocalizedRecoverySuggestionErrorKey: @"Ensure that every inputs.quantize.bias field in model.json is a dictionary with r, g, and b numeric values"
    }];
}

- (NSError*)imageInputNormalizeBiasIsEmptyError {
    return [NSError errorWithDomain:@"doc.ai.tensorio" code:328 userInfo:@{
        NSLocalizedDescriptionKey: [NSString stringWithFormat:@"An inputs.quantize.bias field is empty"],
        NSLocalizedRecoverySuggestionErrorKey: @"Ensure that every inputs.quantize.bias field in model.json is a dictionary with r, g, and b numeric values"
    }];
}

- (NSError*)imageInputNormalizeBiasMustHaveCorectKeysError {
    return [NSError errorWithDomain:@"doc.ai.tensorio" code:329 userInfo:@{
        NSLocalizedDescriptionKey: [NSString stringWithFormat:@"An inputs.quantize.bias field has incorrect values"],
        NSLocalizedRecoverySuggestionErrorKey: @"Ensure that every inputs.quantize.bias field in model.json is a dictionary with r, g, and b numeric values"
    }];
}

- (NSError*)imageInputNormalizeBiasMustBeNumericValuesError {
    return [NSError errorWithDomain:@"doc.ai.tensorio" code:329 userInfo:@{
        NSLocalizedDescriptionKey: [NSString stringWithFormat:@"An inputs.quantize.bias field has incorrect values"],
        NSLocalizedRecoverySuggestionErrorKey: @"Ensure that every inputs.quantize.bias field in model.json is a dictionary with r, g, and b numeric values"
    }];
}

- (NSError*)imageInputFormatNotValidError {
    return [NSError errorWithDomain:@"doc.ai.tensorio" code:330 userInfo:@{
        NSLocalizedDescriptionKey: [NSString stringWithFormat:@"An image type inputs.format field is missing or has an invalid value"],
        NSLocalizedRecoverySuggestionErrorKey: @"Ensure that every image type inputs.format field in model.json is either \"RGB\" or \"BRG\""
    }];
}

// MARK: - Output Errors

- (NSError*)zeroOutputsError {
    return [NSError errorWithDomain:@"doc.ai.tensorio" code:350 userInfo:@{
        NSLocalizedDescriptionKey: [NSString stringWithFormat:@"The model.json file has zero outputs"],
        NSLocalizedRecoverySuggestionErrorKey: @"Ensure that model.json contains at least one output and that it is a valid value"
    }];
}

- (NSError*)missingOutputPropertyError:(NSString*)property {
    return [NSError errorWithDomain:@"doc.ai.tensorio" code:351 userInfo:@{
        NSLocalizedDescriptionKey: [NSString stringWithFormat:@"An outputs fields in the model.json file is missing the %@ property", property],
        NSLocalizedRecoverySuggestionErrorKey: @"Ensure that every outputs field in model.json contains the %@ property and that it is a valid value"
    }];
}

- (NSError*)outputShapeMustBeArrayError {
    return [NSError errorWithDomain:@"doc.ai.tensorio" code:352 userInfo:@{
        NSLocalizedDescriptionKey: [NSString stringWithFormat:@"An outputs.shape field in the model.json file is not an array"],
        NSLocalizedRecoverySuggestionErrorKey: @"Ensure that every outputs.shape field in model.json is an array with one or more numeric values"
    }];
}

- (NSError*)outputShapeMustHaveEntriesError {
    return [NSError errorWithDomain:@"doc.ai.tensorio" code:353 userInfo:@{
        NSLocalizedDescriptionKey: [NSString stringWithFormat:@"An outputs.shape field in the model.json file is empty"],
        NSLocalizedRecoverySuggestionErrorKey: @"Ensure that every outputs.shape field in model.json is an array with one or more numeric values"
    }];
}

- (NSError*)outputShapeMustHaveNumericEntriesError {
    return [NSError errorWithDomain:@"doc.ai.tensorio" code:354 userInfo:@{
        NSLocalizedDescriptionKey: [NSString stringWithFormat:@"An outputs.shape field in the model.json file contains non-numeric values"],
        NSLocalizedRecoverySuggestionErrorKey: @"Ensure that every outputs.shape field in model.json is an array with only numeric values"
    }];
}

- (NSError*)outputTypeMustConformError {
    return [NSError errorWithDomain:@"doc.ai.tensorio" code:355 userInfo:@{
        NSLocalizedDescriptionKey: [NSString stringWithFormat:@"An outputs.type field in the model.json file is invalid"],
        NSLocalizedRecoverySuggestionErrorKey: @"Ensure that every outputs.type field in model.json is either \"array\" or \"image\""
    }];
}

- (NSError*)arrayOutputHasUnusedKeysError {
    return [NSError errorWithDomain:@"doc.ai.tensorio" code:356 userInfo:@{
        NSLocalizedDescriptionKey: [NSString stringWithFormat:@"An outputs array type field in the model.json file has unused keys"],
        NSLocalizedRecoverySuggestionErrorKey: @"Ensure that every outputs array type field in model.json has only name, type, shape, and a labels key with an optional dequantize key"
    }];
}

- (NSError*)arrayOutputDequantizeIsEmptyError {
    return [NSError errorWithDomain:@"doc.ai.tensorio" code:357 userInfo:@{
        NSLocalizedDescriptionKey: [NSString stringWithFormat:@"An outputs.quantize field in the model.json file is empty"],
        NSLocalizedRecoverySuggestionErrorKey: @"Ensure that every outputs.quantize field in model.json has a standard or scale and bias keys"
    }];
}

- (NSError*)arrayOutputDequantizeHasUnusedKeysError {
    return [NSError errorWithDomain:@"doc.ai.tensorio" code:358 userInfo:@{
        NSLocalizedDescriptionKey: [NSString stringWithFormat:@"An outputs.quantize field in the model.json file has unused keys"],
        NSLocalizedRecoverySuggestionErrorKey: @"Ensure that every outputs.quantize field in model.json has only standard or scale and bias keys"
    }];
}

- (NSError*)arrayOutputDequantizeMustHaveCorectKeysError {
    return [NSError errorWithDomain:@"doc.ai.tensorio" code:359 userInfo:@{
        NSLocalizedDescriptionKey: [NSString stringWithFormat:@"An outputs.quantize field is missing valid keys"],
        NSLocalizedRecoverySuggestionErrorKey: @"Ensure that every outputs.quantize field in model.json has only standard or scale and bias keys"
    }];
}

- (NSError*)arrayOutputDequantizeMustHaveStandardOrScaleAndBiasKeysError {
    return [NSError errorWithDomain:@"doc.ai.tensorio" code:360 userInfo:@{
        NSLocalizedDescriptionKey: [NSString stringWithFormat:@"An outputs.quantize field is missing the valid keys"],
        NSLocalizedRecoverySuggestionErrorKey: @"Ensure that every outputs.quantize field in model.json has only standard or scale and bias keys"
    }];
}

- (NSError*)arrayOutputStandardDequantizeMustConformError {
    return [NSError errorWithDomain:@"doc.ai.tensorio" code:361 userInfo:@{
        NSLocalizedDescriptionKey: [NSString stringWithFormat:@"An outputs.quantize.standard field has an invalid value"],
        NSLocalizedRecoverySuggestionErrorKey: @"Ensure that every outputs.quantize.standard field in model.json is either \"[0,1]\" or \"[-1,1]\""
    }];
}

- (NSError*)arrayOutputDequantizeScaleAndBiasMustBeNumericError {
    return [NSError errorWithDomain:@"doc.ai.tensorio" code:362 userInfo:@{
        NSLocalizedDescriptionKey: [NSString stringWithFormat:@"An outputs.quantize.scale or outputs.quantize.bias field has an invalid value"],
        NSLocalizedRecoverySuggestionErrorKey: @"Ensure that every outputs.quantize.scale and outputs.quantize.bias fields in model.json is a numeric value"
    }];
}

- (NSError*)arrayOutputDequantizeMustHaveBothScaleAndBiasKeysError {
    return [NSError errorWithDomain:@"doc.ai.tensorio" code:363 userInfo:@{
        NSLocalizedDescriptionKey: [NSString stringWithFormat:@"An outputs.quantize field has either standard or bias keys but not both"],
        NSLocalizedRecoverySuggestionErrorKey: @"Ensure that every outputs.quantize field in model.json has either standard or scale and bias keys"
    }];
}

- (NSError*)imageOutputHasUnusedKeysError {
    return [NSError errorWithDomain:@"doc.ai.tensorio" code:364 userInfo:@{
        NSLocalizedDescriptionKey: [NSString stringWithFormat:@"An outputs image type field in the model.json file has unused keys"],
        NSLocalizedRecoverySuggestionErrorKey: @"Ensure that every outputs image type field in model.json has only name, type, shape, and normalize keys"
    }];
}

- (NSError*)imageOutputDenormalizeIsEmptyError {
    return [NSError errorWithDomain:@"doc.ai.tensorio" code:365 userInfo:@{
        NSLocalizedDescriptionKey: [NSString stringWithFormat:@"An outputs.normalize field in the model.json file is empty"],
        NSLocalizedRecoverySuggestionErrorKey: @"Ensure that every outputs.normalize field in model.json has a standard or scale and bias keys"
    }];
}

- (NSError*)imageOutputDenormalizeHasUnusedKeysError {
    return [NSError errorWithDomain:@"doc.ai.tensorio" code:366 userInfo:@{
        NSLocalizedDescriptionKey: [NSString stringWithFormat:@"An outputs.normalize image type field in the model.json file has unused keys"],
        NSLocalizedRecoverySuggestionErrorKey: @"Ensure that every outputs.normalize image type field in model.json has only name, type, shape, and normalize keys"
    }];
}

- (NSError*)imageOutputDenormalizeMustHaveCorectKeysError {
    return [NSError errorWithDomain:@"doc.ai.tensorio" code:367 userInfo:@{
        NSLocalizedDescriptionKey: [NSString stringWithFormat:@"An outputs.normalize field is missing valid keys"],
        NSLocalizedRecoverySuggestionErrorKey: @"Ensure that every outputs.normalize field in model.json has only standard or scale and bias keys"
    }];
}

- (NSError*)imageOutputDenormalizeMustHaveStandardOrScaleAndBiasKeysError {
    return [NSError errorWithDomain:@"doc.ai.tensorio" code:368 userInfo:@{
        NSLocalizedDescriptionKey: [NSString stringWithFormat:@"An outputs.normalize field is missing the valid keys"],
        NSLocalizedRecoverySuggestionErrorKey: @"Ensure that every outputs.normalize field in model.json has only standard or scale and bias keys"
    }];
}

- (NSError*)imageOutputStandardDenormalizeMustConformError {
    return [NSError errorWithDomain:@"doc.ai.tensorio" code:369 userInfo:@{
        NSLocalizedDescriptionKey: [NSString stringWithFormat:@"An outputs.normalize.standard field has an invalid value"],
        NSLocalizedRecoverySuggestionErrorKey: @"Ensure that every outputs.normalize.standard field in model.json is either \"[0,1]\" or \"[-1,1]\""
    }];
}

- (NSError*)imageOutputDenormalizeMustHaveBothScaleAndBiasKeysError {
    return [NSError errorWithDomain:@"doc.ai.tensorio" code:370 userInfo:@{
        NSLocalizedDescriptionKey: [NSString stringWithFormat:@"An outputs.normalize field has either standard or bias keys but not both"],
        NSLocalizedRecoverySuggestionErrorKey: @"Ensure that every outputs.normalize field in model.json has either standard or scale and bias keys"
    }];
}

- (NSError*)imageOutputDenormalizeScaleMustBeNumericError {
    return [NSError errorWithDomain:@"doc.ai.tensorio" code:371 userInfo:@{
        NSLocalizedDescriptionKey: [NSString stringWithFormat:@"An outputs.quantize.scale field has an invalid value"],
        NSLocalizedRecoverySuggestionErrorKey: @"Ensure that every outputs.quantize.scale field in model.json is a numeric value"
    }];
}

- (NSError*)imageOutputDenormalizeBiasMustBeDictionaryError {
    return [NSError errorWithDomain:@"doc.ai.tensorio" code:372 userInfo:@{
        NSLocalizedDescriptionKey: [NSString stringWithFormat:@"An outputs.quantize.bias field has an invalid value"],
        NSLocalizedRecoverySuggestionErrorKey: @"Ensure that every outputs.quantize.bias field in model.json is a dictionary with r, g, and b numeric values"
    }];
}

- (NSError*)imageOutputDenormalizeBiasHasUnusedKeysError {
    return [NSError errorWithDomain:@"doc.ai.tensorio" code:373 userInfo:@{
        NSLocalizedDescriptionKey: [NSString stringWithFormat:@"An outputs.quantize.bias field has unused keys"],
        NSLocalizedRecoverySuggestionErrorKey: @"Ensure that every outputs.quantize.bias field in model.json is a dictionary with r, g, and b numeric values"
    }];
}

- (NSError*)imageOutputDenormalizeBiasIsEmptyError {
    return [NSError errorWithDomain:@"doc.ai.tensorio" code:374 userInfo:@{
        NSLocalizedDescriptionKey: [NSString stringWithFormat:@"An outputs.quantize.bias field is empty"],
        NSLocalizedRecoverySuggestionErrorKey: @"Ensure that every outputs.quantize.bias field in model.json is a dictionary with r, g, and b numeric values"
    }];
}

- (NSError*)imageOutputDenormalizeBiasMustHaveCorectKeysError {
    return [NSError errorWithDomain:@"doc.ai.tensorio" code:375 userInfo:@{
        NSLocalizedDescriptionKey: [NSString stringWithFormat:@"An outputs.quantize.bias field has incorrect values"],
        NSLocalizedRecoverySuggestionErrorKey: @"Ensure that every outputs.quantize.bias field in model.json is a dictionary with r, g, and b numeric values"
    }];
}

- (NSError*)imageOutputDenormalizeBiasMustBeNumericValuesError {
    return [NSError errorWithDomain:@"doc.ai.tensorio" code:376 userInfo:@{
        NSLocalizedDescriptionKey: [NSString stringWithFormat:@"An outputs.quantize.bias field has incorrect values"],
        NSLocalizedRecoverySuggestionErrorKey: @"Ensure that every outputs.quantize.bias field in model.json is a dictionary with r, g, and b numeric values"
    }];
}

- (NSError*)imageOutputFormatNotValidError {
    return [NSError errorWithDomain:@"doc.ai.tensorio" code:377 userInfo:@{
        NSLocalizedDescriptionKey: [NSString stringWithFormat:@"An image type outputs.format field is missing or has an invalid value"],
        NSLocalizedRecoverySuggestionErrorKey: @"Ensure that every image type outputs.format field in model.json is either \"RGB\" or \"BRG\""
    }];
}

// MARK: - Model Errors

- (NSError*)modelHasUnusedKeysError {
    return [NSError errorWithDomain:@"doc.ai.tensorio" code:390 userInfo:@{
        NSLocalizedDescriptionKey: [NSString stringWithFormat:@"The model field has unused keys"],
        NSLocalizedRecoverySuggestionErrorKey: @"Ensure that the model field in model.json has a file and quantized entry and optionally a class and type entry"
    }];
}

- (NSError*)modelMissingPropertyError:(NSString*)property {
    return [NSError errorWithDomain:@"doc.ai.tensorio" code:391 userInfo:@{
        NSLocalizedDescriptionKey: [NSString stringWithFormat:@"The model field is missing the %@ property", property],
        NSLocalizedRecoverySuggestionErrorKey: @"Ensure that the model field in model.json contains the %@ property and that it is a valid value"
    }];
}

// MARK: - Assets Errors

- (NSError*)modelFileDoesNotExistsError:(NSString*)filename {
    return [NSError errorWithDomain:@"doc.ai.tensorio" code:392 userInfo:@{
        NSLocalizedDescriptionKey: [NSString stringWithFormat:@"The model.file \"%@\" could not be found", filename],
        NSLocalizedRecoverySuggestionErrorKey: @"Ensure that the model.file value is the name of a file in the root bundle directory"
    }];
}

- (NSError*)labelsFileDoesNotExistError:(NSString*)filename {
    return [NSError errorWithDomain:@"doc.ai.tensorio" code:393 userInfo:@{
        NSLocalizedDescriptionKey: [NSString stringWithFormat:@"The outputs.label file \"%@\" could not be found", filename],
        NSLocalizedRecoverySuggestionErrorKey: @"Ensure that the outputs.label file is the name of a file in the assets directory"
    }];
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
        *error = [self invalidFilepathError];
        return NO;
    }
    
    // Validate bundle structure
    
    if ( ![self.path.pathExtension isEqualToString:kTFModelBundleExtension] ) {
        *error = [self invalidExtensionError];
        return NO;
    }
    
    if ( ![fm fileExistsAtPath:[self JSONPath] isDirectory:&isDirectory] || isDirectory ) {
        *error = [self noModelJSONFileError];
        return NO;
    }
    
    // Validate if JSON can be read
    
    NSDictionary *JSON = [self loadJSON];
    
    if ( JSON == nil ) {
        *error = [self malformedJSONError];
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
    
    if ( ![self validateCustomValidator:JSON validator:customValidator error:error] ) {
        return NO;
    }
    
    return YES;
}

- (BOOL)validateBundleProperties:(NSDictionary*)JSON error:(NSError**)error {
    
    // Validate presence of basic bundle properties
    
    if ( JSON[@"name"] == nil || ![JSON[@"name"] isKindOfClass:[NSString class]] ) {
        *error = [self missingPropertyError:@"name"];
        return NO;
    }
    
    if ( JSON[@"details"] == nil || ![JSON[@"details"] isKindOfClass:[NSString class]] ) {
        *error = [self missingPropertyError:@"details"];
        return NO;
    }
    
    if ( JSON[@"id"] == nil || ![JSON[@"id"] isKindOfClass:[NSString class]] ) {
        *error = [self missingPropertyError:@"id"];
        return NO;
    }
    
    if ( JSON[@"version"] == nil || ![JSON[@"version"] isKindOfClass:[NSString class]] ) {
        *error = [self missingPropertyError:@"version"];
        return NO;
    }
    
    if ( JSON[@"author"] == nil || ![JSON[@"author"] isKindOfClass:[NSString class]] ) {
        *error = [self missingPropertyError:@"author"];
        return NO;
    }
    
    if ( JSON[@"license"] == nil || ![JSON[@"license"] isKindOfClass:[NSString class]] ) {
        *error = [self missingPropertyError:@"license"];
        return NO;
    }
    
    if ( JSON[@"model"] == nil || ![JSON[@"model"] isKindOfClass:[NSDictionary class]] ) {
        *error = [self missingPropertyError:@"model"];
        return NO;
    }
    
    if ( JSON[@"inputs"] == nil || ![JSON[@"inputs"] isKindOfClass:[NSArray class]] ) {
        *error = [self missingPropertyError:@"inputs"];
        return NO;
    }
    
    if ( JSON[@"outputs"] == nil || ![JSON[@"outputs"] isKindOfClass:[NSArray class]] ) {
        *error = [self missingPropertyError:@"outputs"];
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
        *error = [self modelHasUnusedKeysError];
        return NO;
    }
    
    if ( ![allKeys containsObject:@"file"] || ![JSON[@"file"] isKindOfClass:[NSString class]] || [JSON[@"file"] length] == 0 ) {
        *error = [self modelMissingPropertyError:@"file"];
        return NO;
    }
    
    if ( ![allKeys containsObject:@"quantized"] || ![JSON[@"quantized"] isKindOfClass:[NSNumber class]] ) {
        *error = [self modelMissingPropertyError:@"quantized"];
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
        *error = [self modelFileDoesNotExistsError:modelFilename];
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
            *error = [self labelsFileDoesNotExistError:labelsFilename];
            return NO;
        }
    }
    
    return YES;
}

// Ooof. Would love a little DSL that let's me specify all this

- (BOOL)validateInputs:(NSArray*)JSON error:(NSError**)error {
    
    if ( JSON.count == 0 ) {
        *error = [self zeroInputsError];
        return NO;
    }
    
    for ( NSDictionary *input in JSON ) {
        
        // basic properties
        
        if ( input[@"name"] == nil ) {
            *error = [self missingInputPropertyError:@"name"];
            return NO;
        }
        
        if ( input[@"shape"] == nil ) {
            *error = [self missingInputPropertyError:@"shape"];
            return NO;
        }
        
        if ( input[@"type"] == nil ) {
            *error = [self missingInputPropertyError:@"type"];
            return NO;
        }
        
        // shape validation
        
        if ( ![input[@"shape"] isKindOfClass:[NSArray class]] ) {
            *error = [self inputShapeMustBeArrayError];
            return NO;
        }
        
        if ( ((NSArray*)input[@"shape"]).count == 0 ) {
            *error = [self inputShapeMustHaveEntriesError];
            return NO;
        }
        
        for ( id el in (NSArray*)input[@"shape"] ) {
            if ( ![el isKindOfClass:[NSNumber class]] ) {
                *error = [self inputShapeMustHaveNumericEntriesError];
                return NO;
            }
        }
        
        // type validation
        
        if ( ![input[@"type"] isKindOfClass:[NSString class]] || !([input[@"type"] isEqualToString:@"array"] || [input[@"type"] isEqualToString:@"image"]) ) {
            *error = [self inputTypeMustConformError];
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
                *error = [self arrayInputHasUnusedKeysError];
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
                        *error = [self arrayInputQuantizeHasUnusedKeysError];
                        return NO;
                    }
                }
                
                NSSet *keys = [NSSet setWithArray:[input[@"quantize"] allKeys]];
                
                if ( keys.count == 0 ) {
                    *error = [self arrayInputQuantizeIsEmptyError];
                    return NO;
                }
                
                if ( ![keys containsObject:@"standard"] && ![keys containsObject:@"scale"] && ![keys containsObject:@"bias"] ) {
                    *error = [self arrayInputQuantizeMustHaveCorectKeysError];
                    return NO;
                }
                
                // standard validation
                
                if ( [keys containsObject:@"standard"] && ([keys containsObject:@"scale"] || [keys containsObject:@"bias"]) ) {
                    *error = [self arrayInputQuantizeMustHaveStandardOrScaleAndBiasKeysError];
                    return NO;
                }
                
                if ( [keys containsObject:@"standard"] ) {
                    NSArray *values = @[
                        @"[-1,1]",
                        @"[0,1]"
                    ];
                    
                    if ( ![input[@"quantize"][@"standard"] isKindOfClass:[NSString class]] || ![values containsObject:input[@"quantize"][@"standard"]] ) {
                        *error = [self arrayInputStandardQuantizeMustConformError];
                        return NO;
                    }
                }
                
                // scale and bias validation
                
                if ( ([keys containsObject:@"scale"] && ![keys containsObject:@"bias"]) || ([keys containsObject:@"bias"] && ![keys containsObject:@"scale"]) ) {
                    *error = [self arrayInputQuantizeMustHaveBothScaleAndBiasKeysError];
                    return NO;
                }
                
                if ( [keys containsObject:@"scale"] && ![input[@"quantize"][@"scale"] isKindOfClass:[NSNumber class]] ) {
                    *error = [self arrayInputQuantizeScaleAndBiasMustBeNumericError];
                    return NO;
                }
                
                if ( [keys containsObject:@"bias"] && ![input[@"quantize"][@"bias"] isKindOfClass:[NSNumber class]] ) {
                    *error = [self arrayInputQuantizeScaleAndBiasMustBeNumericError];
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
                *error = [self imageInputHasUnusedKeysError];
                return NO;
            }
            
            // format validation
            
            NSArray *formats = @[
                @"RGB",
                @"BGR"
            ];
            
            if ( input[@"format"] == nil  || ![input[@"format"] isKindOfClass:[NSString class]] || ![formats containsObject:input[@"format"]] ) {
                *error = [self imageInputFormatNotValidError];
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
                        *error = [self imageInputNormalizeHasUnusedKeysError];
                        return NO;
                    }
                }
                
                NSSet *keys = [NSSet setWithArray:[input[@"normalize"] allKeys]];
                
                if ( keys.count == 0 ) {
                    *error = [self imageInputNormalizeIsEmptyError];
                    return NO;
                }
                
                if ( ![keys containsObject:@"standard"] && ![keys containsObject:@"scale"] && ![keys containsObject:@"bias"] ) {
                    *error = [self imageInputNormalizeMustHaveCorectKeysError];
                    return NO;
                }
                
                // standard validation
                
                if ( [keys containsObject:@"standard"] && ([keys containsObject:@"scale"] || [keys containsObject:@"bias"]) ) {
                    *error = [self imageInputNormalizeMustHaveStandardOrScaleAndBiasKeysError];
                    return NO;
                }
                
                if ( [keys containsObject:@"standard"] ) {
                    NSArray *values = @[
                        @"[-1,1]",
                        @"[0,1]"
                    ];
                    
                    if ( ![input[@"normalize"][@"standard"] isKindOfClass:[NSString class]] || ![values containsObject:input[@"normalize"][@"standard"]] ) {
                        *error = [self imageInputStandardNormalizeMustConformError];
                        return NO;
                    }
                }
                
                // scale and bias validation
                
                if ( ([keys containsObject:@"scale"] && ![keys containsObject:@"bias"]) || ([keys containsObject:@"bias"] && ![keys containsObject:@"scale"]) ) {
                    *error = [self imageInputNormalizeMustHaveBothScaleAndBiasKeysError];
                    return NO;
                }
                
                if ( [keys containsObject:@"scale"] && ![input[@"normalize"][@"scale"] isKindOfClass:[NSNumber class]] ) {
                    *error = [self imageInputNormalizeScaleMustBeNumericError];
                    return NO;
                }
                
                if ( [keys containsObject:@"bias"] ) {
                    
                    if ( ![input[@"normalize"][@"bias"] isKindOfClass:[NSDictionary class]] ) {
                        *error = [self imageInputNormalizeBiasMustBeDictionaryError];
                        return NO;
                    }
                    
                    {
                        NSMutableSet *biasKeys = [NSMutableSet setWithArray:[input[@"normalize"][@"bias"] allKeys]];
                        [biasKeys removeObject:@"r"];
                        [biasKeys removeObject:@"g"];
                        [biasKeys removeObject:@"b"];
                        
                        if ( biasKeys.count != 0 ) {
                            *error = [self imageInputNormalizeBiasHasUnusedKeysError];
                            return NO;
                        }
                    }
                    
                    NSSet *biasKeys = [NSSet setWithArray:[input[@"normalize"][@"bias"] allKeys]];
                
                    if ( biasKeys.count == 0 ) {
                        *error = [self imageInputNormalizeBiasIsEmptyError];
                        return NO;
                    }
                    
                    if ( ![biasKeys containsObject:@"r"] || ![biasKeys containsObject:@"g"] || ![biasKeys containsObject:@"g"] ) {
                        *error = [self imageInputNormalizeBiasMustHaveCorectKeysError];
                        return NO;
                    }
                    
                    if (   ![input[@"normalize"][@"bias"][@"r"] isKindOfClass:[NSNumber class]]
                        || ![input[@"normalize"][@"bias"][@"g"] isKindOfClass:[NSNumber class]]
                        || ![input[@"normalize"][@"bias"][@"g"] isKindOfClass:[NSNumber class]] ) {
                        *error = [self imageInputNormalizeBiasMustBeNumericValuesError];
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
        *error = [self zeroInputsError];
        return NO;
    }
    
    for ( NSDictionary *output in JSON ) {
        
        // basic properties
        
        if ( output[@"name"] == nil ) {
            *error = [self missingOutputPropertyError:@"name"];
            return NO;
        }
        
        if ( output[@"shape"] == nil ) {
            *error = [self missingOutputPropertyError:@"shape"];
            return NO;
        }
        
        if ( output[@"type"] == nil ) {
            *error = [self missingOutputPropertyError:@"type"];
            return NO;
        }
        
        // shape validation
        
        if ( ![output[@"shape"] isKindOfClass:[NSArray class]] ) {
            *error = [self outputShapeMustBeArrayError];
            return NO;
        }
        
        if ( ((NSArray*)output[@"shape"]).count == 0 ) {
            *error = [self outputShapeMustHaveEntriesError];
            return NO;
        }
        
        for ( id el in (NSArray*)output[@"shape"] ) {
            if ( ![el isKindOfClass:[NSNumber class]] ) {
                *error = [self outputShapeMustHaveNumericEntriesError];
                return NO;
            }
        }
        
        // type validation
        
        if ( ![output[@"type"] isKindOfClass:[NSString class]] || !([output[@"type"] isEqualToString:@"array"] || [output[@"type"] isEqualToString:@"image"]) ) {
            *error = [self outputTypeMustConformError];
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
                *error = [self arrayOutputHasUnusedKeysError];
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
                        *error = [self arrayOutputDequantizeHasUnusedKeysError];
                        return NO;
                    }
                }
                
                NSSet *keys = [NSSet setWithArray:[output[@"dequantize"] allKeys]];
                
                if ( keys.count == 0 ) {
                    *error = [self arrayOutputDequantizeIsEmptyError];
                    return NO;
                }
                
                if ( ![keys containsObject:@"standard"] && ![keys containsObject:@"scale"] && ![keys containsObject:@"bias"] ) {
                    *error = [self arrayOutputDequantizeMustHaveCorectKeysError];
                    return NO;
                }
                
                // standard validation
                
                if ( [keys containsObject:@"standard"] && ([keys containsObject:@"scale"] || [keys containsObject:@"bias"]) ) {
                    *error = [self arrayOutputDequantizeMustHaveStandardOrScaleAndBiasKeysError];
                    return NO;
                }
                
                if ( [keys containsObject:@"standard"] ) {
                    NSArray *values = @[
                        @"[-1,1]",
                        @"[0,1]"
                    ];
                    
                    if ( ![output[@"dequantize"][@"standard"] isKindOfClass:[NSString class]] || ![values containsObject:output[@"dequantize"][@"standard"]] ) {
                        *error = [self arrayOutputStandardDequantizeMustConformError];
                        return NO;
                    }
                }
                
                // scale and bias validation
                
                if ( ([keys containsObject:@"scale"] && ![keys containsObject:@"bias"]) || ([keys containsObject:@"bias"] && ![keys containsObject:@"scale"]) ) {
                    *error = [self arrayOutputDequantizeMustHaveBothScaleAndBiasKeysError];
                    return NO;
                }
                
                if ( [keys containsObject:@"scale"] && ![output[@"dequantize"][@"scale"] isKindOfClass:[NSNumber class]] ) {
                    *error = [self arrayOutputDequantizeScaleAndBiasMustBeNumericError];
                    return NO;
                }
                
                if ( [keys containsObject:@"bias"] && ![output[@"dequantize"][@"bias"] isKindOfClass:[NSNumber class]] ) {
                    *error = [self arrayOutputDequantizeScaleAndBiasMustBeNumericError];
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
                *error = [self imageOutputHasUnusedKeysError];
                return NO;
            }
            
            // format validation
            
            NSArray *formats = @[
                @"RGB",
                @"BGR"
            ];
            
            if ( output[@"format"] == nil  || ![output[@"format"] isKindOfClass:[NSString class]] || ![formats containsObject:output[@"format"]] ) {
                *error = [self imageOutputFormatNotValidError];
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
                        *error = [self imageOutputDenormalizeHasUnusedKeysError];
                        return NO;
                    }
                }
                
                NSSet *keys = [NSSet setWithArray:[output[@"denormalize"] allKeys]];
                
                if ( keys.count == 0 ) {
                    *error = [self imageOutputDenormalizeIsEmptyError];
                    return NO;
                }
                
                if ( ![keys containsObject:@"standard"] && ![keys containsObject:@"scale"] && ![keys containsObject:@"bias"] ) {
                    *error = [self imageOutputDenormalizeMustHaveCorectKeysError];
                    return NO;
                }
                
                // standard validation
                
                if ( [keys containsObject:@"standard"] && ([keys containsObject:@"scale"] || [keys containsObject:@"bias"]) ) {
                    *error = [self imageOutputDenormalizeMustHaveStandardOrScaleAndBiasKeysError];
                    return NO;
                }
                
                if ( [keys containsObject:@"standard"] ) {
                    NSArray *values = @[
                        @"[-1,1]",
                        @"[0,1]"
                    ];
                    
                    if ( ![output[@"denormalize"][@"standard"] isKindOfClass:[NSString class]] || ![values containsObject:output[@"denormalize"][@"standard"]] ) {
                        *error = [self imageOutputStandardDenormalizeMustConformError];
                        return NO;
                    }
                }
                
                // scale and bias validation
                
                if ( ([keys containsObject:@"scale"] && ![keys containsObject:@"bias"]) || ([keys containsObject:@"bias"] && ![keys containsObject:@"scale"]) ) {
                    *error = [self imageOutputDenormalizeMustHaveBothScaleAndBiasKeysError];
                    return NO;
                }
                
                if ( [keys containsObject:@"scale"] && ![output[@"denormalize"][@"scale"] isKindOfClass:[NSNumber class]] ) {
                    *error = [self imageOutputDenormalizeScaleMustBeNumericError];
                    return NO;
                }
                
                if ( [keys containsObject:@"bias"] ) {
                    
                    if ( ![output[@"denormalize"][@"bias"] isKindOfClass:[NSDictionary class]] ) {
                        *error = [self imageOutputDenormalizeBiasMustBeDictionaryError];
                        return NO;
                    }
                    
                    {
                        NSMutableSet *biasKeys = [NSMutableSet setWithArray:[output[@"denormalize"][@"bias"] allKeys]];
                        [biasKeys removeObject:@"r"];
                        [biasKeys removeObject:@"g"];
                        [biasKeys removeObject:@"b"];
                        
                        if ( biasKeys.count != 0 ) {
                            *error = [self imageOutputDenormalizeBiasHasUnusedKeysError];
                            return NO;
                        }
                    }
                    
                    NSSet *biasKeys = [NSSet setWithArray:[output[@"denormalize"][@"bias"] allKeys]];
                
                    if ( biasKeys.count == 0 ) {
                        *error = [self imageOutputDenormalizeBiasIsEmptyError];
                        return NO;
                    }
                    
                    if ( ![biasKeys containsObject:@"r"] || ![biasKeys containsObject:@"g"] || ![biasKeys containsObject:@"g"] ) {
                        *error = [self imageOutputDenormalizeBiasMustHaveCorectKeysError];
                        return NO;
                    }
                    
                    if (   ![output[@"denormalize"][@"bias"][@"r"] isKindOfClass:[NSNumber class]]
                        || ![output[@"denormalize"][@"bias"][@"g"] isKindOfClass:[NSNumber class]]
                        || ![output[@"denormalize"][@"bias"][@"g"] isKindOfClass:[NSNumber class]] ) {
                        *error = [self imageOutputDenormalizeBiasMustBeNumericValuesError];
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
