//
//  YCPhotoAssetCell.h
//  1111
//
//  Created by 余成国 on 15/10/28.
//  Copyright © 2015年 YuChengGuo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YCPhotoAssetModel.h"

@interface YCPhotoAssetCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *thumbnailImageView; //缩略图
@property (weak, nonatomic) IBOutlet UIView *checkedView;             //勾选模糊视图
@property (weak, nonatomic) IBOutlet UIView *highlightedView;         //高亮背景
@property (weak, nonatomic) IBOutlet UIView *videoBaseView;           //视频底视图
@property (weak, nonatomic) IBOutlet UIView *blackBaseView;           //视频半透明黑色背景
@property (weak, nonatomic) IBOutlet UILabel *videoTimeLabel;         //视频时间
@property (nonatomic, weak) YCPhotoAssetVC *photoAssetVC;

- (void)refreshPhotoAssetModel:(YCPhotoAssetModel *)model;

@end
