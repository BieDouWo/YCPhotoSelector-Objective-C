//
//  YCPhotoSelectorCell.h
//  1111
//
//  Created by 余成国 on 15/10/26.
//  Copyright © 2015年 YuChengGuo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YCPhotoSelectorModel.h"

@interface YCPhotoSelectorCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIView *lineView;            //分割线
@property (weak, nonatomic) IBOutlet UIImageView *albumImageView; //相册封面图
@property (weak, nonatomic) IBOutlet UILabel *albumNameLabel;     //相册名称
@property (weak, nonatomic) IBOutlet UILabel *albumNumLabel;      //当前相册图片视频数量

- (void)refreshPhotoSelectorModel:(YCPhotoSelectorModel *)model;

@end
