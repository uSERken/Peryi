//
//  ZKSearchController.m
//  peryi
//
//  Created by k on 16/4/25.
//  Copyright © 2016年 ZK. All rights reserved.
//

#import "ZKSearchController.h"
#import "MBProgressHUD+Extend.h"
#import "ZKHttpTools.h"
#import "Masonry.h"
#import "ZKTypeCollection.h"
#import "ZKSearchDisplayController.h"
#import "ZKCollectionTypeCell.h"
#import <MJExtension/MJExtension.h>
#import "ZKTypeModel.h"
#import "ZKPlayListCollectionHeader.h"
#import "ZKDMListVC.h"
#import "ZKDataTools.h"

@interface ZKSearchController()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UISearchBarDelegate,UISearchDisplayDelegate>
@property (nonatomic, strong) ZKHttpTools *httpTools;


@property (nonatomic, strong) NSArray *typeList;

@property (nonatomic, strong) NSDictionary *allTypeDict;

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, strong) UISearchBar *searchBar;

@property (nonatomic, strong) ZKSearchDisplayController *searchViewVC;

@property (nonatomic, strong) NSArray *typeArr;

@property (nonatomic, strong) ZKDataTools *dataTools;

@property (nonatomic, assign) BOOL isNetWorking;

@property (nonatomic, strong) UILabel *tipLabel;

@end

@implementation ZKSearchController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self initView];
    [_searchBar setHidden:NO];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(isNetWork) name:isNet object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(isNotNetWork) name:isNotNet object:nil];
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [_searchBar setHidden:YES];
    
}

- (void)viewDidLoad{
    [super viewDidLoad];
    self.title = @"搜索";
    _typeArr = @[@"类型",@"年份",@"语言",@"版本"];
    _httpTools = [ZKHttpTools sharedZKHttpTools];
     _dataTools = [ZKDataTools sharedZKDataTools];
    //初始化
    [self isNetWork];
}

- (void)initView{
    UIBarButtonItem *rightBarItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"search_normal"] style:UIBarButtonItemStylePlain target:self action:@selector(searchItemClicked:)];
    [self.navigationItem setRightBarButtonItem:rightBarItem animated:YES];
    if (!_collectionView) {
        _collectionView = ({
            UICollectionViewFlowLayout *collectionViewFlow = [[UICollectionViewFlowLayout alloc] init];
            [collectionViewFlow setScrollDirection:UICollectionViewScrollDirectionVertical];
            UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0,0, self.view.width, self.view.height - 48) collectionViewLayout:collectionViewFlow];
            [collectionView registerClass:[ZKCollectionTypeCell class] forCellWithReuseIdentifier:@"Cell"];
            [collectionView registerClass:[ZKPlayListCollectionHeader class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"Header"];
            collectionView.delegate = self;
            collectionView.dataSource = self;
            collectionView.backgroundColor = [UIColor clearColor];
            collectionView;
        });
        [self.view addSubview:_collectionView];
}
}


- (void)searchItemClicked:(id)sender{
    if(!_searchBar) {
        _searchBar = ({
            UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 20,self.view.frame.size.width,44)];
            searchBar.delegate = self;
            [searchBar sizeToFit];
            searchBar.backgroundColor = [UIColor colorWithHexString:@"0x28303b"];
            searchBar.translucent = NO;
            searchBar.tintColor = [UIColor whiteColor];
            searchBar.placeholder = @"请输入动漫名称";
            searchBar.keyboardType = UIKeyboardTypeWebSearch;
            searchBar.tintColor=[UIColor blackColor];
            searchBar;
        });
    }
     [self.navigationController.view addSubview:_searchBar];
 
    if (!_searchViewVC) {
        _searchViewVC = ({
            ZKSearchDisplayController *searchVC = [[ZKSearchDisplayController alloc] initWithSearchBar:_searchBar contentsController:self];
            searchVC.active = YES;
            searchVC.parentVC = self;
            searchVC.delegate = self;
            searchVC.displaysSearchBarInNavigationBar = NO;
            searchVC;
        });
    
        WeakSelf;
        _searchViewVC.actionBlock=^(NSString *text){
            if (weakSelf.isNetWorking) {
                [MBProgressHUD showMessage:@"请稍候..."];
                [weakSelf.httpTools serarchWithString:text withPage:nil getDatasuccess:^(NSDictionary *listDict) {
                    NSArray *arr = listDict[@"list"];
                    if (arr.count != 0) {
                        ZKDMListVC *vc = [[ZKDMListVC alloc] init];
                        vc.dmListDict = listDict;
                        vc.pageStyle = text;
                        vc.navTitle = text;
                        weakSelf.searchViewVC.active = NO;
                        [weakSelf.navigationController pushViewController:vc animated:YES];
                        [MBProgressHUD hideHUD];
                    }else{
                        [MBProgressHUD hideHUD];
                        [MBProgressHUD showError:@"搜索无结果"];
                    }
                }];
            }else{
                 [MBProgressHUD showError:@"您的网络已断开"];
            }
        };
    }
    [_searchBar becomeFirstResponder];
   
}

