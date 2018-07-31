//
//  PhotoAssetsCollectionViewController.h
//  Net Runner
//
//  Created by Philip Dow on 7/24/18.
//  Copyright © 2018 doc.ai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

NS_ASSUME_NONNULL_BEGIN

@interface PhotoAssetsCollectionViewController : UICollectionViewController

@property NSArray<PHAsset*> *assets;
@property PHCachingImageManager *imageManager;

@end

NS_ASSUME_NONNULL_END
