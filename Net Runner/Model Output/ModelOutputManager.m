//
//  ModelOutputManager.m
//  Net Runner
//
//  Created by Philip Dow on 8/16/18.
//  Copyright © 2018 doc.ai. All rights reserved.
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
