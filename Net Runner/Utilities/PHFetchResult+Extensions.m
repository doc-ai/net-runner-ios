//
//  PHFetchResult+Extensions.m
//  tflite_camera_example
//
//  Created by Philip Dow on 7/24/18.
//  Copyright © 2018 doc.ai. All rights reserved.
//

#import "PHFetchResult+Extensions.h"

@implementation PHFetchResult (Extensions)

- (NSArray<PHAsset*>*)allAssets {
    NSMutableArray<PHAsset*> *assets = [[NSMutableArray<PHAsset*> alloc] init];
    for ( PHAsset *asset in self ) {
        [assets addObject:asset];
    }
    return [assets copy];
}

@end
