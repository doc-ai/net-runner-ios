//
//  TIOInMemoryBatchDataSource.m
//  TensorIO
//
//  Created by Phil Dow on 5/19/19.
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

#import "TIOInMemoryBatchDataSource.h"

@implementation TIOInMemoryBatchDataSource

- (instancetype)initWithBatch:(TIOBatch *)batch {
    if ((self=[super init])) {
        _batch = batch;
    }
    return self;
}

- (instancetype)initWithItem:(TIOBatchItem *)item {
    return [self initWithBatch:[[TIOBatch alloc] initWithItem:item]];
}

- (NSArray<NSString*>*)keys {
    return self.batch.keys;
}

- (NSUInteger)numberOfItems {
    return self.batch.count;
}

- (TIOBatchItem *)itemAtIndex:(NSUInteger)index {
    return [self.batch itemAtIndex:index];
}

@end
