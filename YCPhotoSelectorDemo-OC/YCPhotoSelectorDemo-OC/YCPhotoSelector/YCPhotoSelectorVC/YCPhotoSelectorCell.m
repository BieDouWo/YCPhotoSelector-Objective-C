//
//  YCPhotoSelectorCell.m
//  1111
//
//  Created by 余成国 on 15/10/26.
//  Copyright © 2015年 YuChengGuo. All rights reserved.
//

#import "YCPhotoSelectorCell.h"

@interface YCPhotoSelectorCell()

@end

@implementation YCPhotoSelectorCell
{
    CGSize _thumbnailSize; //缩略图大小
}
#pragma mark- 加载视图
- (void)awakeFromNib
{
    [super awakeFromNib];
    //设置分割线
    [self addSubview:_lineView];
    
    //设置缩略图大小
    CGFloat scale = [UIScreen mainScreen].scale;
    CGSize imageViewSize = CGSizeMake(_albumImageView.frame.size.width, _albumImageView.frame.size.height);
    _thumbnailSize = CGSizeMake(imageViewSize.width * scale, imageViewSize.height * scale);
}
#pragma mark- 刷新数据
- (void)refreshPhotoSelectorModel:(YCPhotoSelectorModel *)model
{
    _albumNameLabel.text = model.albumName;
    _albumNumLabel.text = [NSString stringWithFormat:@"%zd", model.albumNum];
    //设置封面图
    [[PHImageManager defaultManager] requestImageForAsset:model.asset
                                               targetSize:_thumbnailSize
                                              contentMode:PHImageContentModeAspectFill
                                                  options:nil
                                            resultHandler:^(UIImage *result, NSDictionary *info) {
                                                _albumImageView.image = result;
                                            }];
}

@end

