//
//  URLImageEvaluator.m
//  Net Runner
//
//  Created by Philip Dow on 7/18/18.
//  Copyright © 2018 doc.ai. All rights reserved.
//

#import "URLImageEvaluator.h"

#import "ObjcDefer.h"

@interface URLImageEvaluator ()

@property (readwrite) NSDictionary *results;
@property (readwrite) id<Model> model;
@property (readwrite) NSURL *URL;
@property (readwrite) NSString *name;

@end

@implementation URLImageEvaluator {
    dispatch_once_t _once;
}

- (instancetype)initWithModel:(id<Model>)model URL:(NSURL*)URL name:(NSString*)name {
    if (self = [super init]) {
        _model = model;
        _URL = URL;
        _name = name;
        
        assert(NO); // not currently supported
    }
    
    return self;
}

- (void)evaluateWithCompletionHandler:(nullable EvaluatorCompletionBlock)completionHandler {
    dispatch_once(&_once, ^{
    
    @autoreleasepool {
        
        defer_block {
            self.model = nil;
        };
        
    }
    
    }); // dispatch_once
}

@end
