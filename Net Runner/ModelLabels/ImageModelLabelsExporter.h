//
//  ImageModelLabelsExporter.h
//  Net Runner
//
//  Created by Philip Dow on 1/9/19.
//  Copyright © 2019 doc.ai (http://doc.ai)
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
@import Photos;

@import SSZipArchive;
@import TensorIO;

NS_ASSUME_NONNULL_BEGIN

@class ImageModelLabelsDatabase;

@interface ImageModelLabelsExporter : NSObject

/**
 * The database that is being exported.
 */

@property (readonly) ImageModelLabelsDatabase *database;

/**
 * Designated initializer.
 */

- (id)initWithDatabase:(ImageModelLabelsDatabase*)database NS_DESIGNATED_INITIALIZER;

/**
 * Use the designated initializer.
 */

- (id)init NS_UNAVAILABLE;

/**
 * Exports the contents of the database to the designated location.
 */

- (BOOL)exportTo:(NSString*)path;

@end

NS_ASSUME_NONNULL_END
