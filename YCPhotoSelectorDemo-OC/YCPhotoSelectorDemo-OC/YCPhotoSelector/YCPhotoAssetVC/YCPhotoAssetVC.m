//
//  YCPhotoAssetVC.m
//  1111
//
//  Created by 余成国 on 15/10/26.
//  Copyright © 2015年 YuChengGuo. All rights reserved.
//

#import "YCPhotoAssetVC.h"
#import "YCPhotoAssetModel.h"
#import "YCPhotoAssetCell.h"
#import "YCPhotoAssetFooterView.h"

#define SCREEN_WIDTH  ([[UIScreen mainScreen] bounds].size.width)
#define SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)

#define VERTICAL_COLS    4 //竖屏下照片多少列
#define HORIZONTAL_COLS  6 //横屏下照片多少列

@interface YCPhotoAssetVC ()<UICollectionViewDataSource, UICollectionViewDelegate, PHPhotoLibraryChangeObserver, UIGestureRecognizerDelegate>

@end

@implementation YCPhotoAssetVC
{
    NSString *_photoAssetCellID;
    NSInteger _checkedCount;                       //记录视频勾选的总数
    NSIndexPath *_lastIndexPath;                   //记录最后滑动到的索引
    UIPanGestureRecognizer *_panGestureRecognizer; //滑动手势
}
#pragma mark- 释放资源
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver:self];
}
#pragma mark- 加载视图
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = _directoryTitle;
    _photoAssetArr = [NSMutableArray array];
    
    //设置完成按钮
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(finish)];
    self.navigationItem.rightBarButtonItem = rightItem;

    //设置顶部和底部悬空(必须放在这里)
    UIEdgeInsets currentInsets = _photoAssetCollectionView.contentInset;
    currentInsets.top = 0.5f;
    currentInsets.bottom = 0.0f;
    _photoAssetCollectionView.contentInset = currentInsets;
    
    //创建流水布局
    _layout = [[UICollectionViewFlowLayout alloc] init];
    //第一次加载判断设备方向
    [self deviceOrientationChange];
    //设置整个collectionView的内边距
    CGFloat paddingY = 1.0f;
    CGFloat paddingX = 1.0f;
    _layout.sectionInset = UIEdgeInsetsMake(paddingY, paddingX, paddingY, paddingX);
    //设置每一列之间的间距
    _layout.minimumInteritemSpacing = paddingX;
    //设置每一行之间的间距
    _layout.minimumLineSpacing = paddingY;
    
    //设置列表视图
    _photoAssetCollectionView.dataSource = self;
    _photoAssetCollectionView.delegate = self;
    _photoAssetCollectionView.collectionViewLayout = _layout;
    [_photoAssetCollectionView setAllowsMultipleSelection:YES];
    
    //设置缩略图大小
    CGFloat scale = [UIScreen mainScreen].scale;
    CGSize cellSize = _layout.itemSize;
    _thumbnailSize = CGSizeMake(cellSize.width * scale, cellSize.height * scale);
    
    //注册cell
    _photoAssetCellID = @"YCPhotoAssetCell";
    [_photoAssetCollectionView registerNib:[UINib nibWithNibName:@"YCPhotoAssetCell" bundle:nil] forCellWithReuseIdentifier:_photoAssetCellID];
    
    //注册footer
    [_photoAssetCollectionView registerNib:[UINib nibWithNibName:@"YCPhotoAssetFooterView" bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"YCPhotoAssetFooterView"];
    
    //设置滑动手势
    _panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognizer:)];
    _panGestureRecognizer.delegate = self;
    [_panGestureRecognizer setMinimumNumberOfTouches:1];
    [_panGestureRecognizer setMaximumNumberOfTouches:1];
    [self.view addGestureRecognizer:_panGestureRecognizer];

    //监听设备旋转
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationChange) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    //监听系统相册变化
    [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
    
    //设置数据
    for (PHAsset *asset in _assetArr) {
        YCPhotoAssetModel *model = [[YCPhotoAssetModel alloc] initWithAsset:asset];
        [_photoAssetArr addObject:model];
    }
    
    //设置列表视图显示到最底
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)),dispatch_get_main_queue(), ^{
        if (_photoAssetArr.count > 0) {
            [_photoAssetCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:_photoAssetArr.count - 1 inSection:0] atScrollPosition:UICollectionViewScrollPositionTop animated:NO];
        }
    });
    
    //判断没有一个数据
    _noDataBaseView.hidden = _photoAssetArr.count == 0 ? NO : YES;
}
#pragma mark- UICollectionView代理
//多少组
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}
//这组多少行
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _photoAssetArr.count;
}
//每行cell
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    YCPhotoAssetCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:_photoAssetCellID forIndexPath:indexPath];
    cell.photoAssetVC = self;
    [cell refreshPhotoAssetModel:_photoAssetArr[indexPath.row]];
    
    return cell;
}
//选中cell
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self selectItemAtIndexPath:indexPath];
}
//反选cell
- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self selectItemAtIndexPath:indexPath];
}
//点击cell
- (void)selectItemAtIndexPath:(NSIndexPath *)indexPath
{
    YCPhotoAssetModel *model = _photoAssetArr[indexPath.row];
    if (model.isChecked) {
        _checkedCount --;
        model.isChecked = NO;
    }else{
        _checkedCount ++;
        //判断大于最多选择的个数
        if (_checkedCount > _maxNum) {
            
            NSString *title = nil;
            if (_mediaType == PHAssetMediaTypeUnknown) {
                title = [NSString stringWithFormat:@"最多只能选择%zd项!", _maxNum];
            }else if (_mediaType == PHAssetMediaTypeImage){
                title = [NSString stringWithFormat:@"最多只能选择%zd张照片!", _maxNum];
            }else if (_mediaType == PHAssetMediaTypeVideo){
                title = [NSString stringWithFormat:@"最多只能选择%zd部视频!", _maxNum];
            }else if (_mediaType == PHAssetMediaTypeAudio){
                title = [NSString stringWithFormat:@"最多只能选择%zd首歌曲!", _maxNum];
            }
            UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *alertAction = [UIAlertAction actionWithTitle:@"我知道了" style:UIAlertActionStyleDefault handler:nil];
            [alertVC addAction:alertAction];
            [self presentViewController:alertVC animated:YES completion:nil];
            
            _checkedCount --;
            
            return;
        }
        model.isChecked = YES;
    }
    //刷新这一行
    //[_photoAssetCollectionView reloadData];
    [_photoAssetCollectionView reloadItemsAtIndexPaths:@[indexPath]];
    
    //设置标题
    if (_checkedCount == 0) {
        self.navigationItem.title = _directoryTitle;
    }else{
        if (_mediaType == PHAssetMediaTypeUnknown) {
            self.title = [NSString stringWithFormat:@"已选择%zd项", _checkedCount];
        }else if (_mediaType == PHAssetMediaTypeImage){
            self.title = [NSString stringWithFormat:@"已选择%zd张照片", _checkedCount];
        }else if (_mediaType == PHAssetMediaTypeVideo){
            self.title = [NSString stringWithFormat:@"已选择%zd部视频", _checkedCount];
        }else if (_mediaType == PHAssetMediaTypeAudio){
            self.title = [NSString stringWithFormat:@"已选择%zd首歌曲", _checkedCount];
        }
    }
}
//设置footer和header
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if (kind == UICollectionElementKindSectionFooter) {
        YCPhotoAssetFooterView *footerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"YCPhotoAssetFooterView" forIndexPath:indexPath];
        
        NSString *numStr = @"";
        NSInteger imageNum = [_fetchResult countOfAssetsWithMediaType:PHAssetMediaTypeImage];
        NSInteger videoNum = [_fetchResult countOfAssetsWithMediaType:PHAssetMediaTypeVideo];
        NSInteger audioNum = [_fetchResult countOfAssetsWithMediaType:PHAssetMediaTypeAudio];
        
        if (imageNum > 0 && videoNum == 0 && audioNum == 0) {
            numStr = [NSString stringWithFormat:@"%zd张照片", imageNum];
            
        }else if (imageNum > 0 && videoNum > 0 && audioNum == 0){
            numStr = [NSString stringWithFormat:@"%zd张照片、%zd部视频", imageNum, videoNum];
            
        }else if (imageNum > 0 && videoNum > 0 && audioNum > 0){
            numStr = [NSString stringWithFormat:@"%zd张照片、%zd部视频、%zd首歌曲", imageNum, videoNum, audioNum];
            
        }else if (imageNum == 0 && videoNum > 0 && audioNum > 0){
            numStr = [NSString stringWithFormat:@"%zd部视频、%zd首歌曲", videoNum, audioNum];
            
        }else if (imageNum == 0 && videoNum > 0 && audioNum == 0){
            numStr = [NSString stringWithFormat:@"%zd部视频", videoNum];
            
        }else if (imageNum == 0 && videoNum == 0 && audioNum == 0){
            numStr = @"";
        }
        footerView.numLabel.text = numStr;
        
        return footerView;
    }
    return [[YCPhotoAssetFooterView alloc] init];
}
//设置footer高度
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section
{
    //计算集合视图的高度
    CGFloat h = 0;
    UIInterfaceOrientation interfaceOrientation = [UIApplication sharedApplication].statusBarOrientation;
    if (UIInterfaceOrientationIsPortrait(interfaceOrientation)){
        //NSLog(@"是竖屏");
        CGFloat w = (SCREEN_WIDTH - 1.0f * (VERTICAL_COLS + 1)) / VERTICAL_COLS;
        NSInteger row = _photoAssetArr.count / VERTICAL_COLS + (_photoAssetArr.count % VERTICAL_COLS == 0 ? 0 : 1);
        h = (w * row) + (row + 1);
        
    }else if(UIInterfaceOrientationIsLandscape(interfaceOrientation)){
        //NSLog(@"是横屏");
        CGFloat w = (SCREEN_WIDTH - 1.0f * (HORIZONTAL_COLS + 1)) / HORIZONTAL_COLS;
        NSInteger row = _photoAssetArr.count / HORIZONTAL_COLS + (_photoAssetArr.count % HORIZONTAL_COLS == 0 ? 0 : 1);
        h = (w * row) + (row + 1);
    }
    CGFloat screenH = self.view.bounds.size.height - self.navigationController.navigationBar.bounds.size.height - self.navigationController.toolbar.bounds.size.height - 20;
    if (h < screenH) {
        return CGSizeMake(self.view.bounds.size.width, 0);
    }else{
        return CGSizeMake(self.view.bounds.size.width, 40);
    }
}
#pragma mark- 手势代理
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    //判断是滑动手势
    if (gestureRecognizer == _panGestureRecognizer) {
        CGPoint beginPoint = [_panGestureRecognizer locationInView:self.view];
        //小于等于44是右滑返回
        if (beginPoint.x <= 44) {
            return NO;
        }
    }
    return YES;
}
#pragma mark- 滑动多选
- (void)panGestureRecognizer:(UIPanGestureRecognizer *)gestureRecognizer
{
    float pointerX = [gestureRecognizer locationInView:_photoAssetCollectionView].x;
    float pointerY = [gestureRecognizer locationInView:_photoAssetCollectionView].y;
    
    for (UICollectionViewCell *cell in _photoAssetCollectionView.visibleCells) {
        float cellSX = cell.frame.origin.x;
        float cellEX = cell.frame.origin.x + cell.frame.size.width;
        float cellSY = cell.frame.origin.y;
        float cellEY = cell.frame.origin.y + cell.frame.size.height;
        
        if (pointerX >= cellSX && pointerX <= cellEX && pointerY >= cellSY && pointerY <= cellEY){
            NSIndexPath *touchOverIndexPath = [_photoAssetCollectionView indexPathForCell:cell];
            if (_lastIndexPath != touchOverIndexPath){
                if (cell.selected){
                    [self deselectCellForCollectionView:_photoAssetCollectionView atIndexPath:touchOverIndexPath];
                }else{
                    [self selectCellForCollectionView:_photoAssetCollectionView atIndexPath:touchOverIndexPath];
                }
            }
            _lastIndexPath = touchOverIndexPath;
        }
    }
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded){
        _lastIndexPath = nil;
        _photoAssetCollectionView.scrollEnabled = YES;
    }
}
- (void)selectCellForCollectionView:(UICollectionView *)collection atIndexPath:(NSIndexPath *)indexPath
{
    [collection selectItemAtIndexPath:indexPath animated:YES scrollPosition:UICollectionViewScrollPositionNone];
    [self collectionView:collection didSelectItemAtIndexPath:indexPath];
}
- (void)deselectCellForCollectionView:(UICollectionView *)collection atIndexPath:(NSIndexPath *)indexPath
{
    [collection deselectItemAtIndexPath:indexPath animated:YES];
    [self collectionView:collection didDeselectItemAtIndexPath:indexPath];
}
#pragma mark- 监听系统相册变化
- (void)photoLibraryDidChange:(PHChange *)changeInstance
{
    PHFetchResultChangeDetails *collectionChanges = [changeInstance changeDetailsForFetchResult:_fetchResult];
    if (collectionChanges == nil) {
        return;
    } 
    //必须主线程进行
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [_photoAssetArr removeAllObjects];
        
        //重新设置数据
        _fetchResult = [collectionChanges fetchResultAfterChanges];
        for (PHAsset *asset in _fetchResult) {
            YCPhotoAssetModel *model = [[YCPhotoAssetModel alloc] initWithAsset:asset];
            [_photoAssetArr addObject:model];
        }
        [_photoAssetCollectionView reloadData];
        
        //判断没有一个数据
        _noDataBaseView.hidden = _photoAssetArr.count == 0 ? NO : YES;
    });
}
#pragma mark- 监听设备方向
- (void)deviceOrientationChange
{
    UIInterfaceOrientation interfaceOrientation = [UIApplication sharedApplication].statusBarOrientation;
    //计算cell的宽度
    CGFloat w = 0;
    if (UIInterfaceOrientationIsPortrait(interfaceOrientation)){
        //NSLog(@"是竖屏");
        w = (SCREEN_WIDTH - 1.0f * (VERTICAL_COLS + 1)) / VERTICAL_COLS;
        
    }else if(UIInterfaceOrientationIsLandscape(interfaceOrientation)){
        //NSLog(@"是横屏");
        w = (SCREEN_WIDTH - 1.0f * (HORIZONTAL_COLS + 1)) / HORIZONTAL_COLS;
        
    }else{
        return;
    }
    //设置每个格子的尺寸
    _layout.itemSize = CGSizeMake(w, w);
    
    //设置缩略图大小
    CGFloat scale = [UIScreen mainScreen].scale;
    CGSize cellSize = _layout.itemSize;
    _thumbnailSize = CGSizeMake(cellSize.width * scale, cellSize.height * scale);
    
    //刷新
    [_photoAssetCollectionView reloadData];
}
#pragma mark- 完成选择
- (void)finish
{
    if (_checkedCount > 0) {
        NSMutableArray *newAssetArr = [NSMutableArray array];
        for (YCPhotoAssetModel *model in _photoAssetArr) {
            if (model.isChecked) {
                [newAssetArr addObject:model.asset];
            }
        }
        if (_delegate && [_delegate respondsToSelector:@selector(photoSelectorVC:assetArr:)]) {
            [_delegate photoSelectorVC:_photoSelectorVC assetArr:newAssetArr];
        }
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end




