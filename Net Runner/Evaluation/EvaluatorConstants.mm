//
//  EvaluatorConstants.mm
//  Net Runner
//
//  Created by Philip Dow on 8/2/18.
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

#import "EvaluatorConstants.h"

// MARK: - Evaluation Keys

NSString * const kEvaluatorResultsKeySourceType = @"type";
NSString * const kEvaluatorResultsKeyImage = @"image";
NSString * const kEvaluatorResultsKeyModel = @"model";
NSString * const kEvaluatorResultsKeyError = @"error";
NSString * const kEvaluatorResultsKeyErrorDescription = @"error_description";
NSString * const kEvaluatorResultsKeyEvaluation = @"evaluation";

// MARK: - Album photo evaluator keys

NSString * const kEvaluatorResultsKeyAlbum = @"album";

// MARK: - Supported evaluator result source types

NSString * const kEvaluatorResultsKeySourceTypeAlbumPhoto = @"album_photo";
NSString * const kEvaluatorResultsKeySourceTypeFile = @"file";
NSString * const kEvaluatorResultsKeySourceTypeURL = @"url";

// MARK: - Final evaluation results, produced by CVPixelBufferEvaluator

NSString * const kEvaluatorResultsKeyPreprocessingLatency = @"preprocessor_latency";
NSString * const kEvaluatorResultsKeyInferenceLatency = @"inference_latency";
NSString * const kEvaluatorResultsKeyInferenceResults = @"inference_results";
NSString * const kEvaluatorResultsKeyPreprocessingError = @"preprocessor_error";
NSString * const kEvaluatorResultsKeyInferenceError = @"inference_error";
