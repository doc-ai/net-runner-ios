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

/*
{
    "name":         String,
    "id":           String,
    "details":      String,
    "author":       String,
    "license":      String,
 
    "model": {
        "quantized":    Bool,
        "file":         String,
        "class":        String,
        "labels":       String,             // Or any other info
    },
 
    "inputs": [
 
    ],
 
    "outputs": [
 
    ],
    
    "options": {
        "device_position":  String          // "front" | "back"
    }
 
    "input": {
        "type":         String,             // "image"
        "shape":        [Int, Int, Int],    // [width, height, channgels] eg [224,224,3]
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

/*
    The presence of a input.normalize field overrides the input.scale and input.bias fields
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
