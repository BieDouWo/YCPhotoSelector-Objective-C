//
//  YCPhotoSelectorVC.m
//  1111
//
//  Created by 余成国 on 15/10/26.
//  Copyright © 2015年 YuChengGuo. All rights reserved.
//

#import "YCPhotoSelectorVC.h"
#import "YCPhotoSelectorCell.h"
#import "YCPhotoAssetVC.h"

@interface YCPhotoSelectorVC () <PHPhotoLibraryChangeObserver>
@property (weak, nonatomic) IBOutlet UITableView *photoSelectorTableView;
@property (weak, nonatomic) IBOutlet UIView *permissionsBaseView; //没有权限的提示视图
@property (weak, nonatomic) IBOutlet UIView *noDataBaseView;      //没有数据的提示视图

@end

@implementation YCPhotoSelectorVC
{
    NSString *_photoSelectorCellID;
    NSMutableArray *_fetchResultArr;
    NSMutableArray *_photoSelectorArr;
}
#pragma mark- 释放资源
- (void)dealloc
{
    [[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver:self];
}
#pragma mark- 加方法实例化
+ (YCPhotoSelectorVC *)photoSelectorVC
{
    YCPhotoSelectorVC *photoSelectorVC = [[YCPhotoSelectorVC alloc] initWithNibName:@"YCPhotoSelectorVC" bundle:nil];
    photoSelectorVC.mediaType = PHAssetMediaTypeImage;
    photoSelectorVC.maxNum = 100;
    
    return photoSelectorVC;
}
#pragma mark- 加载视图
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = @"相薄";
    _photoSelectorArr = [NSMutableArray array];
    _fetchResultArr = [NSMutableArray array];
   
    //设置取消按钮
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(cancel)];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    //设置头部和尾部分割线
    CGFloat w = ([[UIScreen mainScreen] bounds].size.width);
    UIView *headLineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, w, 0.5)];
    headLineView.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.6];
    _photoSelectorTableView.tableHeaderView = headLineView;
    _photoSelectorTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    //注册cell
    _photoSelectorCellID = @"YCPhotoSelectorCell";
    [_photoSelectorTableView registerNib:[UINib nibWithNibName:_photoSelectorCellID bundle:nil] forCellReuseIdentifier:_photoSelectorCellID];
    
    //判断有权限访问系统相册(用户去开启或关闭都会重启app的)
    if ([self isAlbumPermission]) {
        _permissionsBaseView.hidden = YES;
    }
    
    //初始化相册资源
    [self photoLibraryDidChange:[[PHChange alloc] init]];
#if 0
    //列出所有相册智能相册(PHAssetCollectionTypeSmartAlbum:从iTunes同步来的相册,以及用户在Photos中自己建立的相册 PHAssetCollectionSubtypeSmartAlbumVideos:相机拍摄的视频)
    PHFetchResult *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumVideos options:nil];
#endif

    //装入数组
    //_fetchResultArr = @[allPhotos,topLevelUserCollections];
    
    //监听系统相册变化
    [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
}
#pragma mark- 弹出
- (void)showInController:(UIViewController *)controller delegate:(id)delegate
{
    _delegate = delegate;
    UINavigationController *naVC = [[UINavigationController alloc] initWithRootViewController:self];
    [controller presentViewController:naVC animated:YES completion:nil];
}
#pragma mark- UITableView代理
//多少组
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
//多少行
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _photoSelectorArr.count;
}
//cell高
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}
//返回cell
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    YCPhotoSelectorCell *cell = [tableView dequeueReusableCellWithIdentifier:_photoSelectorCellID];
    [cell refreshPhotoSelectorModel:_photoSelectorArr[indexPath.row]];
    return cell;
#if 0
    PHFetchResult *fetchResult = _fetchResultArr[indexPath.section];
    if (indexPath.section == 0) {
        cell.albumNameLabel.text = @"相机胶卷";
        cell.albumNumLabel.text = [NSString stringWithFormat:@"%zd", fetchResult.count];
    }else{
        //获取当前目录
        PHAssetCollection *assetCollection = fetchResult[indexPath.row];
        cell.albumNameLabel.text = assetCollection.localizedTitle;
        
        //当前目录所有资源
        fetchResult = [PHAsset fetchAssetsInAssetCollection:assetCollection options:nil];
        cell.albumNumLabel.text = [NSString stringWithFormat:@"%zd", fetchResult.count];
    }
    if (fetchResult.count > 0) {
        //获取当前目录下最后一个资源
        PHAsset *asset = fetchResult[fetchResult.count -      1];
        //设置封面图
        CGFloat scale = [UIScreen mainScreen].scale;
        CGSize imageViewSize = CGSizeMake(cell.albumImageView.frame.size.width, cell.albumImageView.frame.size.height);
        CGSize assetGridThumbnailSize = CGSizeMake(imageViewSize.width * scale, imageViewSize.height * scale);
        [_imageManager requestImageForAsset:asset
                                 targetSize:assetGridThumbnailSize
                                contentMode:PHImageContentModeAspectFill
                                    options:nil
                              resultHandler:^(UIImage *result, NSDictionary *info) {
                                  cell.albumImageView.image=result;
                              }];
    }
    return cell;
