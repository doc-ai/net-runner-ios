//
//  EvaluatorConstants.h
//  tflite_camera_example
//
//  Created by Philip Dow on 7/20/18.
//  Copyright © 2018 doc.ai. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

NSString * const kEvaluatorResultsKeyType = @"type";
NSString * const kEvaluatorResultsKeyPhoto = @"photo";
NSString * const kEvaluatorResultsKeyModel = @"model";
NSString * const kEvaluatorResultsKeyError = @"error";
NSString * const kEvaluatorResultsKeyErrorDescription = @"error_description";
NSString * const kEvaluatorResultsKeyEvaluation = @"evaluation";

NSString * const kEvaluatorResultsKeyAlbum = @"album";

// Supported source types

NSString * const kEvaluatorResultsKeyTypeAlbumPhoto = @"album_photo";
NSString * const kEvaluatorResultsKeyTypeFile = @"file";
NSString * const kEvaluatorResultsKeyTypeURL = @"url";

// Final evaluation results

NSString * const kEvaluatorResultsKeyPreprocessingLatency = @"preprocessor_latency";
NSString * const kEvaluatorResultsKeyInferenceLatency = @"inference_latency";
NSString * const kEvaluatorResultsKeyInferenceResults = @"inference_results";

NSString * const kEvaluatorResultsKeyPreprocessingError = @"preprocessor_error";
NSString * const kEvaluatorResultsKeyInferenceError = @"inference_error";

NS_ASSUME_NONNULL_END
