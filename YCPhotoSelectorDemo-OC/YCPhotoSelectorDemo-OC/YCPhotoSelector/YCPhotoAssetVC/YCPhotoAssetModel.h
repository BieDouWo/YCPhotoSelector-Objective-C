//
//  YCPhotoAssetModel.h
//  1111
//
//  Created by 余成国 on 15/10/30.
//  Copyright © 2015年 YuChengGuo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YCPhotoAssetVC.h"

@interface YCPhotoAssetModel : NSObject
@property (nonatomic, strong) PHAsset *asset; //资源
@property (nonatomic, assign) BOOL isChecked; //是否有勾选

- (id)initWithAsset:(PHAsset *)asset;

@end
