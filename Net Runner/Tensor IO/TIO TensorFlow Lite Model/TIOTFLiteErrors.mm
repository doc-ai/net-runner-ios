//
//  TIOTFLiteErrors.mm
//  TensorIO
//
//  Created by Philip Dow on 7/13/18.
//  Copyright © 2018 doc.ai. All rights reserved.
//

#import "TIOTFLiteErrors.h"

NSError * const kTIOTFLiteModelLoadModelError = [NSError errorWithDomain:@"doc.ai.netrunner" code:101 userInfo:@{
    NSLocalizedDescriptionKey: @"Unable to load model from graph file"
}];

NSError * const kTIOTFLiteModelConstructInterpreterError = [NSError errorWithDomain:@"doc.ai.netrunner" code:102 userInfo:@{
    NSLocalizedDescriptionKey: @"Unable to construct interpreter"
}];

NSError * const kTIOTFLiteModelAllocateTensorsError = [NSError errorWithDomain:@"doc.ai.netrunner" code:103 userInfo:@{
    NSLocalizedDescriptionKey: @"Unable to allocate tensors"
}];
