//
//  FileImageEvaluator.mm
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

#import "FileImageEvaluator.h"

#import "EvaluatorConstants.h"
#import "ImageEvaluator.h"
#import "Utilities.h"

@import TensorIO;

@interface FileImageEvaluator ()

@property (readwrite) NSDictionary *results;
@property (readwrite) id<TIOModel> model;
@property (readwrite) NSURL *fileURL;
@property (readwrite) NSString *name;

@end

@implementation FileImageEvaluator {
    dispatch_once_t _once;
}

- (instancetype)initWithModel:(id<TIOModel>)model fileURL:(NSURL*)fileURL name:(NSString*)name {
    if (self = [super init]) {
        _model = model;
        _fileURL = fileURL;
        _name = name;
    }
    
    return self;
}

- (void)evaluateWithCompletionHandler:(nullable EvaluatorCompletionBlock)completionHandler {
    dispatch_once(&_once, ^{
     
    NSString *path = self.fileURL.path;
    NSData *data = [[NSData alloc] initWithContentsOfFile:path];
    UIImage *image = [[UIImage alloc] initWithData:data];
    
    @autoreleasepool {
    
        tio_defer_block {
            self.model = nil;
        };
    
        if (image == nil) {
            NSString *errorDescription = [NSString stringWithFormat:@"Error loading image at %@", path];
            NSLog(@"%@", errorDescription);
            NSDictionary *evaluatorResults = @{
                kEvaluatorResultsKeySourceType          : kEvaluatorResultsKeySourceTypeFile,
                kEvaluatorResultsKeyImage               : self.name,
                kEvaluatorResultsKeyModel               : self.model.identifier,
                kEvaluatorResultsKeyError               : @(YES),
                kEvaluatorResultsKeyErrorDescription    : errorDescription,
                kEvaluatorResultsKeyEvaluation          : [NSNull null]
            };
            safe_block(completionHandler, evaluatorResults, NULL);
            return;
        }
        
        ImageEvaluator *imageEvaluator = [[ImageEvaluator alloc] initWithModel:self.model image:image ];
        
        [imageEvaluator evaluateWithCompletionHandler:^(NSDictionary *results, CVPixelBufferRef _Nullable inputPixelBuffer) {
            NSDictionary *evaluatorResults = @{
                kEvaluatorResultsKeySourceType          : kEvaluatorResultsKeySourceTypeFile,
                kEvaluatorResultsKeyImage               : self.name,
                kEvaluatorResultsKeyModel               : self.model.identifier,
                kEvaluatorResultsKeyError               : @(NO),
                kEvaluatorResultsKeyEvaluation          : results
            };
            safe_block(completionHandler, evaluatorResults, inputPixelBuffer);
        }];
    }
    
    }); // dispatch_once
}

@end
