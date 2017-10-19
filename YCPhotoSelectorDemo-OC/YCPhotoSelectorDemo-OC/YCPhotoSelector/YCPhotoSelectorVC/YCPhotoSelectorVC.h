//
//  YCPhotoSelectorVC.h
//  1111
//
//  Created by 余成国 on 15/10/26.
//  Copyright © 2015年 YuChengGuo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>
//#import <PhotosUI/PhotosUI.h>

@class YCPhotoSelectorVC;
@protocol YCPhotoSelectorVCDelegate <NSObject>
- (void)photoSelectorVC:(YCPhotoSelectorVC *)photoSelectorVC assetArr:(NSMutableArray *)assetArr;

@end

@interface YCPhotoSelectorVC : UIViewController
@property (nonatomic, assign) PHAssetMediaType mediaType; //筛选类型(默认只有照片)
@property (nonatomic, assign) NSInteger maxNum;           //最多选择的项(默认最多100张)
@property (nonatomic, weak) id <YCPhotoSelectorVCDelegate> delegate;

+ (YCPhotoSelectorVC *)photoSelectorVC;
- (void)showInController:(UIViewController *)controller delegate:(id)delegate;

@end
