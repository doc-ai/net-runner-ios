//
//  TIOTFLiteErrors.mm
//  Net Runner
//
//  Created by Philip Dow on 7/13/18.
//  Copyright © 2018 doc.ai. All rights reserved.
//

#import "TIOTFLiteErrors.h"

// MARK: - Errors

NSError * const kTFLiteModelLoadModelError = [NSError errorWithDomain:@"netrunner.ios" code:101 userInfo:@{
    NSLocalizedDescriptionKey: @"Unable to load model from graph file"
}];

NSError * const kTFLiteModelConstructInterpreterError = [NSError errorWithDomain:@"netrunner.ios" code:101 userInfo:@{
    NSLocalizedDescriptionKey: @"Unable to construct interpreter"
}];

NSError * const kTFLiteModelAllocateTensorsError = [NSError errorWithDomain:@"netrunner.ios" code:101 userInfo:@{
    NSLocalizedDescriptionKey: @"Unable to allocate tensors"
}];
