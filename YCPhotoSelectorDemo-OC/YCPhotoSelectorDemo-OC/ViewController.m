//
//  ViewController.m
//  YCPhotoSelectorDemo-OC
//
//  Created by 别逗我 on 2017/10/19.
//  Copyright © 2017年 YuChengGuo. All rights reserved.
//

#import "ViewController.h"
#import "YCPhotoSelectorVC.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (IBAction)goPhotoSelector:(id)sender
{
    YCPhotoSelectorVC *photoVC = [YCPhotoSelectorVC photoSelectorVC];
    
    //设置选择的类型 - 不限制类型
    photoVC.mediaType = PHAssetMediaTypeUnknown;
    
    //设置限制选择的个数
    photoVC.maxNum = 3;
    
    //弹出并设置代理
    [photoVC showInController:self delegate:self];
}

#pragma mark- YCPhotoSelectorVCDelegate
-(void)photoSelectorVC:(YCPhotoSelectorVC *)photoSelectorVC assetArr:(NSMutableArray *)assetArr
{
    PHAsset *asset = assetArr[assetArr.count - 1];
    
    //获取照片或视频缩略图
    CGFloat scale = [UIScreen mainScreen].scale;
    CGSize imageViewSize = CGSizeMake(100, 100);
    CGSize assetGridThumbnailSize = CGSizeMake(imageViewSize.width * scale, imageViewSize.height * scale);
    [[PHImageManager defaultManager] requestImageForAsset:asset
                                               targetSize:assetGridThumbnailSize
                                              contentMode:PHImageContentModeAspectFit
                                                  options:nil
                                            resultHandler:^(UIImage *result, NSDictionary *info) {
                                                
                                                _imageView.image = result;
                                            }];
    
    
    //判断选择的是照片
    if (asset.mediaType == PHAssetMediaTypeImage)
    {
        PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
        //  .Current:修改和调整过的图像
        //  .Unadjusted:递送未被修改的图像,递送JPEG
        //  .Original:递送原始质量最高格式的图像
        options.version = PHImageRequestOptionsVersionOriginal;
        [[PHImageManager defaultManager] requestImageDataForAsset:asset options:options resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
            
            NSURL *photoURL = info[@"PHImageFileURLKey"];
            NSString *photoPath = [photoURL path];
            NSString *photoName = [photoPath lastPathComponent];
            
            NSLog(@"照片名称:%@",photoName);
            NSLog(@"照片绝对路径:%@",photoPath);//这玩意好像是没有权限直接拷贝照片文件
            NSLog(@"照片大小:%f",imageData.length/(1024.0*1024.0));
        }];
    }
    //判断选择的是视频
    else if (asset.mediaType == PHAssetMediaTypeVideo)
    {
        [[PHImageManager defaultManager] requestAVAssetForVideo:asset options:nil resultHandler:^(AVAsset *asset, AVAudioMix *audioMix, NSDictionary *info) {
            
            if ([asset isKindOfClass:[AVURLAsset class]]) {
                //视频路径
                AVURLAsset *urlAsset = (AVURLAsset*)asset;
                NSURL *videoURL = urlAsset.URL;
                NSLog(@"视频路径:%@",videoURL);
                
                //视频绝对路径(可拷贝文件)
                NSString *videoPath;
                [videoURL getResourceValue:&videoPath forKey:NSURLPathKey error:nil];
                NSLog(@"视频绝对路径:%@",videoPath);
                
                //视频名字
                NSString *videoName;
                [videoURL getResourceValue:&videoName forKey:NSURLNameKey error:nil];
                NSLog(@"视频名字:%@",videoName);
                
                //视频大小
                NSNumber *videoSize;
                [videoURL getResourceValue:&videoSize forKey:NSURLFileSizeKey error:nil];
                NSLog(@"视频大小:%f",[videoSize floatValue]/(1024.0*1024.0));
                
                //视频时间
                NSLog(@"视频时间:%lld秒", urlAsset.duration.value/urlAsset.duration.timescale);
            }
        }];
    }
}

@end


