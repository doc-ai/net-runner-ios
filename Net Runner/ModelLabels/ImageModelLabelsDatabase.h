//
//  ImageModelLabelsDatabase.h
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
//  TODO: Note the use of TIOModel and TIOModelBundle below. It should be possible to
//  instantiate an instance of the database with just the model bundle, which means that
//  a model's description should be fully available from the bundle without needing to
//  load a model into memory. See TensorIO todos.

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol TIOModel;
@class TIOModelBundle;
@class ImageModelLabels;
@class FMDatabase;

@interface ImageModelLabelsDatabase : NSObject

/**
 * The model with whose labels this database is associated.
 */

@property id<TIOModel> model;

/**
 * A handle to the underlying FMDB resource.
 *
 * Do not make database calls to this resource directly. It is exposed to allow instances of
 * `ImageModelLabels` to manage their own saving and deleting.
 */

@property (readonly) FMDatabase *db;

/**
 * Initializes a labels database with reference to a particular model.
 *
 * If a database for this model doesn't exist yet, this method creates that database on disk.
 * When you are finished using this database, call `close` on it. That method is also called
 * automatically when this object is released.
 *
 * The on-disk database stores label data according to the format specifed in the outputs field
 * of your model's JSON description. Updates to a model that use the same model identifier must
 * not change their output fields. As a matter of practice, updates to a model should not change
 * the input and output fields, only model weights or internal structure.
 */

- (instancetype)initWithModel:(id<TIOModel>)model basepath:(NSString*)basepath NS_DESIGNATED_INITIALIZER;

/**
 * Use the designated initializer.
 */

- (instancetype)init NS_UNAVAILABLE;

/**
 * Removes the underlying sqlite resource from disk.
 */

+ (BOOL)removeDatabaseForModel:(TIOModelBundle*)model basepath:(NSString*)basepath;

/**
 * Checks if a database exists for a particular model.
 */

+ (BOOL)databaseExistsForModel:(TIOModelBundle*)model basepath:(NSString*)basepath;

/**
 * Returns the labels for an image with a unique identifier, or nil if there was an error
 * reading this object from the database.
 *
 * Call `save` on the resulting object to save your changes to it to the database.
 *
 * If no labels exists for the object with this id, returns a placeholder object that may be used
 * the same way. When you call `save` on this object, a row will be created for it in the
 * database.
 *
 * The identifier corresponds to a `PHObject`'s `localIdentifier` value.
 */

- (nullable ImageModelLabels*)labelsForImageWithID:(NSString*)identifier;

/**
 * Returns all labels in the database.
 */

- (NSArray<ImageModelLabels*>*)allLabels;

/**
 * Closes the connection to the database and frees up the underlying mysql resources.
 *
 * You may call this method when you are done using the database, or it will automatically be
 * called when the object is released.
 */

- (void)close;

@end

NS_ASSUME_NONNULL_END
