//
//  ClassificationModelOutput.m
//  Net Runner
//
//  Created by Phil Dow on 2/14/19.
//  Copyright © 2019 doc.ai. All rights reserved.
//

#import "NoDecayClassificationModelOutput.h"
#import "NSArray+TIOExtensions.h"

static NSString * const kClassificationOutputKey = @"classification";

@interface NoDecayClassificationModelOutput ()

@property (readwrite) NSDictionary *output;

@end

@implementation NoDecayClassificationModelOutput

- (instancetype)initWithDictionary:(NSDictionary*)dictionary {
    if (self = [super init]) {
        _output = @{
            kClassificationOutputKey: dictionary[kClassificationOutputKey]
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
    
    NSArray *keys = classifications.allKeys;
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
    return self;
}

@end
