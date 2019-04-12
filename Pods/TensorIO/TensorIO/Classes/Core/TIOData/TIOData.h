//
//  TIOData.h
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

#import "TIOLayerDescription.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * A `TIOData` is any data type that knows how to provide bytes to an input tensor
 * and how to read bytes from an output tensor. The concrete extension of
 * conforming classes is left to submodules.
 */

@protocol TIOData <NSObject>
@end

/**
 * `NSArray` conforms to `TIOData`.
 */

@interface NSArray (TIOData) <TIOData>
@end

/**
 * `NSData` conforms to `TIOData`.
 */

@interface NSData (TIOData) <TIOData>
@end

/**
 * `NSDictionary` conforms to `TIOData`.
 */

@interface NSDictionary (TIOData) <TIOData>
@end

/**
 * `NSNumber` conforms to `TIOData`.
 */

@interface NSNumber (TIOData) <TIOData>
@end

NS_ASSUME_NONNULL_END