#pragma mark - 初始网络请求

- (void)getSearchWithType:(NSString *)urlStr withTitle:(NSString *)title{
    [MBProgressHUD showMessage:@"请稍候..."];
    WeakSelf;
    [_httpTools searchWithUrlStr:urlStr withPage:nil getDatasuccess:^(NSDictionary *listDict) {
        ZKDMListVC *vc = [[ZKDMListVC alloc] init];
        vc.dmListDict = listDict;
        vc.pageStyle = urlStr;
        vc.navTitle = title;
        [weakSelf.navigationController pushViewController:vc animated:YES];
         [MBProgressHUD hideHUD];
    }];
}

#pragma mark - collection delegate
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return _typeList.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    NSArray *list = _typeList[section];
    return list.count;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    
    ZKPlayListCollectionHeader *view = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"Header" forIndexPath:indexPath];
        view.titleStr = _typeArr[indexPath.section];
    return view;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{
    
    return CGSizeMake(screenW, 30);
    
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    ZKCollectionTypeCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    ZKTypeModel *model = self.typeList[indexPath.section][indexPath.row];
    cell.title = model.title;
    cell.backgroundColor = [UIColor whiteColor];
    
    

    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(nonnull NSIndexPath *)indexPath{

    if (_isNetWorking) {
        ZKTypeModel *model = _typeList[indexPath.section][indexPath.row];
        [self getSearchWithType:model.href withTitle:model.title];
    }else{
         [MBProgressHUD showError:@"您的网络已断开"];
    }
}


- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(5, 5, 5, 5);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(65, 30);
    
}

/*
#pragma mark - searchbar 代理

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [MBProgressHUD showMessage:@"请稍候..."];
    WeakSelf;
    [_httpTools serarchWithString:searchBar.text withPage:nil getDatasuccess:^(NSDictionary *listDict) {
        NSArray *arr = listDict[@"list"];
        if (arr.count != 0) {
            ZKDMListVC *vc = [[ZKDMListVC alloc] init];
            vc.dmListDict = listDict;
            vc.pageStyle = searchBar.text;
            weakSelf.searchViewVC.active = NO;
            [weakSelf.navigationController pushViewController:vc animated:YES];
             [MBProgressHUD hideHUD];
        }else{
            [MBProgressHUD hideHUD];
             weakSelf.searchViewVC.active = NO;
            [MBProgressHUD showError:@"没有结果"];
        }
    }];
}
*/

#pragma mark - 网络判断后加载数据
- (void)isNetWork{
    _isNetWorking = YES;
    [_tipLabel removeFromSuperview];
    WeakSelf;
    [weakSelf.httpTools searchHomeListgetDatasuccess:^(NSArray *listArr) {
        NSMutableArray *modelArr = [NSMutableArray array];
        for (NSArray *arr in listArr) {
            [modelArr addObject:[ZKTypeModel mj_objectArrayWithKeyValuesArray:arr]];
        }
         weakSelf.typeList = modelArr;
        [weakSelf.collectionView reloadData];
        //初始化无网络后执行从数据库提取
        if (modelArr.count == 0) {
            [weakSelf isNotNetWork];
        }else{//有值保存
            [weakSelf.dataTools saveSearchTypeWithArr:listArr];
        }
    }];
}

- (void)isNotNetWork{
    _isNetWorking = NO;

    NSMutableArray *modelArr = [NSMutableArray array];
    for (NSArray *arr in [_dataTools getSearchType]) {
        [modelArr addObject:[ZKTypeModel mj_objectArrayWithKeyValuesArray:arr]];
    }
    NSLog(@"%ld",modelArr.count);
     self.typeList = modelArr;
    [self.collectionView reloadData];
    
    if (modelArr.count == 0) {//数据库中无值提示
        _tipLabel = [[UILabel alloc] init];
        _tipLabel.size = CGSizeMake(120, 30);
        _tipLabel.center = self.view.center;
        _tipLabel.textAlignment = NSTextAlignmentCenter;
        [self.view addSubview:_tipLabel];
    }
    
}


-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end
