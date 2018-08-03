//
//  FileImageEvaluator.m
//  Net Runner
//
//  Created by Philip Dow on 7/18/18.
//  Copyright © 2018 doc.ai. All rights reserved.
//

#import "FileImageEvaluator.h"

#import "EvaluatorConstants.h"
#import "ImageEvaluator.h"
#import "Utilities.h"
#import "ObjcDefer.h"

@interface FileImageEvaluator ()

@property (readwrite) NSDictionary *results;
@property (readwrite) id<VisionModel> model;
@property (readwrite) NSURL *fileURL;
@property (readwrite) NSString *name;

@end

@implementation FileImageEvaluator {
    dispatch_once_t _once;
}

- (instancetype)initWithModel:(id<VisionModel>)model fileURL:(NSURL*)fileURL name:(NSString*)name {
    if (self = [super init]) {
        _model = model;
        _fileURL = fileURL;
        _name = name;
    }
    
    return self;
}

// TODO: use key constants not strings

- (void)evaluateWithCompletionHandler:(nullable EvaluatorCompletionBlock)completionHandler {
    dispatch_once(&_once, ^{
     
    NSString *path = self.fileURL.path;
    NSData *data = [[NSData alloc] initWithContentsOfFile:path];
    UIImage *image = [[UIImage alloc] initWithData:data];
    
    @autoreleasepool {
    
        defer_block {
            self.model = nil;
        };
    
        if (image == nil) {
            NSString *errorDescription = [NSString stringWithFormat:@"Error loading image at %@", path];
            NSLog(@"%@", errorDescription);
            self.results = @{
                kEvaluatorResultsKeySourceType          : kEvaluatorResultsKeySourceTypeFile,
                kEvaluatorResultsKeyImage               : self.name,
                kEvaluatorResultsKeyModel               : self.model.identifier,
                kEvaluatorResultsKeyError               : @(YES),
                kEvaluatorResultsKeyErrorDescription    : errorDescription,
                kEvaluatorResultsKeyEvaluation          : [NSNull null]
            };
            safe_block(completionHandler, self.results);
            return;
        }
        
        ImageEvaluator *imageEvaluator = [[ImageEvaluator alloc] initWithModel:self.model image:image ];
        
        [imageEvaluator evaluateWithCompletionHandler:^(NSDictionary *results) {
            self.results = @{
                kEvaluatorResultsKeySourceType          : kEvaluatorResultsKeySourceTypeFile,
                kEvaluatorResultsKeyImage               : self.name,
                kEvaluatorResultsKeyModel               : self.model.identifier,
                kEvaluatorResultsKeyError               : @(NO),
                kEvaluatorResultsKeyEvaluation          : results
            };
            safe_block(completionHandler, self.results);
        }];
    }
    
    }); // dispatch_once
}

@end
