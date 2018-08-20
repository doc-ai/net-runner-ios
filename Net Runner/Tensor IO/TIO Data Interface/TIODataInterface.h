//
//  TIODataInterface.h
//  TensorIO
//
//  Created by Philip Dow on 8/3/18.
//  Copyright © 2018 doc.ai. All rights reserved.
//
//  TODO: Perhaps TIODataInteface is TIOLayerInterface

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

#import "TIODataDescription.h"

NS_ASSUME_NONNULL_BEGIN

@class TIOPixelBufferDescription;
@class TIOVectorDescription;

typedef void (^TIOPixelBufferMatcher)(TIOPixelBufferDescription *pixelBufferDescription);
typedef void (^TIOVectorMatcher)(TIOVectorDescription *vectorDescription);

/**
 * The input or output interface to a model, described by a `TIODataDescription`.
 *
 * This is an algebraic data type inspired by Remodel: https://github.com/facebook/remodel.
 * In Swift it would be an Enumeration with Associated Values. The intent is to capture the
 * variety of inputs and outputs a model can accept in a unified interface.
 *
 * Normally you will not need to interract with this class, although you may request a
 * `TIODataDescription` from a conforming `TIOModel` for inputs or outputs that you are specifically
 * interested in, for example, a pixel buffer input when you want greater control over scaling
 * and clipping an image before passing it to the model.
 */

@interface TIODataInterface : NSObject

/**
 * Initializes a `TIODataInterface` with a pixel buffer description.
 *
 * @param pixelBufferDescription Description of the expected pixel buffer
 *
 * @return `TIODataInterface` The encapsulated description
 */

- (instancetype)initWithName:(NSString*)name isInput:(BOOL)isInput pixelBufferDescription:(TIOPixelBufferDescription*)pixelBufferDescription;

/**
 * Initializes a `TIODataInterface` with a vector description, e.g. the description of a  vector,
 * matrix, or other tensor.
 *
 * @param vectorDescription Description of the expected vector
 *
 * @return `TIODataInterface` The encapsulated description
 */

- (instancetype)initWithName:(NSString*)name isInput:(BOOL)isInput vectorDescription:(TIOVectorDescription*)vectorDescription;

/**
 * Use one of the above initializer
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
 * `TIODataDescription` directly.
 */

@property (readonly) id<TIODataDescription> dataDescription;

/**
 * Use this function to switch on the underlying description.
 *
 * When preparing inputs and capturing outputs, a `TIOModel` uses the underlying description of a layer
 * in order to determine how to move bytes around.
 */

- (void)matchCasePixelBuffer:(TIOPixelBufferMatcher)pixelBufferMatcher caseVector:(TIOVectorMatcher)vectorMatcher;

@end

NS_ASSUME_NONNULL_END
