//
//  YCPhotoAssetCell.m
//  1111
//
//  Created by 余成国 on 15/10/28.
//  Copyright © 2015年 YuChengGuo. All rights reserved.
//

#import "YCPhotoAssetCell.h"

@implementation YCPhotoAssetCell

#pragma mark- 加视图
- (void)awakeFromNib
{
    [super awakeFromNib];
    //设置勾选背景颜色为偏白模糊
    _checkedView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.4];
}
#pragma mark- 高亮时
- (void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    _highlightedView.alpha = highlighted ? 0.5f : 0.0f;
}
#pragma mark- 刷新数据
- (void)refreshPhotoAssetModel:(YCPhotoAssetModel *)model
{
    //设置视频半透明黑色背景
    CGRect rect = _blackBaseView.frame;
    rect.size.width = self.frame.size.width;
    _blackBaseView.frame = rect;
    for (CALayer *layer in _blackBaseView.layer.sublayers) {
        if ([layer isKindOfClass:[CAGradientLayer class]]) {
            [layer removeFromSuperlayer];
        }
    }
    [self insertTransparentGradientInView:_blackBaseView];
    
    //设置缩略图
    [[PHImageManager defaultManager] requestImageForAsset:model.asset
                                               targetSize:_photoAssetVC.thumbnailSize
                                              contentMode:PHImageContentModeAspectFill
                                                  options:nil
                                            resultHandler:^(UIImage *result, NSDictionary *info) {
                                                _thumbnailImageView.image = result;
                                            }];
    
    //判断资源类型
    if (model.asset.mediaType == PHAssetMediaTypeVideo) {
        _videoBaseView.hidden = NO;
        NSInteger duration = model.asset.duration;
        NSInteger min = duration / 60;
        NSInteger sec = duration % 60;
        _videoTimeLabel.text = [NSString stringWithFormat:@"%02zd:%02zd", min, sec];
    }else{
        _videoBaseView.hidden = YES;
    }
    
    //判断是否勾选
    if (model.isChecked) {
        _checkedView.hidden = NO;  //显示勾选图标
    }else{
        _checkedView.hidden = YES; //隐藏勾选图标
    }
}
#pragma mark- 设置view渐变黑色背景
- (void)insertTransparentGradientInView:(UIView *)view
{
    UIColor *colorOne = [UIColor colorWithRed:(33/255.0)  green:(33/255.0)  blue:(33/255.0)  alpha:0.0];
    UIColor *colorTwo = [UIColor colorWithRed:(33/255.0)  green:(33/255.0)  blue:(33/255.0)  alpha:0.5];
    NSArray *colors = [NSArray arrayWithObjects:(id)colorOne.CGColor, colorTwo.CGColor, nil];
    NSNumber *stopOne = [NSNumber numberWithFloat:0.0];
    NSNumber *stopTwo = [NSNumber numberWithFloat:0.5];
    NSArray *locations = [NSArray arrayWithObjects:stopOne, stopTwo, nil];
    
    CAGradientLayer *headerLayer = [CAGradientLayer layer];
    headerLayer.colors = colors;
    headerLayer.locations = locations;
    headerLayer.frame = view.bounds;
    headerLayer.startPoint = CGPointMake(0.0, 0.0);
    headerLayer.endPoint = CGPointMake(0.0, 2.0);
    [view.layer insertSublayer:headerLayer atIndex:0];
}

@end



