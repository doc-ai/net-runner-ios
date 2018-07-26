//
//  EvaluatePhotoAlbumTableViewCell.h
//  tflite_camera_example
//
//  Created by Philip Dow on 7/17/18.
//  Copyright © 2018 doc.ai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

NS_ASSUME_NONNULL_BEGIN

@protocol EvaluatePhotoAlbumTableViewCellActionTarget <NSObject>

- (void)didSwitchAlbum:(PHAssetCollection*)album toSelected:(BOOL)selected;

@end

// MARK: -

@interface EvaluatePhotoAlbumTableViewCell : UITableViewCell

@property (weak) IBOutlet UIImageView *albumImageView;
@property (weak) IBOutlet UILabel *titleLabel;
@property (weak) IBOutlet UISwitch *selectedSwitch;

@property (weak) id<EvaluatePhotoAlbumTableViewCellActionTarget> actionTarget;
@property (nonatomic) PHAssetCollection *album;

- (IBAction)selectedSwitchAction:(UISwitch*)sender;

@end

NS_ASSUME_NONNULL_END
