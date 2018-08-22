//
//  ImageNetClassificationModelOutput.m
//  Net Runner
//
//  Created by Philip Dow on 7/28/18.
//  Copyright © 2018 doc.ai. All rights reserved.
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
    
    const float decayValue = 0.75f;
    const float updateValue = 0.25f;
    const float thresholdValue = 0.01f;
    
    NSMutableDictionary<NSString*,NSNumber*> *decayedInference = [NSMutableDictionary dictionary];
    NSDictionary<NSString*,NSNumber*> *previousInference = previousOutput.value[kClassificationOutputKey];
    NSDictionary<NSString*,NSNumber*> *newInference = self.value[kClassificationOutputKey];
    
    for ( NSString *key in previousInference ) {
        decayedInference[key] = previousInference[key];
    }
    
    for ( NSString *key in newInference ) {
        if ( decayedInference[key] == nil ) {
            decayedInference[key] = @(0.0f);
        }
        
        decayedInference[key] = @((decayedInference[key].floatValue * decayValue ) + (newInference[key].floatValue * updateValue));
        
        if ( decayedInference[key].floatValue < thresholdValue ) {
            [decayedInference removeObjectForKey:key];
        }
    }
    
    return [[ImageNetClassificationModelOutput alloc] initWithDictionary:@{
        kClassificationOutputKey: decayedInference
    }];
}

@end
