//
//  TIOModelBundleValidator.h
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

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef BOOL (^TIOModelBundleValidationBlock)(NSString *path, NSDictionary *JSON, NSError **error);

@interface TIOModelBundleValidator : NSObject

/**
 * Instantiates a bundle validator with a model bundle.
 *
 * @param path A path to a .tfbundle folder that will be validated.
 *
 * @return instancetype A validator instance.
 */

- (instancetype)initWithModelBundleAtPath:(NSString*)path NS_DESIGNATED_INITIALIZER;

/**
 * Use the designated initializer.
 */

- (instancetype)init NS_UNAVAILABLE;

/**
 * The path to the bundle which is being evaluated.
 */

@property(readonly) NSString *path;

/**
 * The JSON in the model.json file for which the bundle is being evaluated
 */

@property(readonly) NSDictionary *JSON;

/**
 * Validates the bundle which was provided at initialization.
 *
 * @param customValidator A custom validation block for application specific validation
 * @param error Pointer to an `NSError` that will be set if the bundle could not be validated.
 *
 * @return BOOL `YES` if the bundle was successfully validated, `NO` otherwise.
 */

- (BOOL)validate:(_Nullable TIOModelBundleValidationBlock)customValidator error:(NSError**)error;

/**
 * A convenience method for validating the bundle when not custom validation is needed
 *
 * @param error Pointer to an `NSError` that will be set if the bundle could not be validated.
 *
 * @return BOOL `YES` if the bundle was successfully validated, `NO` otherwise.
 */

- (BOOL)validate:(NSError**)error;

/**
 * Validates bundle properties from a JSON dictionary. Called by `validate:`
 *
 * @param JSON The bundle properties loaded from a model.json file.
 * @param error Pointer to an `NSError` that will be set if the bundle properties could not be validated.
 *
 * @return BOOL `YES` if the bundle was successfully validated, `NO` otherwise.
 */

// TODO: documentation

- (BOOL)validateBundleProperties:(NSDictionary*)JSON error:(NSError**)error;

- (BOOL)validateModelProperties:(NSDictionary*)JSON error:(NSError**)error;

- (BOOL)validateAssets:(NSDictionary*)JSON error:(NSError**)error;

- (BOOL)validateInputs:(NSArray*)JSON error:(NSError**)error;

- (BOOL)validateOutputs:(NSArray*)JSON error:(NSError**)error;

- (BOOL)validateCustomValidator:(NSDictionary*)JSON validator:(TIOModelBundleValidationBlock)customValidator error:(NSError**)error;

@end

NS_ASSUME_NONNULL_END
