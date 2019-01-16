//
//  ModelOutputManager.m
//  Net Runner
//
//  Created by Philip Dow on 8/16/18.
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

#import "ModelOutputManager.h"

#import "ImageNetClassificationModelOutput.h"
#import "DefaultModelOutput.h"

@interface ModelOutputManager ()

@property NSDictionary<NSString*,Class> *classes;

@end

@implementation ModelOutputManager

+ (instancetype)sharedManager {
    static dispatch_once_t once;
    static id sharedInstance;

    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] initWithClasses:ModelOutputManager.classes];
    });
    return sharedInstance;
}

- (instancetype)initWithClasses:(NSDictionary*)classes {
    if (self = [super init]) {
        _classes = classes;
    }
    return self;
}

+ (NSDictionary<NSString*,Class>*)classes {
    NSMutableDictionary<NSString*,Class> *classes = [[NSMutableDictionary alloc] init];
    
    classes[@"image.classification.imagenet"] = NSClassFromString(@"ImageNetClassificationModelOutput");
    // Add your model output class here
    
    return [classes copy];
}

- (Class)classForType:(NSString*)type {
    Class class = self.classes[type];
    if ( class != nil ) {
        return class;
    } else {
        return DefaultModelOutput.class;
    }
}

@end