#endif
}
//点击cell
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    YCPhotoSelectorModel *model = _photoSelectorArr[indexPath.row];
    YCPhotoAssetVC *photoAssetVC = [[YCPhotoAssetVC alloc] initWithNibName:@"YCPhotoAssetVC" bundle:nil];
    photoAssetVC.mediaType = _mediaType;
    photoAssetVC.maxNum = _maxNum;
    photoAssetVC.delegate = _delegate;
    photoAssetVC.fetchResult = model.fetchResult;
    photoAssetVC.directoryTitle = model.albumName;
    photoAssetVC.assetArr = model.assetArr;
    [self.navigationController pushViewController:photoAssetVC animated:YES];
#if 0
    PHFetchResult *fetchResult = _fetchResultArr[indexPath.section];
    NSString *directoryTitle = nil;
    if (indexPath.section == 0) {
        directoryTitle = @"相机胶卷";
    }else{
        //获取当前目录
        PHAssetCollection *assetCollection = fetchResult[indexPath.row];
        //当前目录所有资源
        fetchResult = [PHAsset fetchAssetsInAssetCollection:assetCollection options:nil];
        
        directoryTitle = assetCollection.localizedTitle;
    }
#endif
}
#pragma mark- 监听系统相册变化
- (void)photoLibraryDidChange:(PHChange *)changeInstance
{
    //必须主线程进行
    dispatch_async(dispatch_get_main_queue(), ^{
        [_photoSelectorArr removeAllObjects];
        
        //获取所有资源的集合,并按资源的创建时间排序
        PHFetchOptions *allPhotosOptions = [[PHFetchOptions alloc] init];
        //allPhotosOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
        PHFetchResult *allPhotos;
        //PHAssetMediaTypeUnknown:这个是未知的
        if (_mediaType == PHAssetMediaTypeUnknown) {
            allPhotos = [PHAsset fetchAssetsWithOptions:allPhotosOptions];
        }else{
            allPhotos = [PHAsset fetchAssetsWithMediaType:_mediaType options:allPhotosOptions];
        }
        //判断资源大于0
        if (allPhotos.count > 0) {
            YCPhotoSelectorModel *model = [[YCPhotoSelectorModel alloc] init];
            model.fetchResult = allPhotos;
            model.albumName = @"相机胶卷";
            model.albumNum = allPhotos.count;
            //取出所以资源装到数组
            NSMutableArray *assetArr = [NSMutableArray array];
            for (NSInteger j = 0; j < allPhotos.count; ++j) {
                PHAsset *asset = allPhotos[j];
                [assetArr addObject:asset];
            }
            model.assetArr = assetArr;
            
            //设置封面图
            model.asset = model.assetArr[model.assetArr.count - 1];
            [_photoSelectorArr addObject:model];
        }
        
        //列出所有用户创建的相册
        PHFetchResult *topLevelUserCollections = [PHCollectionList fetchTopLevelUserCollectionsWithOptions:nil];
        //遍历所有用户创建的相册
        for (NSInteger i = 0; i < topLevelUserCollections.count; ++i) {
            //获取当前目录
            PHAssetCollection *assetCollection = topLevelUserCollections[i];
            PHFetchResult *fetchResult = [PHAsset fetchAssetsInAssetCollection:assetCollection options:nil];
            //判断当前目录资源大于0
            if (fetchResult.count > 0) {
                //找出符合筛选条件的资源
                NSMutableArray *assetArr = [NSMutableArray array];
                for (NSInteger j = 0; j < fetchResult.count; ++j) {
                    PHAsset *asset = fetchResult[j];
                    //视频或图片
                    if (asset.mediaType == _mediaType && _mediaType != PHAssetMediaTypeUnknown) {
                        [assetArr addObject:asset];
                    }
                    //全部
                    if (_mediaType == PHAssetMediaTypeUnknown) {
                        [assetArr addObject:asset];
                    }
                }
                //判断筛选后当前目录资源大于0
                if (assetArr.count > 0) {
                    YCPhotoSelectorModel *model = [[YCPhotoSelectorModel alloc] init];
                    model.fetchResult = fetchResult;
                    model.albumName = assetCollection.localizedTitle;
                    model.albumNum = assetArr.count;
                    model.assetArr = assetArr;
                    
                    //设置封面图
                    model.asset = model.assetArr[model.assetArr.count - 1];
                    [_photoSelectorArr addObject:model];
                }
            }
        }
        [_photoSelectorTableView reloadData];
        //判断没有一个数据
        _noDataBaseView.hidden = _photoSelectorArr.count == 0 ? NO : YES;
    });
}
#pragma mark- 判断是否有权限访问相册
- (BOOL)isAlbumPermission
{
    PHAuthorizationStatus author = [PHPhotoLibrary authorizationStatus];
    if (author == PHAuthorizationStatusRestricted || author == PHAuthorizationStatusDenied) {
        return NO;//无权限
    }
    return YES;
}
#pragma mark- 取消选择
- (void)cancel
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end



