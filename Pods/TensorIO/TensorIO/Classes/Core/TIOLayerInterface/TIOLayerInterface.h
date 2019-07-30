//
//  TIOLayerInterface.h
//  TensorIO
//
//  Created by Philip Dow on 8/3/18.
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
#import <AVFoundation/AVFoundation.h>

#import "TIOLayerDescription.h"

NS_ASSUME_NONNULL_BEGIN

@class TIOPixelBufferLayerDescription;
@class TIOVectorLayerDescription;
@class TIOStringLayerDescription;

typedef void (^TIOPixelBufferMatcher)(TIOPixelBufferLayerDescription *pixelBufferDescription);
typedef void (^TIOVectorMatcher)(TIOVectorLayerDescription *vectorDescription);
typedef void (^TIOStringMatcher)(TIOStringLayerDescription *stringDescription);

/**
 * The kind of layer this interface describes, one of input, output, or placeholder.
 */

typedef enum : NSUInteger {
    TIOLayerInterfaceModeInput,
    TIOLayerInterfaceModeOutput,
    TIOLayerInterfaceModePlaceholder,
} TIOLayerInterfaceMode;

/**
 * Encapsulates information about the input, output, and placeholder layers of a model, fully described by a
 * `TIOLayerDescription`. Used internally by a model when parsing its description. Also used to
 * match inputs, outputs, and placeholders to their corresponding layers.
 *
 * This is an algebraic data type inspired by Remodel: https://github.com/facebook/remodel.
 * In Swift it would be an Enumeration with Associated Values. The intent is to capture the
 * variety of inputs and outputs a model can accept and produce in a unified interface.
 *
 * Normally you will not need to interact with this class, although you may request a
 * `TIOLayerDescription` from a conforming `TIOModel` for inputs or outputs that you are specifically
 * interested in, for example, a pixel buffer input when you want greater control over scaling
 * and clipping an image before passing it to the model.
 */

@interface TIOLayerInterface : NSObject

/**
 * Initializes a `TIOLayerInterface` with a pixel buffer description.
 *
 * @param name The name of the layer
 * @param JSON The JSON description from whic this layer was parsed, may be nil
 * @param mode The function of this layer, one of input, output, or placeholder
 * @param pixelBufferDescription Description of the expected pixel buffer
 *
 * @return TIOLayerInterface The encapsulated description
 */

- (instancetype)initWithName:(NSString *)name JSON:(nullable NSDictionary *)JSON mode:(TIOLayerInterfaceMode)mode pixelBufferDescription:(TIOPixelBufferLayerDescription *)pixelBufferDescription NS_DESIGNATED_INITIALIZER;

/**
 * Initializes a `TIOLayerInterface` with a vector description, e.g. the description of a vector,
 * matrix, or other tensor.
 *
 * @param name The name of the layer
 * @param JSON The JSON description from whic this layer was parsed, may be nil
 * @param mode The function of this layer, one of input, output, or placeholder
 * @param vectorDescription Description of the expected vector
 *
 * @return TIOLayerInterface The encapsulated description
 */

- (instancetype)initWithName:(NSString *)name JSON:(nullable NSDictionary *)JSON mode:(TIOLayerInterfaceMode)mode vectorDescription:(TIOVectorLayerDescription *)vectorDescription NS_DESIGNATED_INITIALIZER;

/**
 * Initializes a `TIOLayerInterface` with a string description, e.g. the description
 * of a tensor taking raw bytes.
 *
 * @param name The name of the layer
 * @param JSON The JSON description from whic this layer was parsed, may be nil
 * @param mode The function of this layer, one of input, output, or placeholder
 * @param stringDescription Description of the expected vector
 *
 * @return TIOLayerInterface The encapsulated description
 */

- (instancetype)initWithName:(NSString *)name JSON:(nullable NSDictionary *)JSON mode:(TIOLayerInterfaceMode)mode stringDescription:(TIOStringLayerDescription *)stringDescription NS_DESIGNATED_INITIALIZER;

/**
 * Use one of the above initializers
 */

- (instancetype)init NS_UNAVAILABLE;

// MARK: -

/**
 * The name of the model interface
 *
 * May corresponding to an actual layer name or be your own name. The name will be used to copy
 * values to a tensor buffer when a model is run on an `NSDictionary` input or to associate an
 * output with a given name.
 */

@property (readonly) NSString *name;

/**
 * The layer's mode, one of input, output, or placeholder.
 */

@property (readonly) TIOLayerInterfaceMode mode;

/**
 * The underlying JSON description. May be `nil` if the layer description was
 * not parsed from JSON. You should not need to access this property yourself,
 * but it is used for debugging and to check for object equality.
 */

@property (nullable, readonly) NSDictionary *JSON;

// MARK: -

/**
 * Use this function to switch on the underlying description.
 *
 * When preparing inputs and capturing outputs, a `TIOModel` uses the underlying description of a layer
 * in order to determine how to move bytes around.
 */

- (void)matchCasePixelBuffer:(TIOPixelBufferMatcher)pixelBufferMatcher caseVector:(TIOVectorMatcher)vectorMatcher caseString:(TIOStringMatcher)stringMatcher;

/**
 * Checks for object equality. The `JSON` property is used to check for equality
 * and must not be `nil` for both objects to be equal.
 *
 * Attributes of the underlying layer description cannot be used because they
 * include block properties which cannot be compared.
 *
 */

- (BOOL)isEqualToLayerInterface:(TIOLayerInterface *)otherLayerInterface;

@end

NS_ASSUME_NONNULL_END
