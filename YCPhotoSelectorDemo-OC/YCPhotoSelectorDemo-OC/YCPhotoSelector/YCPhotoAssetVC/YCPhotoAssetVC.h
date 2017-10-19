//
//  YCPhotoAssetVC.h
//  1111
//
//  Created by 余成国 on 15/10/26.
//  Copyright © 2015年 YuChengGuo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YCPhotoSelectorVC.h"
@import Photos;

@interface YCPhotoAssetVC : UIViewController
@property (weak, nonatomic) IBOutlet UICollectionView *photoAssetCollectionView;
@property (weak, nonatomic) IBOutlet UIView *noDataBaseView;

@property (nonatomic, strong) UICollectionViewFlowLayout *layout;
@property (nonatomic, assign) CGSize thumbnailSize;
@property (nonatomic, strong) NSMutableArray *photoAssetArr;

@property (nonatomic, weak) YCPhotoSelectorVC *photoSelectorVC;
@property (nonatomic, assign) PHAssetMediaType mediaType;
@property (nonatomic, assign) NSInteger maxNum;
@property (nonatomic, weak) id <YCPhotoSelectorVCDelegate> delegate;

@property (nonatomic, strong) PHFetchResult *fetchResult; //当前目录
@property (nonatomic, copy) NSString *directoryTitle;
@property (nonatomic, strong) NSMutableArray *assetArr;

@end
