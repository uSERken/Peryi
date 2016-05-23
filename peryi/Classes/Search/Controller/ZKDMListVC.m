//
//  ZKDMListVC.m
//  peryi
//
//  Created by k on 16/5/10.
//  Copyright © 2016年 ZK. All rights reserved.
//

#import "ZKDMListVC.h"
#import "ZKDMListCell.h"
#import <MJRefresh/MJRefresh.h>
#import <MJExtension/MJExtension.h>
#import "ZKListModel.h"
#import "ZKHttpTools.h"
#import "MBProgressHUD+Extend.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "ZKVideoController.h"
#import "ZKDataTools.h"
#import "ZKPageTips.h"
#import "ZKDMListTouchVC.h"

@interface ZKDMListVC ()<UITableViewDelegate,UITableViewDataSource,UIViewControllerPreviewingDelegate>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *dmListArr;

@property (nonatomic, strong) NSString *lastPage;

@property (nonatomic, strong)  ZKHttpTools *httpTools;

@property (nonatomic, assign) NSInteger page;

@property (nonatomic, strong) ZKPageTips *pageTipsView;

@property (nonatomic, assign) BOOL isNetWorking;
@end

@implementation ZKDMListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = _navTitle;
    [self setUpView];
    _pageTipsView.lastPageStr = _lastPage;
    _page = 2;
    _httpTools = [ZKHttpTools sharedZKHttpTools];
    _isNetWorking = YES;
    //网络状态改变通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(isNetWork) name:isNet object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(isNotNetWork) name:isNotNet object:nil];
}

- (void)setDmListDict:(NSDictionary *)dmListDict{
    _dmListDict = dmListDict;
    _lastPage = _dmListDict[@"lastPage"];
    _dmListArr = [ZKListModel mj_objectArrayWithKeyValuesArray:_dmListDict[@"list"]];
    [_tableView reloadData];
}

- (void)setUpView{
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    _tableView = ({
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height - 44) style:UITableViewStylePlain];
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.backgroundColor = [UIColor clearColor];
        tableView.tableFooterView =[[UIView alloc] initWithFrame:CGRectZero];
        tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(getMoreData)];
        
        tableView;
        });
    [self.view addSubview:_tableView];
    
    _pageTipsView = [ZKPageTips initView];
    [_pageTipsView setOrigin:CGPointMake((self.view.width - 80)/2, (self.view.height - 80))];
    [self.view addSubview:_pageTipsView];
}


- (void)getMoreData{
    if (_page <= [_lastPage integerValue]) {
      NSString *pageStr = [NSString stringWithFormat:@"%ld",_page];
        WeakSelf;
        //判断是网页类型搜索还是关键词语搜索
    if ([_pageStyle rangeOfString:@"searchtype"].location != NSNotFound) {
        [_httpTools searchWithUrlStr:_pageStyle withPage:pageStr getDatasuccess:^(NSDictionary *listDict) {
            if (listDict[@"list"] != nil) {
                [weakSelf.dmListArr addObjectsFromArray:[ZKListModel mj_objectArrayWithKeyValuesArray:listDict[@"list"]]];
                [weakSelf.tableView reloadData];
                ++weakSelf.page;
            }else{
                [_tableView.mj_footer endRefreshingWithNoMoreData];
            }
            
            [weakSelf.tableView.mj_footer endRefreshing];
        }];
        
    }else{
        
        [_httpTools serarchWithString:_pageStyle withPage:pageStr getDatasuccess:^(NSDictionary *listDict) {
            if (listDict[@"list"] != nil) {
                [weakSelf.dmListArr addObjectsFromArray:[ZKListModel mj_objectArrayWithKeyValuesArray:listDict[@"list"]]];
                [weakSelf.tableView reloadData];
                ++weakSelf.page;
            }else{
                [_tableView.mj_footer endRefreshingWithNoMoreData];
            }
            
            [weakSelf.tableView.mj_footer endRefreshing];
        }];
    }//判断结束
     }else{
        [_tableView.mj_footer endRefreshingWithNoMoreData];
        [MBProgressHUD showError:@"没有更多了"];
        [_tableView.mj_footer endRefreshing];
    }
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dmListArr.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
   
    ZKDMListCell *cell = [ZKDMListCell cellWithTableView:tableView];
    ZKListModel *model = self.dmListArr[indexPath.row];
    
     [self registerForPreviewingWithDelegate:self sourceView:cell];

    cell.titleLabel.text = model.alt;
    [cell.imgView sd_setImageWithURL:[NSURL URLWithString:model.src] placeholderImage:[UIImage imageNamed:@"Management_Mask"]];
    cell.updateLabel.text = model.about[@"update"];
    cell.attentionLabel.text = model.about[@"attention"];
    cell.synopsisLabel.text = model.about[@"synopsis"];
    
    //网页中每页分别19条数据
    NSInteger count = indexPath.row / 19;
    _pageTipsView.currentPageStr = [NSString stringWithFormat:@"%ld",count+1];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    if (_isNetWorking) {
        ZKListModel *model = self.dmListArr[indexPath.row];
        ZKVideoController *vc = [[ZKVideoController alloc] initWithAddress:model.href];
        [self.navigationController pushViewController:vc animated:YES];
    }else{
        [MBProgressHUD showError:@"您的网络已断开"];
    }
    

}

//header高
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 3;
}

//table分割线
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 3)];
    headerView.backgroundColor = [UIColor whiteColor];
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 90;
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView{
    _pageTipsView.hidden = NO;
    [UIView animateWithDuration:1 animations:^{
        _pageTipsView.alpha = 0.5;
    } completion:^(BOOL finished) {
        
    }];
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    [UIView animateWithDuration:1 animations:^{
        _pageTipsView.alpha = 0;
    } completion:^(BOOL finished) {
        _pageTipsView.hidden = YES;
    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


#pragma mark - 3DTouch
- (UIViewController *)previewingContext:(id<UIViewControllerPreviewing>)previewingContext viewControllerForLocation:(CGPoint)location{
    NSIndexPath *indexPath = [_tableView indexPathForCell:(ZKDMListCell*)[previewingContext sourceView]];
    ZKListModel *model = self.dmListArr[indexPath.row];

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
