//
//  EvaluatorConstants.mm
//  Net Runner
//
//  Created by Philip Dow on 8/2/18.
//  Copyright © 2018 doc.ai. All rights reserved.
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
