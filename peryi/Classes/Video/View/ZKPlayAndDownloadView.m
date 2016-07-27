//
//  ZKPlayAndDownloadView.m
//  peryi
//
//  Created by k on 16/5/3.
//  Copyright © 2016年 ZK. All rights reserved.
//

#import "ZKPlayAndDownloadView.h"
#import "ZKPlayAndDownCell.h"
#import "ZKSegmentedControl.h"
#import "ZKDetailPlay.h"
#import "ZKPlayListCollectionHeader.h"
#import "ZKDetailDown.h"
#import "ZKDataTools.h"
#import "ZKDetailAbout.h"
#import <MJExtension/MJExtension.h>

#define identifier @"Cell"

@interface ZKPlayAndDownloadView()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (weak, nonatomic) IBOutlet ZKSegmentedControl *segmentedControl;

@property (nonatomic, strong) UICollectionViewFlowLayout *collectionViewFlow;

@property (nonatomic, strong) NSArray *useList;
//是否是播放列表
@property (nonatomic, assign) BOOL isPlay;

//选中的section
@property (nonatomic ,assign)NSInteger selectSection;
//选中的row
@property (nonatomic ,assign)NSInteger selectIndex;
//根据数据库得到集数选中
@property (nonatomic ,assign)NSInteger firstIndex;
//第一次进入显示
@property (nonatomic ,assign)BOOL firstSel;

@property (nonatomic, strong) ZKDataTools *dataTools;


@end


@implementation ZKPlayAndDownloadView
static NSString *ID = identifier;

+(instancetype)view{
    return [[NSBundle mainBundle] loadNibNamed:@"ZKPlayAndDownloadView" owner:nil options:nil].firstObject;
}

- (void)awakeFromNib{
    [super awakeFromNib];
    self.selectSection = MAXFLOAT;
    self.selectIndex = MAXFLOAT;
    _isPlay = YES;
    _useList = _playModelList;
    _dataTools = [ZKDataTools sharedZKDataTools];
    
    WeakSelf;
    [self.segmentedControl setIndexChangeBlock:^(NSInteger index) {
        switch (index) {
            case 0:
                weakSelf.isPlay = YES;
                weakSelf.useList = _playModelList;
                 [weakSelf.collectionView reloadData];
                break;
            case 1:
                weakSelf.isPlay = NO;
                weakSelf.useList = _downModelList;
                 [weakSelf.collectionView reloadData];
                break;
            default:
                break;
        }
    }];

    _collectionViewFlow = [[UICollectionViewFlowLayout alloc] init];
    [_collectionViewFlow setScrollDirection:UICollectionViewScrollDirectionVertical];
    _collectionView.collectionViewLayout = _collectionViewFlow;
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    [_collectionView registerClass:[ZKPlayAndDownCell class] forCellWithReuseIdentifier:identifier];
    [_collectionView registerClass:[ZKPlayListCollectionHeader class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"header"];
}

- (void)layoutSubviews{
     _collectionView.backgroundColor = [UIColor whiteColor];
    [_collectionView reloadData];
}


- (void)setPlayModelList:(NSArray *)playModelList{
    _playModelList = playModelList;
    if (_isPlay) {
       _useList = _playModelList;
      [_collectionView reloadData];
    }
}

- (void)setDownModelList:(NSArray *)downModelList{
    _downModelList = downModelList;
    if (!_isPlay) {
      _useList = _downModelList;
    [_collectionView reloadData];
    }
}

- (void)setTitle:(NSString *)title{
    _title = title;
        //获取记录
    ZKDetailAbout *model = [ZKDetailAbout mj_objectWithKeyValues:[_dataTools getDetailAboutWithTitle:title]];
    //获取播放集数的纯数字
    NSString *playTitle= [[model.currentplaytitle componentsSeparatedByCharactersInSet:[[NSCharacterSet characterSetWithCharactersInString:@"0123456789"] invertedSet]] componentsJoinedByString:@""];
    if (playTitle) {
        _firstIndex = [playTitle integerValue] - 1;
        if (_firstIndex < 0) {
            _firstIndex = 0;
        }
    }else{
        _firstIndex = 0;
    }
    _firstSel = YES;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    if (_isPlay) {
        return self.useList.count;
    }else{
       return 1; 
    }
    
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    
    ZKPlayListCollectionHeader *view = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"header" forIndexPath:indexPath];
    if (_isPlay) {
          view.titleStr = [NSString stringWithFormat:@"播放列表%ld",indexPath.section+1];
    }else{
          view.titleStr = @"云盘列表";
    }
    
        return view;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{
    
    return CGSizeMake(screenW, 30);
    
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    if (_isPlay) {
        NSArray *playList = self.useList[section];
        return playList.count;
    }else{
        return self.useList.count;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    ZKPlayAndDownCell *cell =(ZKPlayAndDownCell *)[collectionView dequeueReusableCellWithReuseIdentifier:ID forIndexPath:indexPath];
    if (_isPlay) {
       ZKDetailPlay *playModel = self.useList[indexPath.section][indexPath.row];
        cell.title = playModel.title;
    }else{
        ZKDetailDown *down = self.useList[indexPath.row];
        cell.title = down.title;
    }
    
    [self selectCellBgWithCell:cell withIndexPath:indexPath];
    
    return cell;
}

//背景选中样式判断
- (void)selectCellBgWithCell:(ZKPlayAndDownCell *)cell withIndexPath:(NSIndexPath *)indexPath{
    //第一次进入默认选中
    if (_isPlay) {
      if (_firstSel) {
        if (_useList.count > 0  && indexPath.section == 0) {//如果列表大于1个则默认选中第二个
            if (indexPath.row == _firstIndex) {
                cell.isSelected = YES;
            }
         }
      }
    }else{
        cell.isSelected = NO;
    }
    //解决复用颜色显示问题
    if (indexPath.section == _selectSection) {
        if (indexPath.row == _selectIndex) {
            cell.isSelected = YES;
        }else{
            cell.isSelected = NO;
        }
    }
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    ZKPlayAndDownCell *cell =(ZKPlayAndDownCell *)[collectionView cellForItemAtIndexPath:indexPath];
    cell.isSelected = YES;
    NSString *url = nil;
    //记录所选中相
    _selectSection = indexPath.section;
    _selectIndex = indexPath.row;

    //播放地址
    if (_isPlay) {
       ZKDetailPlay *playModel = self.useList[indexPath.section][indexPath.row];
        url = playModel.href;
        //保存播放的集数
        [_dataTools saveCurrentPlayWithTitle:_title withplayTitle:playModel.title withHref:playModel.href];
    }else{//下载地址
        ZKDetailDown *downModel = self.useList[indexPath.row];
        url = downModel.href;
    }
    if (_action) {
        _action(url);
    }
    
    //选中其他时马上更新原有选中
    _firstSel = NO;
    [self setNeedsLayout];
    
}


//当选中其他时恢复颜色
- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath{
    ZKPlayAndDownCell *cell =(ZKPlayAndDownCell *)[collectionView cellForItemAtIndexPath:indexPath];
    cell.layer.cornerRadius = 5.0f;
    cell.isSelected = NO;
    
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(5, 5, 5, 5);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    if (_isPlay) {
        ZKDetailPlay *playModel = self.useList[indexPath.section][indexPath.row];
        if (playModel.title.length < 5) {
            return CGSizeMake(50, 30);
        }else{
            return CGSizeMake(90, 30);
        }
    }else{
        return CGSizeMake(90, 30);
    }
}



@end
