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
//为 nil 时无网络，NO 时是 wifi，YES 时是4G 网络
@property (nonatomic,assign)BOOL is4G;

@property (nonatomic,strong)NSTimer *timer;

@property (nonatomic,assign)BOOL isRefresh;

@end


@implementation ZKHomeController

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setHidden:YES];
    [MobClick beginLogPageView:@"HomePage"];
    _isNetWorking = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(isNetWork) name:isNet object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(isNotNetWork) name:isNotNet object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(is4GWAAN) name:isWWAN object:nil];
    
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"HomePage"];
    [self.navigationController.navigationBar setHidden:NO];
}


- (void)viewDidLoad{
    [super viewDidLoad];
    self.title = @"首页";
    _isRefresh = NO;
    _httpTools = [ZKHttpTools sharedZKHttpTools];
    _dataTools = [ZKDataTools sharedZKDataTools];
    _dmList = [ZKHomeList mj_objectArrayWithKeyValuesArray:[_dataTools getHomeDMlist]];
     [self setUpSlideViewAndCollectionView];
    //进入界面后自动刷新
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.5f target:self selector:@selector(timerAction) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
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
     _isRefresh = YES;
    WeakSelf;
    [_httpTools getDMListDatasuccess:^(NSArray *listArr) {
        //判断是否通过网络成功加载值
        if (listArr.count > 1) {
            [weakSelf getDmListFromNetWithArr:listArr];
        }else{
            [MBProgressHUD showError:@"无网络连接或网络错误"];
            weakSelf.dmList = [ZKHomeList mj_objectArrayWithKeyValuesArray:[_dataTools getHomeDMlist]];
        }
    }];
    [self.collectionView.mj_header endRefreshing];
}

- (void)getDmListFromNetWithArr:(NSArray *)listArr{
    self.dmList = [ZKHomeList mj_objectArrayWithKeyValuesArray:listArr];
    self.slideView.listArr = self.dmList;
    [self.collectionView reloadData];
    [_dataTools saveHomeDMListWithArry:listArr];
    }

-(void)timerAction{
    [self.collectionView.mj_header beginRefreshing];
    if (_isRefresh == YES) {
        if (self.timer != nil) {
            [_timer invalidate];
        }
    }

}

- (void)goToVideoControllerWithStrUrl:(NSString *)strUrl{
    ZKVideoController *viewCtr = [[ZKVideoController alloc] initWithAddress:strUrl];
    viewCtr.is4G = _is4G;
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
    _is4G = NO;
}

- (void)isNotNetWork{
    _isNetWorking = NO;
    _is4G = nil;
}

- (void)is4GWAAN{
    _is4G = YES;
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end
