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
#import "TIOModelBackend.h"

@import DSJSONSchemaValidation;

static NSError * TIOMalformedJSONError(void);
static NSError * TIOInvalidFilepathError(NSString * path);
static NSError * TIOInvalidExtensionError(NSString * path);
static NSError * TIONoModelJSONFileError(void);
static NSError * TIOModelFileDoesNotExistsError(NSString *filename);
static NSError * TIOLabelsFileDoesNotExistError(NSString *filename);
static NSError * TIOModelSchemaError(void);
static NSError * TIOModelValidationError(void);

// MARK: -

@implementation TIOModelBundleValidator

- (instancetype)initWithModelBundleAtPath:(NSString *)path {
    if (self = [super init]) {
        _path = path;
    }
    return self;
}

// MARK: - Validation

- (BOOL)validate:(NSError * _Nullable *)error {
    return [self validate:nil error:error];
}

- (BOOL)validate:(_Nullable TIOModelBundleValidationBlock)customValidator error:(NSError * _Nullable *)error {
    NSFileManager *fm = [NSFileManager defaultManager];
    BOOL isDirectory;
    
    // Validate path
    
    if ( ![fm fileExistsAtPath:self.path isDirectory:&isDirectory] || !isDirectory ) {
        if (error) {
            *error = TIOInvalidFilepathError(self.path);
        }
        return NO;
    }
    
    // Validate bundle structure
    
    if ( [self.path.pathExtension isEqualToString:TIOTFModelBundleExtension] ) {
        NSLog(@"The %@ extension for TIO Model Bundle is deprecated, use %@ instead",
                TIOTFModelBundleExtension,
                TIOModelBundleExtension);
    } else if ( ![self.path.pathExtension isEqualToString:TIOModelBundleExtension] ) {
        if (error) {
            *error = TIOInvalidExtensionError(self.path);
        }
        return NO;
    }
    
    if ( ![fm fileExistsAtPath:[self JSONPath] isDirectory:&isDirectory] || isDirectory ) {
        if (error) {
            *error = TIONoModelJSONFileError();
        }
        return NO;
    }
    
    // Validate if JSON can be read
    
    NSDictionary *JSON = [self loadJSON];
    
    if ( JSON == nil ) {
        if (error) {
            *error = TIOMalformedJSONError();
        }
        return NO;
    }
    
    // Acquire backend
    
    NSString *backend = JSON[@"model"][@"backend"];
    
    if (backend == nil) {
        backend = TIOModelBackend.availableBackend;
        NSLog(@"**** WARNING **** The model.json file must now specify which backend this model uses. "
              @"Add a \"backend\" field to the model dictionary in model.json, for example: "
              @"\n\"model\": {"
              @"\n  \"file\": \"model.tflite\","
              @"\n  \"backend\": \"tflite\""
              @"\n}");
    }
    
    // Validate JSON using schema
    
    NSError *schemaError = nil;
    DSJSONSchema *schema = [self JSONSchemaForBackend:backend error:&schemaError];
    
    if (schemaError) {
        if (error) {
            *error = TIOModelSchemaError();
        }
        NSLog(@"There was a problem loading the model schema for backend %@, error: %@", backend, schemaError);
        return NO;
    }
    
    NSError *validationError;
    [schema validateObject:JSON withError:&validationError];
    
    if (validationError) {
        if (error) {
            *error = TIOModelValidationError();
        }
        NSLog(@"The model.json file with backend %@ failed validation, error: %@", backend, validationError);
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

- (BOOL)validateAssets:(NSDictionary *)JSON error:(NSError * _Nullable *)error {
    NSFileManager *fm = NSFileManager.defaultManager;
    
    // validate model file, but only if this is not a placeholder model
    
    if ( JSON[@"placeholder"] == nil || [JSON[@"placeholder"] boolValue] == NO ) {
    
        NSString *modelFilename = JSON[@"model"][@"file"];
        NSString *modelFilepath = [self.path stringByAppendingPathComponent:modelFilename];
        
        if ( ![fm fileExistsAtPath:modelFilepath] ) {
            if (error) {
                *error = TIOModelFileDoesNotExistsError(modelFilename);
            }
            return NO;
        }
        
    }
    
    // validate any labels that appear in outputs
    
    for ( NSDictionary *output in JSON[@"outputs"] ) {
        NSString *labelsFilename = output[@"labels"];
        if ( labelsFilename == nil ) {
            break;
        }
        
        NSString *labelsFilepath = [[self.path stringByAppendingPathComponent:TIOModelAssetsDirectory] stringByAppendingPathComponent:labelsFilename];
        
        if ( ![fm fileExistsAtPath:labelsFilepath] ) {
            if (error) {
                *error = TIOLabelsFileDoesNotExistError(labelsFilename);
            }
            return NO;
        }
    }
    
    return YES;
}

- (BOOL)validateCustomValidator:(NSDictionary *)JSON validator:(TIOModelBundleValidationBlock)customValidator error:(NSError * _Nullable *)error {
    return customValidator(self.path, JSON, error);
}

// MARK: - Utilities

- (DSJSONSchema *)JSONSchemaForBackend:(NSString *)backend error:(NSError * _Nullable *)error {
    NSBundle *bundle = [TIOModelBackend resourceBundleForBackend:backend];
    NSURL *schemaURL = [bundle URLForResource:@"model-schema" withExtension:@"json"];
    NSData *schemaData = [NSData dataWithContentsOfURL:schemaURL];
    
    return [DSJSONSchema
        schemaWithData:schemaData
        baseURI:nil
        referenceStorage:nil
        specification:[DSJSONSchemaSpecification draft7]
        options:nil
        error:error];
}

- (NSString *)JSONPath {
    return [self.path stringByAppendingPathComponent:TIOModelInfoFile];
}

- (NSDictionary *)loadJSON {
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

// MARK: - Error Codes

static NSString * const TIOModelBundleValidatorErrorDomain = @"ai.doc.tensorio.model-bundle-validator";

static const NSUInteger TIOMalformedJSONErrorCode = 1000;
static const NSUInteger TIOInvalidFilepathErrorCode = 1001;
static const NSUInteger TIOInvalidExtensionErrorCode = 1002;
static const NSUInteger TIONoModelJSONFileErrorCode = 1003;
static const NSUInteger TIOModelFileDoesNotExistsErrorCode = 1004;
static const NSUInteger TIOLabelsFileDoesNotExistErrorCode = 1005;
static const NSUInteger TIOModelSchemaErrorCode = 1006;
static const NSUInteger TIOModelValidationErrorCode = 1007;

// MARK: - Bundle Structure Errors

static NSError * TIOInvalidFilepathError(NSString * path) {
    return [NSError errorWithDomain:TIOModelBundleValidatorErrorDomain code:TIOInvalidFilepathErrorCode userInfo:@{
        NSLocalizedDescriptionKey: [NSString stringWithFormat:@"No .tiobundle directory exists at path, %@", path],
        NSLocalizedRecoverySuggestionErrorKey: @"Make sure a .tiobundle directory is the root directory"
    }];
}

static NSError * TIOInvalidExtensionError(NSString * path) {
    return [NSError errorWithDomain:TIOModelBundleValidatorErrorDomain code:TIOInvalidExtensionErrorCode userInfo:@{
        NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Dirctory exists at path but does not have a .tiobundle extension, %@", path],
        NSLocalizedRecoverySuggestionErrorKey: @"Add the .tiobundle extension to the root directory"
    }];
}

static NSError * TIONoModelJSONFileError(void) {
    return [NSError errorWithDomain:TIOModelBundleValidatorErrorDomain code:TIONoModelJSONFileErrorCode userInfo:@{
        NSLocalizedDescriptionKey: [NSString stringWithFormat:@"No model.json file found"],
        NSLocalizedRecoverySuggestionErrorKey: @"Ensure the root .tiobundle directory contains a model.json file"
    }];
}

// MARK: - JSON Errors

static NSError * TIOMalformedJSONError(void) {
    return [NSError errorWithDomain:TIOModelBundleValidatorErrorDomain code:TIOMalformedJSONErrorCode userInfo:@{
        NSLocalizedDescriptionKey: [NSString stringWithFormat:@"The model.json file could not be read"],
        NSLocalizedRecoverySuggestionErrorKey: @"Make sure that model.json contains valid json"
    }];
}

static NSError * TIOModelSchemaError(void) {
    return [NSError errorWithDomain:TIOModelBundleValidatorErrorDomain code:TIOModelSchemaErrorCode userInfo:@{
        NSLocalizedDescriptionKey: [NSString stringWithFormat:@"The model-schema.json file for this backend could not be loaded"],
        NSLocalizedRecoverySuggestionErrorKey: @"Make sure you have added a backend to your podspec"
    }];
}

static NSError * TIOModelValidationError(void) {
    return [NSError errorWithDomain:TIOModelBundleValidatorErrorDomain code:TIOModelValidationErrorCode userInfo:@{
        NSLocalizedDescriptionKey: [NSString stringWithFormat:@"The model.json file failed validation."],
        NSLocalizedRecoverySuggestionErrorKey: @"Use the ajv-cli tool and the latest model schema at https://doc-ai.github.io/tensorio/ to validate the your model.json file"
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
