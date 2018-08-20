//
//  TIOModelBundle.m
//  Net Runner
//
//  Created by Philip Dow on 7/20/18.
//  Copyright © 2018 doc.ai. All rights reserved.
//

#import "TIOModelBundle.h"

#import "TIOModel.h"
#import "TIOModelOptions.h"

NSString * const kTFModelBundleExtension = @"tfbundle";
NSString * const kTFModelInfoFile = @"model.json";
NSString * const kTFLiteModelClassName = @"TIOTFLiteModel";
NSString * const kAssetsDirectory = @"assets";

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
        
        // Required properties
        
        assert(json[@"id"] != nil);
        assert(json[@"name"] != nil);
        assert(json[@"version"] != nil);
        assert(json[@"details"] != nil);
        assert(json[@"author"] != nil);
        assert(json[@"license"] != nil);
        
        assert(json[@"model"] != nil);
        assert(json[@"model"][@"quantized"] != nil);
        assert(json[@"model"][@"file"] != nil);
        // assert(json[@"model"][@"type"] != nil);
        
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
    }
    
    return self;
}

- (nullable id<TIOModel>)newModel {
    
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
    return [_path stringByAppendingPathComponent:_info[@"model"][@"file"]];
}

- (NSString*)pathToAsset:(NSString*)filename {
    return [[_path stringByAppendingPathComponent:kAssetsDirectory] stringByAppendingPathComponent:filename];
}

@end
