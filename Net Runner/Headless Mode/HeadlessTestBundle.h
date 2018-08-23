//
//  HeadlessTestBundle.h
//  Net Runner
//
//  Created by Philip Dow on 7/19/18.
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

@import Foundation;

NS_ASSUME_NONNULL_BEGIN

@protocol EvaluationMetric;

@interface HeadlessTestBundle : NSObject

/**
 * The full path to the test bundle folder.
 */

@property (readonly) NSString *path;

/**
 * The deserialized information contained in the test.json file.
 */

@property (readonly) NSDictionary *info;

/**
 * The test bundle's name.
 */

@property (readonly) NSString *name;

/**
 * A string uniquely identifying the test bundle
 */

@property (readonly) NSString *identifier;

/**
 * The test bundle's version.
 */

@property (readonly) NSString *version;

/**
 * An array of model id's corresponding to the model's that will be evaluated.
 */

@property (readonly) NSArray<NSString*> *modelIds;

/**
 * An array of image names and relative paths corresponding to the images against which
 * the model will be evaluated.
 */

@property (readonly) NSArray<NSDictionary<NSString*, id>*> *images;

/**
 * The expected inference.
 */

@property (readonly) NSDictionary<NSString*,id> *labels;

/**
 * Test options, including the number of iterations to run on each image and the metric to use.
 */

@property (readonly) NSDictionary<NSString*,id> *options;

/**
 * The number of iterations to run on each image.
 */

@property (readonly) NSUInteger iterations;

/**
 * The `EvaluationMetric` to use.
 */

@property (readonly) id<EvaluationMetric> metric;

// MARK: -

/**
 * The designated initializer.
 *
 * @param path The full path to the test bundle.
 */

- (instancetype)initWithPath:(NSString*)path NS_DESIGNATED_INITIALIZER;

/**
 * Use the designated initializer.
 */

- (instancetype)init NS_UNAVAILABLE;

/**
 * Derives the fully qualifed file path for one of the images contained in the images field.
 *
 * @param imageInfo The dictionary for the image.
 *
 * @return NSString The fully qualified path to the image.
 */

- (NSString*)filePathForImageInfo:(NSDictionary<NSString*,NSString*>*)imageInfo;

@end

NS_ASSUME_NONNULL_END
