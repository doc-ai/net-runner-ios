//
//  ModelBundleJSONSchema.h
//  Net Runner
//
//  Created by Philip Dow on 7/16/18.
//  Copyright © 2018 doc.ai. All rights reserved.
//

#ifndef ModelBundleJSONSchema_h
#define ModelBundleJSONSchema_h

// TODO: update this schema definition

/**
{
    "name":         String,
    "id":           String,
    "details":      String,
    "author":       String,
    "license":      String,
 
    "model": {
        "quantized":    Bool,                   // true if model is quantized, false otherwise
        "file":         String,                 // filename of model in bundle directory, e.g. model.tflite
        "class":        String,                 // optional class to use with this model
    },
 
    "inputs": [
        {
            "name":         String,
            "type":         String,             // "image" | "array"
            "shape":        [Int, ...],         // [width, height, channels] for an image input
            "quantize":     {                   // quantization for array inputs
                "standard":     String,         // "[0,1]" | "[-1,1]"
                "scale":        Float,
                "bias":         Float,
            },
            "format":       String,             // "RGB" | "BGR" for image inputs
            "normalize":    {                   // normalization for image inputs
                "standard":     String,         // "[0,1]" | "[-1,1]"
                "scale:         Float,
                "bias": {
                    "r":        Float,
                    "g":        Float,
                    "b":        Float,
                }
            }
        },
    ],
 
    "outputs": [
        {
            "name":         String,
            "type":         String,             // "image" | "array"
            "shape":        [Int, ...],         // [width, height, channels] for an image input
            "dequantize":     {                 // dequantization for array outputs
                "standard":     String,         // "[0,1]" | "[-1,1]"
                "scale":        Float,
                "bias":         Float,
            },
            "labels":       String              // optional name of file in assets folder
            "format":       String,             // "RGB" | "BGR" for image inputs
            "denormalize":    {                 // denormalization for image inputs
                "standard":     String,         // "[0,1]" | "[-1,1]"
                "scale:         Float,
                "bias": {
                    "r":        Float,
                    "g":        Float,
                    "b":        Float,
                }
            }
        },
    ],
    
    "options": {
        "device_position":  String          // "front" | "back" for models that prefer a camera device position
    }
 
    "input": {
        "type":         String,             // "image"
        "shape":        [Int, Int, Int],    // [width, height, channels] eg [224,224,3]
        "format":       String,             // "RGB" | "BGR"
        "normalize":    String,             // "[0,1]" | "[-1,1]"
        "scale":        Float,
        "bias": {
            "r":    Float,
            "g":    Float,
            "b":    Float,
        }
    },
}
*/

/**
 * Additional Notes
 *
 * Quantization and Dequantization
 * The presence of a "standard" field in the "quantize" and "dequantize" dictionaries overrides
 * the presence of the "bias" and "scale" fields in those dictionaries.
 *
 * Normalization and Denormalization
 * The presence of a "standard" field in the "normalize" and "denormalize" dictionaries overrides
 * the presence of the "bias" and "scale" fields in those dictionaries.
*/

#endif /* ModelBundleJSONSchema_h */

/*
"normalize": {
    "standard":     String      // "[0,1]" | "[-1,1]"
    "scale":        Float
    "red_bias":     Float
    "green_bias":   Float
    "blue_bias":    Float
}
*/

/*
"dequantize": {
    "standard":     String      // "[0,1]"
    "scale":        Float
    "bias":         Float
}
*/
