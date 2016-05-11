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
#define identifier @"Cell"

@interface ZKPlayAndDownloadView()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (weak, nonatomic) IBOutlet ZKSegmentedControl *segmentedControl;

@property (nonatomic, strong) UICollectionViewFlowLayout *collectionViewFlow;

@property (nonatomic, strong) NSArray *useList;
//是否是播放列表
@property (nonatomic, assign) BOOL isPlay;


@end


@implementation ZKPlayAndDownloadView
static NSString *ID = identifier;

+(instancetype)view{
    return [[NSBundle mainBundle] loadNibNamed:@"ZKPlayAndDownloadView" owner:nil options:nil].firstObject;
}

- (void)awakeFromNib{
    [super awakeFromNib];
    _isPlay = YES;
    _useList = _playModelList;
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
    return cell;
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    ZKPlayAndDownCell *cell =(ZKPlayAndDownCell *)[collectionView cellForItemAtIndexPath:indexPath];
    NSString *url = nil;
    if (_isPlay) {
       ZKDetailPlay *playModel = self.useList[indexPath.section][indexPath.row];
        url = playModel.href;
        cell.backgroundColor = [UIColor grayColor];
    }else{
        ZKDetailDown *downModel = self.useList[indexPath.row];
        url = downModel.href;
    }
    if (_action) {
        _action(url);
    }
    
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
