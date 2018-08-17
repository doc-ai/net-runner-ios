//
//  TIOTFLiteModel.h
//  Net Runner Parser
//
//  Created by Philip Dow on 8/3/18.
//  Copyright © 2018 doc.ai. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "TIODataInterface.h"
#import "TIOData.h"
#import "Model.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * An Objective-C wrapper around TensorFlow lite models that provides a unified interface to the
 * input and output layers of the underlying model.
 */

@interface TIOTFLiteModel : NSObject <Model>

// Model Protocol Properties

@property (readonly) ModelBundle *bundle;
@property (readonly) ModelOptions *options;

@property (readonly) NSString* identifier;
@property (readonly) NSString* name;
@property (readonly) NSString* details;
@property (readonly) NSString* author;
@property (readonly) NSString* license;
@property (readonly) BOOL quantized;
@property (readonly) NSString *type;
@property (readonly) ModelWeightSize weightSize; // Unused
@property (readonly) BOOL loaded;

// Model Protocol Methods

- (nullable instancetype)initWithBundle:(ModelBundle*)bundle;

- (BOOL)load:(NSError**)error;
- (void)unload;

// MARK: - New

- (id<TIOData>)runModelOn:(id<TIOData>)input;

- (id<TIODataDescription>)dataDescriptionForInputAtIndex:(NSUInteger)index;
- (id<TIODataDescription>)dataDescriptionForInputWithName:(NSString*)name;

- (id<TIODataDescription>)dataDescriptionForOutputAtIndex:(NSUInteger)index;
- (id<TIODataDescription>)dataDescriptionForOutputWithName:(NSString*)name;

@end

NS_ASSUME_NONNULL_END
