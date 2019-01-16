//
//  ImageModelLabelsExporter.m
//  Net Runner
//
//  Created by Philip Dow on 1/9/19.
//  Copyright © 2019 doc.ai (http://doc.ai)
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

#import "ImageModelLabelsExporter.h"
#import "ImageModelLabelsDatabase.h"
#import "ImageModelLabels.h"

#define IMAGE_SIZE 512

NSString * PathSafeString(NSString * string) {
    return [[string
        stringByReplacingOccurrencesOfString:@"/" withString:@"-"]
        stringByReplacingOccurrencesOfString:@":" withString:@"-"];
}

@interface ImageModelLabelsExporter()

@end

@implementation ImageModelLabelsExporter

+ (PHImageRequestOptions*)imageRequestOptions {
    static PHImageRequestOptions *options = nil;
    
    if ( options != nil ) {
        return options;
    }
    
    options = [[PHImageRequestOptions alloc] init];
    
    options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    options.resizeMode = PHImageRequestOptionsResizeModeFast; // PHImageRequestOptionsResizeModeExact
    options.networkAccessAllowed = YES;
    options.synchronous = YES;
    
    return options;
}

+ (PHFetchOptions*)fetchOptions {
    static PHFetchOptions *options = nil;
    
    if ( options != nil ) {
        return options;
    }
    
    PHFetchOptions *fetchOptions = [[PHFetchOptions alloc] init];
    
    fetchOptions.includeAllBurstAssets = NO;
    fetchOptions.includeHiddenAssets = NO;
    
    return options;
}

- (id)initWithDatabase:(ImageModelLabelsDatabase*)database {
    if ((self=[super init])) {
        _database = database;
    }
    return self;
}

- (BOOL)exportTo:(NSString*)path {
    NSArray<ImageModelLabels*> *labels = self.database.allLabels;
    NSMutableArray<NSString*> *identifiers = [[NSMutableArray alloc] init];
    NSMutableDictionary<NSString*,ImageModelLabels*> *labelsByIdentifier = [[NSMutableDictionary alloc] init];
    
    NSMutableArray<NSDictionary*> *labelDictionaries = [[NSMutableArray alloc] init];
    
    // Prepare a temporary directory to hold our contents
    
    NSError *fileError;
    NSURL *tmpDirectory = [NSURL fileURLWithPath:NSTemporaryDirectory() isDirectory:YES];
    tmpDirectory = [tmpDirectory URLByAppendingPathComponent:NSProcessInfo.processInfo.globallyUniqueString];
    
    if (![NSFileManager.defaultManager createDirectoryAtURL:tmpDirectory withIntermediateDirectories:YES attributes:nil error:&fileError]) {
        NSLog(@"Unable to create temporary destination directory for export at path %@, error: %@", tmpDirectory, fileError);
        return NO;
    }
    
    // Iterate through each set of labels, noting the identifiers and mapping from identifier to labels
    
    // The identifiers array will be used to request image assets. Because the photo library may
    // return fewer image assets than we have identifiers for (in case an image has been deleted),
    // only include labels for the available images in the final labelDictionaries dict that is
    // converted to JSON.
    
    for (ImageModelLabels *label in labels) {
        [identifiers addObject:label.identifier];
        labelsByIdentifier[label.identifier] = label;
    }
    
    // Acquire the image assets and write them out
    
    PHFetchResult<PHAsset *> *assets = [PHAsset fetchAssetsWithLocalIdentifiers:identifiers options:ImageModelLabelsExporter.fetchOptions];
    
    PHImageRequestOptions *imageRequestOptions = ImageModelLabelsExporter.imageRequestOptions;
    CGSize size = CGSizeMake(IMAGE_SIZE, IMAGE_SIZE); // PHImageManagerMaximumSize
    PHImageContentMode contentMode = PHImageContentModeAspectFit; // PHImageContentModeAspectFill
    
    [assets enumerateObjectsUsingBlock:^(PHAsset * _Nonnull asset, NSUInteger idx, BOOL * _Nonnull stop) {
        [[PHImageManager defaultManager]
            requestImageForAsset:asset
            targetSize:size
            contentMode:contentMode
            options:imageRequestOptions
            resultHandler:^(UIImage *result, NSDictionary *info) {
            
                // Write the image
                
                NSString *imageFilename = [NSString stringWithFormat:@"%@.jpg", PathSafeString(asset.localIdentifier)];
                NSURL *imageFilepath = [tmpDirectory URLByAppendingPathComponent:imageFilename];
                NSData *imageData = UIImageJPEGRepresentation(result, 1.0);
                NSError *imageError;
                
                if (![imageData writeToURL:imageFilepath options:NSDataWritingAtomic error:&imageError]) {
                    NSLog(@"Could not write image with identifier %@ to file, error: %@", asset.localIdentifier, imageData);
                } else {
                    // Prepare the JSON entry for the final labelDictionaries dict
                    ImageModelLabels *label = labelsByIdentifier[asset.localIdentifier];
                    NSMutableDictionary *l = label.labels.mutableCopy;
                    l[@"id"] = PathSafeString(label.identifier);
                    [labelDictionaries addObject:l.copy];
                }
            }
        ];
    }];
    
    // Write the JSON entry (labelDictionaries)
    
    NSError *JSONError;
    NSData *JSON = [NSJSONSerialization dataWithJSONObject:labelDictionaries options:NSJSONWritingPrettyPrinted error:&JSONError];
    
    if (JSONError) {
        NSLog(@"Could not serialize labels to JSON, error: %@", JSONError);
        return NO;
    }
    
    NSURL *JSONFilepath = [tmpDirectory URLByAppendingPathComponent:@"labels.json"];
    NSError *writeError;
    
    [JSON writeToURL:JSONFilepath options:NSDataWritingAtomic error:&writeError];
    
    if (writeError) {
        NSLog(@"Could not write JSON to file, error: %@", writeError);
        return NO;
    }
    
    // Zip the contents of the directory
    
    BOOL zipped = [SSZipArchive createZipFileAtPath:path withContentsOfDirectory:tmpDirectory.path];
    
    if (!zipped) {
        NSLog(@"Could not create zip file of contents at path %@ to %@", tmpDirectory.path, path);
        return NO;
    }
    
    return YES;
}

@end
