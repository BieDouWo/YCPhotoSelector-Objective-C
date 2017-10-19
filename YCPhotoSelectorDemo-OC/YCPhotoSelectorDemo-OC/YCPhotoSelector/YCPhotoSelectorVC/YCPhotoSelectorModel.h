//
//  YCPhotoSelectorModel.h
//  1111
//
//  Created by 余成国 on 15/10/30.
//  Copyright © 2015年 YuChengGuo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YCPhotoSelectorVC.h"

@interface YCPhotoSelectorModel : NSObject
@property (nonatomic, strong) PHFetchResult *fetchResult; //当前目录
@property (nonatomic, strong) PHAsset *asset;             //相册封面图
@property (nonatomic, copy) NSString *albumName;          //相册名称
@property (nonatomic, assign) NSInteger albumNum;         //当前相册资源数量
@property (nonatomic, strong) NSMutableArray *assetArr;   //当前相册资源

@end
