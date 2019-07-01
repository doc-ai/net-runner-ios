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

/**
 * A validation block that allows clients of the validator to add custom validation as a final step.
 *
 * For example, Net Runner currrently only works with models that take a single image input,
 * so it verifies that model inputs conform to that requirement in its custom validation block.
 *
 * @param path The path to the model bundle.
 * @param JSON The json loaded from model.json in the model bundle.
 * @param error A pointer to an error object that the custom validator can set if validation fails.
 *
 * @return BOOL `YES` if the custom validation passed, `NO` otherwise.
 */

typedef BOOL (^TIOModelBundleValidationBlock)(NSString *path, NSDictionary *JSON, NSError **error);

/**
 * `TIOModelBundleValidator` is responsible for ensuring that the contents of a TensorIO bundle
 * are valid.
 *
 * The bundle validator will commonly be used to validate bundles that are deployed after release of
 * an app rather than those that are packaged with it. It validates each part of the TensorIO model
 * spec, and also allows the client to provide a custom validation block.
 */

@interface TIOModelBundleValidator : NSObject

/**
 * Instantiates a bundle validator with a model bundle.
 *
 * @param path A path to a .tiobundle folder that will be validated.
 *
 * @return instancetype A validator instance.
 */

- (instancetype)initWithModelBundleAtPath:(NSString *)path NS_DESIGNATED_INITIALIZER;

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

// MARK: - Validation

/**
 * Validates the bundle which was provided at initialization. Use this method to validate models.
 *
 * @param customValidator A custom validation block for application specific validation
 * @param error Pointer to an `NSError` that will be set if the bundle could not be validated.
 *
 * @return BOOL `YES` if the bundle was successfully validated, `NO` otherwise.
 */

- (BOOL)validate:(_Nullable TIOModelBundleValidationBlock)customValidator error:(NSError * _Nullable *)error;

/**
 * A convenience method for validating the bundle when no custom validation is needed.
 *
 * @param error Pointer to an `NSError` that will be set if the bundle could not be validated.
 *
 * @return BOOL `YES` if the bundle was successfully validated, `NO` otherwise.
 */

- (BOOL)validate:(NSError * _Nullable *)error;

/**
 * Validates presence of assets identified in JSON dictionary. Called by `validate:error:`
 *
 * @param JSON The bundle properties loaded from a model.json file.
 * @param error Pointer to an `NSError` that will be set if the assets could not be located.
 *
 * @return BOOL `YES` if the bundle was successfully validated, `NO` otherwise.
 */

- (BOOL)validateAssets:(NSDictionary *)JSON error:(NSError * _Nullable *)error;

/**
 * Executes a custom validator. Called by `validate:error:`
 *
 * The `validate:error:` function passes the custom validator provided there to this function.
 *
 * @param JSON The bundle properties loaded from a model.json file.
 * @param customValidator The custom validator provided to the `validate:error:` function.
 * @param error Pointer to an `NSError` that will be set if the output properties could not be validated.
 *
 * @return BOOL `YES` if the bundle was successfully validated, `NO` otherwise.
 */

- (BOOL)validateCustomValidator:(NSDictionary *)JSON validator:(TIOModelBundleValidationBlock)customValidator error:(NSError * _Nullable *)error;

@end

NS_ASSUME_NONNULL_END
