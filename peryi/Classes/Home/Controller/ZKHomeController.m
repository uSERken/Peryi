//
//  ZKHomeController.m
//  peryi
//
//  Created by k on 16/4/25.
//  Copyright © 2016年 ZK. All rights reserved.
//

#import "ZKHomeController.h"
#import "ZKHttpTools.h"
#import "ZKSlideView.h"
#import "ZKHomeCollectionCell.h"
#import "ZKHomeList.h"
#import "MJExtension.h"
#import "Masonry.h"
#import <MJRefresh/MJRefresh.h>
#import "ZKVideoController.h"
#import "MBProgressHUD+Extend.h"
#import "ZKDataTools.h"

#define identifier @"Cell"

@interface ZKHomeController()

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, strong) NSArray *dmList;

@property (nonatomic, strong) ZKSlideView *slideView;

@property (nonatomic, strong) ZKDataTools *dataTools;

@end

@interface ZKHomeController()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

@end

@implementation ZKHomeController

- (void)viewDidLoad{
    [super viewDidLoad];

    self.title = @"首页";
    
    _dataTools = [ZKDataTools sharedZKDataTools];
    
    [self refreshHome];
 
    [self setUpSlideViewAndCollectionView];


}

- (void)setUpSlideViewAndCollectionView{
    
    if (_slideView == nil) {
        _slideView = [[ZKSlideView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.navigationController.navigationBar.frame), self.view.width, 265)];
        _slideView.listArr = self.dmList;
        [self.view addSubview:_slideView];
    }
    
    WeakSelf;
    self.slideView.tapActionBlock=^(ZKHomeList *homeListModel){
        ZKHomeList *model = homeListModel;
        [weakSelf goToVideoControllerWithStrUrl:model.href];
    };
    
    if (!_collectionView) {
        _collectionView=({
            UICollectionViewFlowLayout *collectionViewFlow = [[UICollectionViewFlowLayout alloc] init];
            [collectionViewFlow setScrollDirection:UICollectionViewScrollDirectionVertical];
            UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_slideView.frame), self.view.width, (self.view.height - CGRectGetMaxY(_slideView.frame)-44)) collectionViewLayout:collectionViewFlow];
            [collectionView registerClass:[ZKHomeCollectionCell class] forCellWithReuseIdentifier:identifier];
            collectionView.delegate = self;
            collectionView.dataSource = self;
            collectionView.backgroundColor = [UIColor clearColor];
            collectionView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(refreshHome)];
            collectionView;
        });
    
        [self.view addSubview:_collectionView];
    }
    
}

- (void)refreshHome{
    [MBProgressHUD showMessage:@"请稍候..."];
    ZKHttpTools *httpTools = [ZKHttpTools sharedZKHttpTools];
//    NSArray *dmArr = [httpTools getDMLIST];
    WeakSelf;
    [httpTools getDMListDatasuccess:^(NSArray *listArr) {
        if (listArr.count > 1) {
            weakSelf.dmList = [ZKHomeList mj_objectArrayWithKeyValuesArray:listArr];
            weakSelf.slideView.listArr = weakSelf.dmList;
            [_dataTools saveHomeDMListWithArry:listArr];
            [MBProgressHUD hideHUD];
        }else{
            [MBProgressHUD hideHUD];
            weakSelf.dmList = [ZKHomeList mj_objectArrayWithKeyValuesArray:[_dataTools getHomeDMlist]];
            [MBProgressHUD showError:@"无网络连接或网络错误"];
        }
    }];
    
       [self.collectionView.mj_header endRefreshing];
}

- (void)goToVideoControllerWithStrUrl:(NSString *)strUrl{
    ZKVideoController *viewCtr = [[ZKVideoController alloc] initWithAddress:strUrl];
    [self.navigationController pushViewController:viewCtr animated:YES];
}



#pragma mark - uicollectionview代理
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.dmList.count;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *ID = identifier;
    ZKHomeCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:ID forIndexPath:indexPath];
    ZKHomeList *model = _dmList[indexPath.row];
    cell.title = model.title;
    cell.current = model.current;
    cell.imgUrl = model.src;
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    ZKHomeList *selectModel = _dmList[indexPath.row];
    [self goToVideoControllerWithStrUrl:selectModel.href];
    //进入即保存为播放记录
    [_dataTools saveHistroyOrStartWithModel:selectModel withType:saveHome];
    
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(5, 5, 5, 5);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat ViewW = (self.view.width - 20)/2;
    return CGSizeMake(ViewW, 260);
    
}


@end
