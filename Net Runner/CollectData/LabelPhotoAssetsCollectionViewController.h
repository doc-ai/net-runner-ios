//
//  LabelPhotoAssetsCollectionViewController.h
//  Net Runner
//
//  Created by Philip Dow on 7/24/18.
//  Copyright © 2018 doc.ai (http://doc.ai)
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

//  TODO: We are duplicating code in PhotoAssetsCollectionViewController and then relying on its cell implementation
//  ^^^^: Refactor and share

@import UIKit;
@import Photos;

@class TIOModelBundle;

NS_ASSUME_NONNULL_BEGIN

@interface LabelPhotoAssetsCollectionViewController : UICollectionViewController

@property (nonatomic) PHCachingImageManager *imageManager;
@property (nonatomic) PHAssetCollection *album;

// Labeling specific

@property TIOModelBundle *modelBundle;

- (IBAction)selectMultiple:(id)sender;
- (IBAction)takePicture:(id)sender;

@end

NS_ASSUME_NONNULL_END
