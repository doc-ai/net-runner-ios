//
//  TIOModelIdentifier.m
//  TensorIO
//
//  Created by Phil Dow on 6/28/19.
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


#import "TIOModelIdentifier.h"

@implementation TIOModelIdentifier

- (instancetype)initWithModelId:(NSString *)modelId hyperparametersId:(nullable NSString *)hyperparametersId checkpointsId:(nullable NSString *)checkpointId {
    if ((self=[super init])) {
        _modelId = modelId;
        _hyperparametersId = hyperparametersId;
        _checkpointId = checkpointId;
    }
    return self;
}

- (nullable instancetype)initWithBundleId:(NSString *)bundleId {
    NSURL *URL = [NSURL URLWithString:bundleId];
    
    if ( ![URL.scheme isEqualToString:@"tio"] ) {
        return nil;
    }
    
    NSArray<NSString*> *components = URL.pathComponents;
    
    if ( components.count != 7 ) {
        return nil;
    }
    
    if (   ![components[1] isEqualToString:@"models"]
        || ![components[3] isEqualToString:@"hyperparameters"]
        || ![components[5] isEqualToString:@"checkpoints"] ) {
        return nil;
    }

    return [self initWithModelId:components[2] hyperparametersId:components[4] checkpointsId:components[6]];
}

- (NSString *)description {
    NSString *ms = [NSString stringWithFormat:@"Model ID: %@", self.modelId];
    NSString *hs = [NSString stringWithFormat:@"Hyperparameters ID: %@", self.hyperparametersId];
    NSString *cs = [NSString stringWithFormat:@"Checkpoint ID: %@", self.checkpointId];
    return [NSString stringWithFormat:@"%@\n%@\n%@", ms, hs, cs];
}

@end
