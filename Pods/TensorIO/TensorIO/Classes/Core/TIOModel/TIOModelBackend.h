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

NS_ASSUME_NONNULL_BEGIN

/**
 * Returns the available backend or the first one it finds
 *
 * When you define a backend in the Podspec, you should also add a
 * `GCC_PREPROCESSOR_DEFINITIONS` that defines your backend. Return the name
 * of the backend here if that preprocessor definition is defined.
 */

NSString * _Nullable TIOAvailableBackend();

/**
 * Returns the default model class name used with a backend
 *
 * When you create a new backend for tensorflow note your backend
 * name and class name in this function. Test that you backend
 * returns the correct class name in TIOModelBackendsTests.
 */

NSString * _Nullable TIOClassNameForBackend(NSString *backend);

NS_ASSUME_NONNULL_END
