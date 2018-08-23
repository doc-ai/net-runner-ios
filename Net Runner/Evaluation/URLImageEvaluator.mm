//
//  URLImageEvaluator.mm
//  Net Runner
//
//  Created by Philip Dow on 7/18/18.
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

#import "URLImageEvaluator.h"

@import TensorIO;

@interface URLImageEvaluator ()

@property (readwrite) NSDictionary *results;
@property (readwrite) id<TIOModel> model;
@property (readwrite) NSURL *URL;
@property (readwrite) NSString *name;

@end

@implementation URLImageEvaluator {
    dispatch_once_t _once;
}

- (instancetype)initWithModel:(id<TIOModel>)model URL:(NSURL*)URL name:(NSString*)name {
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
        
        tio_defer_block {
            self.model = nil;
        };
        
    }
    
    }); // dispatch_once
}

@end
