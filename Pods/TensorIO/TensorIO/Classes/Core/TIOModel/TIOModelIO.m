//
//  TIOModelIO.m
//  TensorIO
//
//  Created by Phil Dow on 6/25/19.
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

#import "TIOModelIO.h"
#import "TIOLayerInterface.h"

@implementation TIOModelIO

- (instancetype)initWithInputInterfaces:(NSArray<TIOLayerInterface*> *)inputInterfaces ouputInterfaces:(NSArray<TIOLayerInterface*> *)outputInterfaces {
    if ((self = [super init])) {
        _inputs = [[TIOModelIOList alloc] initWithLayerInterfaces:inputInterfaces];
        _outputs = [[TIOModelIOList alloc] initWithLayerInterfaces:outputInterfaces];
    }
    return self;
}

@end

// MARK: -

@implementation TIOModelIOList {
    NSArray<TIOLayerInterface*> *_indexedInterfaces;
    NSDictionary<NSString*,TIOLayerInterface*> *_namedInterfaces;
    NSDictionary<NSString*,NSNumber*> *_nameToIndex;
}

- (instancetype)initWithLayerInterfaces:(NSArray<TIOLayerInterface*> *)interfaces {
    if ((self=[super init])) {
        _indexedInterfaces = interfaces;
        
        NSMutableDictionary *namedInterfaces = NSMutableDictionary.dictionary;
        NSMutableDictionary *nameToIndex = NSMutableDictionary.dictionary;
        
        [interfaces enumerateObjectsUsingBlock:^(TIOLayerInterface * _Nonnull interface, NSUInteger idx, BOOL * _Nonnull stop) {
            namedInterfaces[interface.name] = interface;
            nameToIndex[interface.name] = @(idx);
        }];
        
        _namedInterfaces = namedInterfaces.copy;
        _nameToIndex = nameToIndex.copy;
        
    }
    return self;
}

// MARK: -

- (NSUInteger)count {
    return _indexedInterfaces.count;
}

- (NSArray<TIOLayerInterface*> *)all {
    return _indexedInterfaces;
}

- (NSArray<NSString*> *)keys {
    return _namedInterfaces.allKeys;
}

- (NSNumber *)indexForName:(NSString *)name {
    return _nameToIndex[name];
}

// MARK: -

- (TIOLayerInterface *)objectAtIndexedSubscript:(NSInteger)idx {
    return _indexedInterfaces[idx];
}

- (void)setObject:(TIOLayerInterface *)obj atIndexedSubscript:(NSInteger)idx {
    NSAssert(NO, @"Writing to an indexed subscript is not supported.");
}

- (TIOLayerInterface *)objectForKeyedSubscript:(NSString *)key {
    return _namedInterfaces[key];
}

- (void)setObject:(TIOLayerInterface *)obj forKeyedSubscript:(NSString *)key {
    NSAssert(NO, @"Writing to an indexed subscript is not supported.");
}

@end
