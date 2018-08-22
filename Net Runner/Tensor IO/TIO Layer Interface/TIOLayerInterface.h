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

typedef void (^TIOPixelBufferMatcher)(TIOPixelBufferLayerDescription *pixelBufferDescription);
typedef void (^TIOVectorMatcher)(TIOVectorLayerDescription *vectorDescription);

/**
 * Encapsulates information about the input and output layers of a model, fully described by a
 * `TIOLayerDescription`. Used internally by a model when parsing its description. Also used to
 * match inputs and outputs to their corresponding layers.
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
 * @param pixelBufferDescription Description of the expected pixel buffer
 *
 * @return `TIOLayerInterface` The encapsulated description
 */

- (instancetype)initWithName:(NSString*)name isInput:(BOOL)isInput pixelBufferDescription:(TIOPixelBufferLayerDescription*)pixelBufferDescription NS_DESIGNATED_INITIALIZER;

/**
 * Initializes a `TIOLayerInterface` with a vector description, e.g. the description of a vector,
 * matrix, or other tensor.
 *
 * @param vectorDescription Description of the expected vector
 *
 * @return `TIOLayerInterface` The encapsulated description
 */

- (instancetype)initWithName:(NSString*)name isInput:(BOOL)isInput vectorDescription:(TIOVectorLayerDescription*)vectorDescription NS_DESIGNATED_INITIALIZER;

/**
 * Use one of the above initializers
 */

- (instancetype)init NS_UNAVAILABLE;

/**
 * The name of the model interface
 *
 * May corresponding to an actual layer name or be your own name. The name will be used to copy
 * values to a tensor buffer when a model is run on an `NSDictionary` input or to associate an
 * output with a given name.
 */

@property (readonly) NSString *name;

/**
 * `YES` if this describes an input to the model, `NO` if this describes an output to the model.
 */

@property (readonly,getter=isInput) BOOL input;

/**
 * The underlying data description.
 *
 * Generally you should use the match-case function instead of accessing the underlying
 * `TIOLayerDescription` directly.
 */

@property (readonly) id<TIOLayerDescription> dataDescription;

/**
 * Use this function to switch on the underlying description.
 *
 * When preparing inputs and capturing outputs, a `TIOModel` uses the underlying description of a layer
 * in order to determine how to move bytes around.
 */

- (void)matchCasePixelBuffer:(TIOPixelBufferMatcher)pixelBufferMatcher caseVector:(TIOVectorMatcher)vectorMatcher;

@end

NS_ASSUME_NONNULL_END
