//
//  ImageNetClassificationHelpers.h
//  Net Runner
//
//  Created by Philip Dow on 7/13/18.
//  Copyright © 2018 doc.ai. All rights reserved.
//

#ifndef ImageNetClassificationHelpers_h
#define ImageNetClassificationHelpers_h

#import <Foundation/Foundation.h>

#include <vector>
#include <iostream>
#include <fstream>
#include <queue>

/**
 * Loads the output labels used by the model
 */

void LoadLabels(NSString* labels_path, std::vector<std::string>* label_strings);

// MARK: - Template Methods

/**
 * Returns the top N confidence values over threshold in the provided vector,
 * sorted by confidence in descending order.
 *
 * weight_t will be of type float_t (32 bits) or uint8_t for quantized models
 */

template <typename weight_t>
void GetTopN(const weight_t* prediction, const int prediction_size, const int num_results, const float threshold, std::vector<std::pair<float, int>>* top_results) {
    // Will contain top N results in ascending order.
    std::priority_queue<std::pair<float, int>, std::vector<std::pair<float, int>>, std::greater<std::pair<float, int>>> top_result_pq;

    for (int i = 0; i < prediction_size; ++i) {
        
        // pdow: dequantize quantized models by dividing the prediction by 255.0,
        // normalizing the output and ensuring it is a valid probability distribution
        
        const float p_adjustment = sizeof(weight_t) == 4 ? 1.0 : 255.0;
        const float value = prediction[i] / p_adjustment;
        
        // Only add it if it beats the threshold and has a chance at being in the top N.
        
        if (value < threshold) {
            continue;
        }

        top_result_pq.push(std::pair<float, int>(value, i));

        // If at capacity, kick the smallest value out.
        
        if (top_result_pq.size() > num_results) {
            top_result_pq.pop();
        }
    }

    // Copy to output vector and reverse into descending order.
    
    while (!top_result_pq.empty()) {
        top_results->push_back(top_result_pq.top());
        top_result_pq.pop();
    }
    
    std::reverse(top_results->begin(), top_results->end());
}

/**
 * Capture the model output, returning the top N confidence values over threshold in the provided vector,
 * sorted by confidence in descending order.
 *
 * N is defined as 5 and threshold as 0.1
 *
 * weight_t will be of type float_t (32 bits) or uint8_t for quantized models
 */

template <typename weight_t>
NSDictionary* CaptureOutput(weight_t* output, std::vector<std::string> labels) {
    const int output_size = 1000;
    const int kNumResults = 5;
    const float kThreshold = 0.1f;

    std::vector<std::pair<float, int>> top_results;
    
    GetTopN(output, output_size, kNumResults, kThreshold, &top_results);

    NSMutableDictionary* newValues = [NSMutableDictionary dictionary];
    for (const auto& result : top_results) {
        const float confidence = result.first;
        const int index = result.second;
        NSString* labelObject = [NSString stringWithUTF8String:labels[index].c_str()];
        NSNumber* valueObject = [NSNumber numberWithFloat:confidence];
        [newValues setObject:valueObject forKey:labelObject];
    }
    
    return newValues;
}

#endif /* ImageNetClassificationHelpers_h */
