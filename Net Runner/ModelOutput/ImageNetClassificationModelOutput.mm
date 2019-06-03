//
//  ImageNetClassificationModelOutput.mm
//  Net Runner
//
//  Created by Philip Dow on 7/28/18.
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

#import "ImageNetClassificationModelOutput.h"

#import "NSArray+TIOExtensions.h"
#import "NSDictionary+TIOExtensions.h"

static NSString * const kClassificationOutputKey = @"classification";

@interface ImageNetClassificationModelOutput ()

@property (readwrite) NSDictionary *output;

@end

@implementation ImageNetClassificationModelOutput

- (instancetype)initWithDictionary:(NSDictionary*)dictionary {
    if (self = [super init]) {
        _output = @{
            kClassificationOutputKey: [dictionary[kClassificationOutputKey] topN:5 threshold:0.1]
        };
    }
    return self;
}

// MARK: -

- (id)value {
    return self.output;
}

- (id)propertyList {
    return self.output;
}

- (NSString*)description {
    return [self.output.description stringByReplacingOccurrencesOfString:@"\n" withString:@"\r"];
}

- (NSString*)localizedDescription {
    NSDictionary *classifications = self.output[kClassificationOutputKey];
    
    if ( classifications.count == 0 ) {
        return @"";
    }
    
    NSArray *keys = [classifications keysSortedByValueUsingSelector:@selector(compare:)].reversed;
    NSMutableString *description = [NSMutableString string];
    
    for ( NSString *key in keys ) {
        NSNumber *value = classifications[key];
        [description appendFormat:@"(%.2f) %@\n", value.floatValue, key];
    }
    
    if ( description.length > 0 ) {
        [description deleteCharactersInRange:NSMakeRange(description.length-1, 1)];
    }
    
    return description;
}

- (BOOL)isEqual:(id)anObject {
    if ( ![anObject isKindOfClass:self.class] ) {
        return NO;
    }
    
    return [self.output isEqual:[anObject output]];
}

// MARK: -

- (id<ModelOutput>)decayedOutput:(nullable id<ModelOutput>)previousOutput {
    if ( previousOutput == nil ) {
        return self;
    }
    
    NSAssert([previousOutput isKindOfClass:self.class], @"previousOutput is not same class as self: %@, %@", previousOutput.class, self.class);
    
    const float decayValue = 0.70f;
    const float updateValue = 0.30f;
    const float thresholdValue = 0.01f;
    
    NSMutableDictionary<NSString*,NSNumber*> *decayedInference = [NSMutableDictionary dictionary];
    NSDictionary<NSString*,NSNumber*> *previousInference = previousOutput.value[kClassificationOutputKey];
    NSDictionary<NSString*,NSNumber*> *newInference = self.value[kClassificationOutputKey];
    
    for ( NSString *key in previousInference ) {
        decayedInference[key] = @(previousInference[key].floatValue * decayValue);
    }
    
    for ( NSString *key in newInference ) {
        if ( decayedInference[key] == nil ) {
            decayedInference[key] = @(0.0f);
        }
        
        decayedInference[key] = @(decayedInference[key].floatValue + (newInference[key].floatValue * updateValue));
    }
    
    for ( NSString *key in decayedInference ) {
        if ( decayedInference[key].floatValue < thresholdValue ) {
            [decayedInference removeObjectForKey:key];
        }
    }
    
    return [[ImageNetClassificationModelOutput alloc] initWithDictionary:@{
        kClassificationOutputKey: decayedInference
    }];
}

@end
