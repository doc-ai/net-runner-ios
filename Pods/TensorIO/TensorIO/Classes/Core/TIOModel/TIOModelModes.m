//
//  TIOModelModes.m
//  TensorIO
//
//  Created by Phil Dow on 4/30/19.
//  Copyright © 2019 doc.ai (http://doc.ai)
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

#import "TIOModelModes.h"

typedef NS_OPTIONS(NSUInteger, TIOModelMode) {
    TIOModelModePredict = 1 << 0,
    TIOModelModeTrain = 1 << 1,
    TIOModelModelEval = 1 << 2
};

static TIOModelMode TIOParseModelModes(NSArray<NSString*> * _Nullable array) {
    if (!array) {
        return TIOModelModePredict;
    }
    
    TIOModelMode modes = 0;
    
    if ([array containsObject:@"predict"]) {
        modes |= TIOModelModePredict;
    }
    if ([array containsObject:@"train"]) {
        modes |= TIOModelModeTrain;
    }
    if ([array containsObject:@"eval"]) {
        modes |= TIOModelModelEval;
    }
    
    return modes;
}

@interface TIOModelModes ()

@property TIOModelMode modes;

@end

@implementation TIOModelModes

- (instancetype)initWithArray:(nullable NSArray<NSString*>*)array {
    if ((self=[super init])) {
        _modes = TIOParseModelModes(array);
    }
    return self;
}

- (BOOL)predicts {
    return (_modes & TIOModelModePredict) == TIOModelModePredict;
}

- (BOOL)trains {
    return (_modes & TIOModelModeTrain) == TIOModelModeTrain;
}

- (BOOL)evals {
    return (_modes & TIOModelModelEval) == TIOModelModelEval;
}

@end
