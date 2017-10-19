//
//  YCPhotoAssetModel.m
//  1111
//
//  Created by 余成国 on 15/10/30.
//  Copyright © 2015年 YuChengGuo. All rights reserved.
//

#import "YCPhotoAssetModel.h"

@implementation YCPhotoAssetModel

- (id)initWithAsset:(PHAsset *)asset
{
    self = [super init];
    if (self) {
        _asset = asset;
        _isChecked = NO;
    }
    return self;
}

@end
