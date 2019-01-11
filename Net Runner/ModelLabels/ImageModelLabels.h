//
//  ImageModelLabels.h
//  Net Runner
//
//  Created by Philip Dow on 1/7/19.
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

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class ImageModelLabelsDatabase;

@interface ImageModelLabels : NSObject

/**
 * The database this set of labels is associated with.
 */

@property (weak) ImageModelLabelsDatabase *database;

/**
 * An unique identifier for this object in the database, corresponding to a `PHObject`'s
 * `localIdentifier` value.
 */

@property NSString *identifier;

/**
 * Unnested key-value pairs associated with model outputs.
 *
 * These values are more safely accessed using the labelForKey: method.
 */

@property (readonly) NSDictionary *labels;

/**
 * Designated initializer.
 *
 * You should not need to call this method or need to instantiate an `ImageModelLabels` object yourself.
 * It should only ever be called by an instance of `ImageModelLabelsDatabase`.
 */

- (instancetype)initWithDatabase:(ImageModelLabelsDatabase*)database identifier:(NSString*)identifier labels:(NSDictionary*)labels isCreated:(BOOL)isCreated NS_DESIGNATED_INITIALIZER;

/**
 * Use the designated initializer.
 */

- (instancetype)init NS_UNAVAILABLE;

/**
 * Get the label for a particular output key.
 *
 * Key-value pairs are model and application specific. The key corresponds to the name of an
 * output layer as they are described in the model.json file. Requesting a label for an output that
 * does not exist results in an exception.
 */

- (id)labelForKey:(NSString*)key;

/**
 * Set the label for a particular input key.
 *
 * Key-value pairs are model and application specific.  The key corresponds to the name of an
 * output layer as they are described in the model.json file. Setting a label for an output that
 * does not exist results in an exception. Values must be serializable to JSON.
 *
 * Label types are not currently enforced, so it is up to you to ensure that you associate a label
 * of the correct type with a particular key.
 */

- (void)setLabel:(id)value forKey:(NSString*)key;

/**
 * Saves the values to the database, creating a new row if necessary.
 */

- (BOOL)save;

/**
 * Removes the row associated with this object from the database.
 */

- (BOOL)remove;

@end

NS_ASSUME_NONNULL_END
