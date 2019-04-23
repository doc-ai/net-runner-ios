//
//  UserDefaults.m
//  Net Runner
//
//  Created by Philip Dow on 7/23/18.
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

@import Foundation;

#import "UserDefaults.h"

NSString * const kPrefsShowInputBuffers         = @"app.ui.show-input-buffers";
NSString * const kPrefsShowInputBufferAlpha     = @"app.ui.show-input-buffer-alpha";
NSString * const kPrefsEvaluateIterations       = @"app.eval.number-of-iterations";
NSString * const kPrefsBuild7CleanedModelsDir   = @"app.build7.cleaned-models-dir";
NSString * const kPrefsVersionLast              = @"app.version.last";
