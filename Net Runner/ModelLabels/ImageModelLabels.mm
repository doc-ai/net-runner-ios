//
//  ImageModelLabels.m
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

#import "ImageModelLabels.h"
#import "ImageModelLabelsDatabase.h"

@import FMDB;

@interface ImageModelLabels ()

/**
 * Unnested key-value pairs associated with model outputs.
 */

@property (readwrite) NSDictionary *labels;

/**
 * Flag indicating if the values have actually been stored in the database yet.
 */

@property BOOL created;

@end

@implementation ImageModelLabels

- (instancetype)initWithDatabase:(ImageModelLabelsDatabase*)database identifier:(NSString*)identifier labels:(NSDictionary*)labels isCreated:(BOOL)isCreated {
    if ((self=[super init])) {
        _database = database;
        _created = isCreated;
        _identifier = identifier;
        _labels = labels;
    }
    return self;
}

- (id)labelForKey:(NSString*)key {
    [self throwExceptionIfKeyNotInOutputs:key];
    
    return self.labels[key];
}

- (void)setLabel:(id)value forKey:(NSString*)key {
    [self throwExceptionIfKeyNotInOutputs:key];
    
    NSMutableDictionary *newLabels = self.labels.mutableCopy;
    newLabels[key] = value;
    self.labels = newLabels;
}

- (void)throwExceptionIfKeyNotInOutputs:(NSString*)key {
    if (![self.labels.allKeys containsObject:key]) {
        @throw [NSException exceptionWithName:@"KeyNotFoundException"
                reason:@"An output layer with the specified name (key) could not be found"
                userInfo:@{@"key": key}];
    }
}

- (BOOL)save {
    NSError *JSONError;
    NSData *data = [NSJSONSerialization dataWithJSONObject:self.labels options:0 error:&JSONError];
    
    if (data == nil || JSONError != nil) {
        NSLog(@"Unable to serialize model labels to JSON for object with identifier %@, error: %@",
            self.identifier, JSONError);
        return NO;
    }
    
    if (self.created) {
        // Perform update
        NSString *query = @"UPDATE labels SET labels = ? WHERE id = ?";
        
        if (![self.database.db executeUpdate:query, data, self.identifier]) {
            NSLog(@"Unable to save changes to model labels for object with identifier %@, error: %@",
                self.identifier, self.database.db.lastErrorMessage);
            return NO;
        }
    } else {
        // Perform create
        NSString *query = @"INSERT INTO labels (id, labels) VALUES (?, ?)";
        
        if (![self.database.db executeUpdate:query, self.identifier, data]) {
            NSLog(@"Unable to create model labels for object with identifier %@, error: %@",
                self.identifier, self.database.db.lastErrorMessage);
            return NO;
        }
    }
    
    _created = YES;
    return YES;
}

- (BOOL)remove {
    if (!self.created) {
        return YES;
    }
    
    NSString *query = @"DELETE FROM labels WHERE id = ?";
    
    if (![self.database.db executeUpdate:query, self.identifier]) {
        NSLog(@"Unable to delete object with identifier %@, error: %@",
            self.identifier, self.database.db.lastErrorMessage);
        return NO;
    }
    
    return YES;
}

@end
