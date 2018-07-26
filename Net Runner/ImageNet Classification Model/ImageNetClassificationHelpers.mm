//
//  ImageNetClassificationHelpers.mm
//  tflite_camera_example
//
//  Created by Philip Dow on 7/13/18.
//  Copyright © 2018 doc.ai. All rights reserved.
//

#include "ImageNetClassificationHelpers.h"

void LoadLabels(NSString* labels_path, std::vector<std::string>* label_strings) {
    std::ifstream t;
    t.open([labels_path UTF8String]);
    std::string line;
    while (t) {
        std::getline(t, line);
        label_strings->push_back(line);
    }
    t.close();
}
