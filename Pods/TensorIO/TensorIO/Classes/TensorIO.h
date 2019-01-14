//
//  TensorIO.h
//  TensorIO
//
//  Created by Philip Dow on 7/10/18.
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

// Model

#import "TIOModel.h"
#import "TIOModelBundle.h"
#import "TIOModelBundleManager.h"
#import "TIOModelBundleValidator.h"
#import "TIOModelJSONParsing.h"
#import "TIOModelOptions.h"
#import "TIOPixelNormalization.h"
#import "TIOPlaceholderModel.h"
#import "TIOQuantization.h"
#import "TIOVisionModelHelpers.h"
#import "TIOVisionPipeline.h"

// Layer Interface

#import "TIOLayerDescription.h"
#import "TIOLayerInterface.h"
#import "TIOPixelBufferLayerDescription.h"
#import "TIOVectorLayerDescription.h"

// TFLite Model

#import "TIOTFLiteModel.h"
#import "TIOTFLiteErrors.h"

// Data

#import "TIOData.h"
#import "TIOVector.h"
#import "TIOPixelBuffer.h"
#import "NSArray+TIOData.h"
#import "NSData+TIOData.h"
#import "NSDictionary+TIOData.h"
#import "NSNumber+TIOData.h"

// Utilities

#import "NSArray+TIOExtensions.h"
#import "NSDictionary+TIOExtensions.h"
#import "UIImage+TIOCVPixelBufferExtensions.h"
#import "TIOCVPixelBufferHelpers.h"
#import "TIOObjcDefer.h"
