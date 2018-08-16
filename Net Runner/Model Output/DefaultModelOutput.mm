//
//  DefaultModelOutput.m
//  Net Runner
//
//  Created by Philip Dow on 8/16/18.
//  Copyright © 2018 doc.ai. All rights reserved.
//

#import "DefaultModelOutput.h"

@interface DefaultModelOutput ()

@property (readwrite) NSDictionary *output;

@end

@implementation DefaultModelOutput

- (instancetype)initWithDictionary:(NSDictionary<NSString*,NSNumber*>*)dictionary {
    if (self = [super init]) {
        _output = dictionary;
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
    
    if ( self.output.count == 0 ) {
        return @"";
    }
    
    NSMutableString *description = [NSMutableString string];
    
    for ( NSString *key in self.output ) {
        NSNumber *value = self.output[key];
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
