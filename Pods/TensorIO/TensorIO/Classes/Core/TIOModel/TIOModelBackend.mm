//
//  TIOModelBackends.m
//  TensorIO
//
//  Created by Phil Dow on 4/18/19.
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

#import <Foundation/Foundation.h>

#import "TIOModelBackend.h"

// Backend Names

static NSString * const TIOBackendTFLite = @"tflite";
static NSString * const TIOBackendTensorFlow = @"tensorflow";

// Model Class Names

static NSString * const TIOModelClassNameTFLite = @"TIOTFLiteModel";
static NSString * const TIOModelClassNameTensorFlow = @"TIOTensorFlowModel";

// Resource Bundle Names

static NSString * const TIOTFLiteResourceBundle = @"TFLite.bundle";
static NSString * const TIOTensorFlowResourceBundle = @"TensorFlow.bundle";

// Backend Exception

static NSString * const TIONoBackendAvailableException = @"TIONoBackendAvailableException";
static NSString * const TIONoBackendAvailableReason =
    @"TensorIO 0.6.0 and greater require the inclusion of a backend "
    @"along with the core pod installation. Add pod 'TensorIO/TFLite' "
    @"or another backend to your podfile and run pod install.";

@implementation TIOModelBackend

// Available Backend
// Add your backend preprocessor definition and name to this method

+ (nullable NSString *)availableBackend {
    #ifdef TIO_TFLITE
        return TIOBackendTFLite;
    #elif TIO_TENSORFLOW
        return TIOBackendTensorFlow;
    #else
        @throw [NSException
            exceptionWithName:TIONoBackendAvailableException
            reason:TIONoBackendAvailableReason
            userInfo:nil];
        return nil;
    #endif
}

// Class Name for Backend
// Add your backend name and class name to this dictionary

+ (nullable NSString *)classNameForBackend:(NSString *)backend {
    static NSDictionary<NSString*,NSString*> *classnames = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        classnames = @{
            TIOBackendTFLite:       TIOModelClassNameTFLite,
            TIOBackendTensorFlow:   TIOModelClassNameTensorFlow
        };
    });
    
    return classnames[backend.lowercaseString];
}

+ (nullable NSBundle *)resourceBundleForBackend:(NSString *)backend {
    static NSDictionary<NSString*,NSString*> *bundles = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        bundles = @{
            TIOBackendTFLite:       TIOTFLiteResourceBundle,
            TIOBackendTensorFlow:   TIOTensorFlowResourceBundle
        };
    });
    
    NSBundle *frameworkBundle = [NSBundle bundleForClass:self.class];
    NSURL *resourceURL = [frameworkBundle.resourceURL URLByAppendingPathComponent:bundles[backend.lowercaseString]];
    NSBundle *resourceBundle = [NSBundle bundleWithURL:resourceURL];
    
    return resourceBundle;
}

@end
