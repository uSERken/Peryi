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
#import "ZKDMListTouchVC.h"
#import "AppDelegate.h"
#import "ZKMainController.h"
#define identifier @"Cell"

@interface ZKHomeController()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UIViewControllerPreviewingDelegate>

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, strong) NSArray *dmList;

@property (nonatomic, strong) ZKSlideView *slideView;

@property (nonatomic, strong) ZKDataTools *dataTools;

@property (nonatomic, strong) ZKHttpTools *httpTools;

@property (nonatomic, assign) BOOL isNetWorking;

@end


@implementation ZKHomeController

- (void)viewDidLoad{
    [super viewDidLoad];
    _isNetWorking = NO;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(isNetWork) name:isNet object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(isNotNetWork) name:isNotNet object:nil];
    
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
        if (weakSelf.isNetWorking) {
            ZKHomeList *model = homeListModel;
            [weakSelf goToVideoControllerWithStrUrl:model.href];
        }else{
            [MBProgressHUD showError:@"您的网络已断开"];
        }
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
    _httpTools = [ZKHttpTools sharedZKHttpTools];
    
    WeakSelf;
    [_httpTools getDMListDatasuccess:^(NSArray *listArr) {
        //判断是否通过网络成功加载值
        if (listArr.count > 1) {
            weakSelf.dmList = [ZKHomeList mj_objectArrayWithKeyValuesArray:listArr];
            weakSelf.slideView.listArr = weakSelf.dmList;
            [_dataTools saveHomeDMListWithArry:listArr];
        }else{
            [MBProgressHUD showError:@"无网络连接或网络错误"];
            weakSelf.dmList = [ZKHomeList mj_objectArrayWithKeyValuesArray:[_dataTools getHomeDMlist]];
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
    [self registerForPreviewingWithDelegate:self sourceView:cell];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (_isNetWorking) {
        ZKHomeList *selectModel = _dmList[indexPath.row];
        [self goToVideoControllerWithStrUrl:selectModel.href];
    }else{
        [MBProgressHUD showError:@"您的网络已断开"];
    }
    
    
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(5, 5, 5, 5);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat ViewW = (self.view.width - 20)/2;
    return CGSizeMake(ViewW, 260);
    
}



#pragma mark - 3DTouch
- (UIViewController *)previewingContext:(id<UIViewControllerPreviewing>)previewingContext viewControllerForLocation:(CGPoint)location{
    
    NSIndexPath *indexPath = [_collectionView indexPathForCell:(ZKHomeCollectionCell*)[previewingContext sourceView]];
    ZKHomeList *model = _dmList[indexPath.row];
    ZKDMListTouchVC *touchVc = [[ZKDMListTouchVC alloc] initWithUrlStr:model.href bgColor:[UIColor yellowColor]];
    //加载列表数据
    [_httpTools getDetailDMWithURL:model.href getDatasuccess:^(NSDictionary *listData) {
        touchVc.detailList = listData;
    }];
    
    touchVc.preferredContentSize = CGSizeMake(0, 450);
    return touchVc;
}


- (void)previewingContext:(id<UIViewControllerPreviewing>)previewingContext commitViewController:(UIViewController *)viewControllerToCommit{
    [self showViewController:viewControllerToCommit sender:self];
}

- (void)isNetWork{
    _isNetWorking = YES;
}

- (void)isNotNetWork{
    _isNetWorking = NO;
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end
