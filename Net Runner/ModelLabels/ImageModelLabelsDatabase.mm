//
//  ImageModelLabelsDatabase.m
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

#import "ImageModelLabelsDatabase.h"
#import "ImageModelLabels.h"

@import TensorIO;
@import FMDB;

NSString * _Nonnull  ImageModelLabelsDatabasePath(NSString * _Nonnull  basepath, TIOModelBundle * _Nonnull model) {
    return [basepath stringByAppendingPathComponent:model.identifier];
}

NSDictionary * _Nonnull PlaceholderLabelsForModel(id<TIOModel> _Nonnull model) {
    NSMutableDictionary *placeholders = [[NSMutableDictionary alloc] init];
    
    for ( TIOLayerInterface *layer in model.io.outputs.all) {
        [layer matchCasePixelBuffer:^(TIOPixelBufferLayerDescription * _Nonnull pixelBufferDescription) {
                // Image buffer: currently unsupported
                placeholders[layer.name] = [NSData data];
        } caseVector:^(TIOVectorLayerDescription * _Nonnull vectorDescription) {
            if ( vectorDescription.labels == nil ) {
                // Float values
                placeholders[layer.name] = @[];
            } else {
                // Text label
                placeholders[layer.name] = @"";
            }
        } caseString:^(TIOStringLayerDescription * _Nonnull stringDescription) {
            // Text label
            placeholders[layer.name] = @"";
        }];
    }
    
    return placeholders;
}

@interface ImageModelLabelsDatabase()

@property (readwrite) FMDatabase *db;

@end

@implementation ImageModelLabelsDatabase

+ (BOOL)removeDatabaseForModel:(TIOModelBundle*)model basepath:(NSString*)basepath {
    NSString *path = ImageModelLabelsDatabasePath(basepath, model);
    NSError *error;
    
    if (![NSFileManager.defaultManager fileExistsAtPath:path]) {
        return YES;
    }
    
    if (![NSFileManager.defaultManager removeItemAtPath:path error:&error]) {
        NSLog(@"Unable to remove the database at path %@, error: %@", path, error);
        return NO;
    }
    
    return YES;
}

+ (BOOL)databaseExistsForModel:(TIOModelBundle*)model basepath:(NSString*)basepath {
    NSString *path = ImageModelLabelsDatabasePath(basepath, model);
    return [NSFileManager.defaultManager fileExistsAtPath:path];
}

// MARK: -

- (void)dealloc {
    [self close];
}

- (instancetype)initWithModel:(id<TIOModel>)model basepath:(NSString*)basepath {
    if ((self=[super init])) {
        _model = model;
        
        NSString *path = ImageModelLabelsDatabasePath(basepath, model.bundle);
        
        if ( [NSFileManager.defaultManager fileExistsAtPath:path] ) {
            _db = [self openDatabase:path model:model];
        } else {
            _db = [self createDatabase:path model:model];
        }
        
        if (!_db) {
            NSLog(@"There was a problem opening or creating the database at path %@", path);
            return nil;
        }
    }
    return self;
}

- (nullable FMDatabase*)openDatabase:(NSString*)path model:(id<TIOModel>)model {
    FMDatabase *database = [[FMDatabase alloc] initWithPath:path];
    
    if (![database open]) {
        NSLog(@"Unable to open database at path %@, error: %@", path, database.lastErrorMessage);
        return nil;
    }
    
    return database;
}

- (nullable FMDatabase*)createDatabase:(NSString*)path model:(id<TIOModel>)model {
    FMDatabase *database = [[FMDatabase alloc] initWithPath:path];
    
    if (![database open]) {
        NSLog(@"Unable to open database at path %@, error: %@", path, database.lastErrorMessage);
        return nil;
    }
    
    // Create Labels Table
    
    NSString *createLabelsQuery =
        @"CREATE TABLE labels ("
         "id TEXT PRIMARY KEY, "
         "labels BLOB NOT NULL )";
    
    if (![database executeUpdate:createLabelsQuery]) {
        NSLog(@"Unable to create labels table for database at path %@, error: %@", path, database.lastErrorMessage);
        [database close];
        return nil;
    }
    
    return database;
}

- (ImageModelLabels*)labelsForImageWithID:(NSString*)identifier {
    NSString *query = @"SELECT * FROM labels WHERE id = ?";
    FMResultSet *results = [self.db executeQuery:query, identifier];
    
    if (results == nil) {
        NSLog(@"Error executing labels select query, error: %@", self.db.lastErrorMessage);
        return nil;
    }
    
    if (!results.next) {
        // No results, return a placeholder object
        NSDictionary *placeholders = PlaceholderLabelsForModel(self.model);
        ImageModelLabels *labels = [[ImageModelLabels alloc] initWithDatabase:self identifier:identifier labels:placeholders isCreated:NO];
        return labels;
    }
    
    // Read labels from result, deserialize, and return an instance
    
    NSData *data = [results objectForColumn:@"labels"];
    
    if (data == nil) {
        NSLog(@"Unable to read labels from select results for object with identifier %@, error: %@",
            identifier, self.db.lastErrorMessage);
        return nil;
    }
    
    NSError *JSONError;
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&JSONError];
    
    if (dictionary == nil) {
        NSLog(@"Unable to deserialize labels from select results for object with identifier %@, error: %@",
            identifier, JSONError);
        return nil;
    }
    
    ImageModelLabels *labels = [[ImageModelLabels alloc] initWithDatabase:self identifier:identifier labels:dictionary isCreated:YES];
    return labels;
}

- (NSArray<ImageModelLabels*>*)allLabels {
    NSString *query = @"SELECT * FROM labels";
    FMResultSet *results = [self.db executeQuery:query];
    
    if (results == nil) {
        NSLog(@"Error executing labels select query, error: %@", self.db.lastErrorMessage);
        return nil;
    }
    
    NSMutableArray<ImageModelLabels*> *allLabels = [[NSMutableArray alloc] init];
    
    while (results.next) {
        NSString *identifier = [results objectForColumn:@"id"];
        NSData *data = [results objectForColumn:@"labels"];
        
        if (data == nil) {
            NSLog(@"Unable to read labels from select results for object with identifier %@, error: %@",
                identifier, self.db.lastErrorMessage);
            continue;
        }
        
        NSError *JSONError;
        NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&JSONError];
        
        if (dictionary == nil) {
            NSLog(@"Unable to deserialize labels from select results for object with identifier %@, error: %@",
                identifier, JSONError);
            continue;
        }
        
        ImageModelLabels *labels = [[ImageModelLabels alloc] initWithDatabase:self identifier:identifier labels:dictionary isCreated:YES];
        
        [allLabels addObject:labels];
    }
    
    return allLabels.copy;
}

- (void)close {
    [_db close];
}

@end
