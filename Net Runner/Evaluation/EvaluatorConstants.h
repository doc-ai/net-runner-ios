//
//  EvaluatorConstants.h
//  Net Runner
//
//  Created by Philip Dow on 7/20/18.
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

NS_ASSUME_NONNULL_BEGIN

// MARK: - Evaluation Keys

/**
 * The type of data being evaluated, for example, "album photo", "file", or "url".
 * See the supported evaluator result types below.
 */

extern NSString * const kEvaluatorResultsKeySourceType;

/**
 * A value that uniquely identifies the object being evaluated, for example
 * a photo asset identifier, filename, or url.
 */

extern NSString * const kEvaluatorResultsKeyImage;

/**
 * The unique identifier of the model which produced these results.
 */

extern NSString * const kEvaluatorResultsKeyModel;

/**
 * A boolean value indicating if any kind of error occurred during evaluation.
 */

extern NSString * const kEvaluatorResultsKeyError;

/**
 * A localized description of the error that occurred, if any.
 */

extern NSString * const kEvaluatorResultsKeyErrorDescription;

/**
 * A dictionary containing the results of the evaluation. See the final evaluation results
 * section below for keys contained in this dictionary.
 */

extern NSString * const kEvaluatorResultsKeyEvaluation;

// MARK: - Album photo evaluator keys

/**
 * The locally unique identifier of the album to which this album photo belongs.
 */

extern NSString * const kEvaluatorResultsKeyAlbum;

// MARK: - Supported evaluator result source types

/**
 * Source type album photo.
 */

extern NSString * const kEvaluatorResultsKeySourceTypeAlbumPhoto;

/**
 * Source type file.
 */

extern NSString * const kEvaluatorResultsKeySourceTypeFile;

/**
 * Source type URL.
 */

extern NSString * const kEvaluatorResultsKeySourceTypeURL;

// MARK: - Final evaluation results, produced by CVPixelBufferEvaluator

/**
 * Preprocess latency, double value, including all image transformations such as cropping
 * scaling, and color space conversion, but excluding the initial conversion to a `CVPixelBuffer`
 * representation and any normalization applied to the buffer.
 */

extern NSString * const kEvaluatorResultsKeyPreprocessingLatency;

/**
 * Time it takes in milliseconds, double value, to run inference with the model and input.
 */

extern NSString * const kEvaluatorResultsKeyInferenceLatency;

/**
 * Results produced by the model as a `ModelOutput` object.
 */

extern NSString * const kEvaluatorResultsKeyInferenceResults;

/**
 * Any error that occurred during input preprocessing. String value.
 */

extern NSString * const kEvaluatorResultsKeyPreprocessingError;

/**
 * Any error that occurred during inference. String value.
 */

extern NSString * const kEvaluatorResultsKeyInferenceError;

NS_ASSUME_NONNULL_END
