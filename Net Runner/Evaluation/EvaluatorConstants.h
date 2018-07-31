//
//  EvaluatorConstants.h
//  Net Runner
//
//  Created by Philip Dow on 7/20/18.
//  Copyright © 2018 doc.ai. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

// MARK: - Evaluation Keys

/**
 * The type of data being evaluated, for example, "album photo", "file", or "url".
 * See the supported evaluator result types below.
 */

NSString * const kEvaluatorResultsKeySourceType = @"type";

/**
 * A value that uniquely identifies the object being evaluated, for example
 * a photo asset identifier, filename, or url.
 */

NSString * const kEvaluatorResultsKeyImage = @"image";

/**
 * The unique identifier of the model which produced these results.
 */

NSString * const kEvaluatorResultsKeyModel = @"model";

/**
 * A boolean value indicating if any kind of error occurred during evaluation.
 */

NSString * const kEvaluatorResultsKeyError = @"error";

/**
 * A localized description of the error that occurred, if any.
 */

NSString * const kEvaluatorResultsKeyErrorDescription = @"error_description";

/**
 * A dictionary containing the results of the evaluation. See the final evaluation results
 * section below for keys contained in this dictionary.
 */

NSString * const kEvaluatorResultsKeyEvaluation = @"evaluation";

// MARK: - Album photo evaluator keys

/**
 * The locally unique identifier of the album to which this album photo belongs.
 */

NSString * const kEvaluatorResultsKeyAlbum = @"album";

// MARK: - Supported evaluator result source types

/**
 * Source type album photo.
 */

NSString * const kEvaluatorResultsKeySourceTypeAlbumPhoto = @"album_photo";

/**
 * Source type file.
 */

NSString * const kEvaluatorResultsKeySourceTypeFile = @"file";

/**
 * Source type URL.
 */

NSString * const kEvaluatorResultsKeySourceTypeURL = @"url";

// MARK: - Final evaluation results, produced by CVPixelBufferEvaluator

/**
 * Preprocess latency, double value, including all image transformations such as cropping
 * scaling, and color space conversion, but excluding the initial conversion to a `CVPixelBuffer`
 * representation and any normalization applied to the buffer.
 */

NSString * const kEvaluatorResultsKeyPreprocessingLatency = @"preprocessor_latency";

/**
 * Time it takes in milliseconds, double value, to run inference with the model and input.
 */

NSString * const kEvaluatorResultsKeyInferenceLatency = @"inference_latency";

/**
 * Results produced by the model as a `ModelOutput` object.
 */

NSString * const kEvaluatorResultsKeyInferenceResults = @"inference_results";

/**
 * Any error that occurred during input preprocessing. String value.
 */

NSString * const kEvaluatorResultsKeyPreprocessingError = @"preprocessor_error";

/**
 * Any error that occurred during inference. String value.
 */

NSString * const kEvaluatorResultsKeyInferenceError = @"inference_error";

NS_ASSUME_NONNULL_END
