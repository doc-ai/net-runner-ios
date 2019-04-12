//
//  TIOModelBundle.m
//  TensorIO
//
//  Created by Philip Dow on 7/20/18.
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

#import "TIOModelBundle.h"

#import "TIOModel.h"
#import "TIOModelOptions.h"
#import "TIOPlaceholderModel.h"

NSString * const kTFModelBundleExtension = @"tfbundle";
NSString * const kTFModelInfoFile = @"model.json";
NSString * const kTFLiteModelClassName = @"TIOTFLiteModel";
NSString * const kTFModelAssetsDirectory = @"assets";

@interface TIOModelBundle ()

@property (readwrite) NSDictionary *info;
@property (readwrite) NSString *path;

@property (readwrite) NSString *identifier;
@property (readwrite) NSString *name;
@property (readwrite) NSString *details;
@property (readwrite) NSString *author;
@property (readwrite) NSString *license;
@property (readwrite) BOOL quantized;

@property (readwrite) TIOModelOptions *options;
@property (readwrite) NSString *modelClassName;

@end

@implementation TIOModelBundle

- (nullable instancetype)initWithPath:(NSString*)path {
    if (self = [super init]) {
        
        // Read json file
    
        NSString *jsonPath = [path stringByAppendingPathComponent:kTFModelInfoFile];
        NSData *data = [NSData dataWithContentsOfFile:jsonPath];
        
        NSError *jsonError;
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
        
        if ( json == nil ) {
            NSLog(@"Error reading json file at path %@, error %@", jsonPath, jsonError);
            return nil;
        }
        
        // Initialize
        
        _path = path;
        _info = json;
        
        _identifier = json[@"id"];
        _name = json[@"name"];
        _version = json[@"version"];
        _details = json[@"details"];
        _author = json[@"author"];
        _license = json[@"license"];
        
        _options = [[TIOModelOptions alloc] initWithDictionary:json[@"options"]];
        _quantized = [json[@"model"][@"quantized"] boolValue];
        _type = json[@"model"][@"type"];
        
        _modelClassName = json[@"model"][@"class"] != nil
            ? json[@"model"][@"class"]
            : kTFLiteModelClassName;
        
        _placeholder = json[@"placeholder"] != nil
                    && [json[@"placeholder"] boolValue] == YES;
    }
    
    return self;
}

- (nullable id<TIOModel>)newModel {
    
    if ( self.placeholder ) {
        return [[TIOPlaceholderModel alloc] initWithBundle:self];
    }
    
    Class ModelClass = NSClassFromString(self.modelClassName);
    
    if ( ModelClass == nil ) {
        NSLog(@"Unable to convert model class name to class, %@", self.modelClassName);
        return nil;
    }
    
    id<TIOModel> model = [[ModelClass alloc] initWithBundle:self];
    
    if ( model == nil ) {
        NSLog(@"Unable to instantiate model for class %@", ModelClass);
        return nil;
    }

    return model;
}

- (NSString*)modelFilepath {
    if (self.isPlaceholder) {
        return nil;
    } else {
        return [_path stringByAppendingPathComponent:_info[@"model"][@"file"]];
    }
}

- (NSString*)pathToAsset:(NSString*)filename {
    return [[_path stringByAppendingPathComponent:kTFModelAssetsDirectory] stringByAppendingPathComponent:filename];
}

@end
