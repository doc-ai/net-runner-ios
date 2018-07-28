//
//  ModelBundle.m
//  tflite_camera_example
//
//  Created by Philip Dow on 7/20/18.
//  Copyright © 2018 doc.ai. All rights reserved.
//

#import "ModelBundle.h"

#import "Model.h"
#import "ModelOptions.h"

NSString * const kTFModelBundleExtension = @"tfbundle";
NSString * const kTFModelInfoFile = @"model.json";

@interface ModelBundle ()

@property (readwrite) NSDictionary *info;
@property (readwrite) NSString *path;

@property (readwrite) NSString *identifier;
@property (readwrite) NSString *name;
@property (readwrite) NSString *details;
@property (readwrite) NSString *author;
@property (readwrite) NSString *license;
@property (readwrite) BOOL quantized;

@property (readwrite) ModelOptions *options;
@property (readwrite) NSString *modelClassName;

@end

@implementation ModelBundle

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
        
        // Required properties
        
        assert(json[@"id"] != nil);
        assert(json[@"name"] != nil);
        assert(json[@"version"] != nil);
        assert(json[@"details"] != nil);
        assert(json[@"author"] != nil);
        assert(json[@"license"] != nil);
        
        assert(json[@"model"] != nil);
        assert(json[@"model"][@"quantized"] != nil);
        assert(json[@"model"][@"class"] != nil);
        assert(json[@"model"][@"file"] != nil);
        
        // Initialize
        
        _path = path;
        _info = json;
        
        _identifier = json[@"id"];
        _name = json[@"name"];
        _version = json[@"version"];
        _details = json[@"details"];
        _author = json[@"author"];
        _license = json[@"license"];
        
        _options = [[ModelOptions alloc] initWithDictionary:json[@"options"]];
        _quantized = [json[@"model"][@"quantized"] boolValue];
        _modelClassName = json[@"model"][@"class"];
    }
    
    return self;
}

- (nullable id<Model>)newModel {
    
    Class ModelClass = NSClassFromString(self.modelClassName);
    
    if ( ModelClass == nil ) {
        NSLog(@"Unable to convert model class name to class, %@", self.modelClassName);
        return nil;
    }
    
    id<Model> model = [[ModelClass alloc] initWithBundle:self];
    
    if ( model == nil ) {
        NSLog(@"Unable to instantiate model for class %@", ModelClass);
        return nil;
    }

    return model;
}

- (NSString*)modelFilepath {
    return [_path stringByAppendingPathComponent:_info[@"model"][@"file"]];
}

@end
