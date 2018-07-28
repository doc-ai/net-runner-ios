//
//  ModelJSONSchema.h
//  tflite_camera_example
//
//  Created by Philip Dow on 7/16/18.
//  Copyright © 2018 doc.ai. All rights reserved.
//

#ifndef ModelJSONSchema_h
#define ModelJSONSchema_h

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
    "options": {
        "device_position":  String          // "front" | "back"
    }
}
*/

/*
    The presence of a input.normalize field overrides the input.scale and input.bias fields
*/

#endif /* ModelJSONSchema_h */
