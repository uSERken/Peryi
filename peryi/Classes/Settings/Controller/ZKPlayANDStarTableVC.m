//
//  ZKPlayANDStarTableVC.m
//  peryi
//
//  Created by k on 16/5/12.
//  Copyright © 2016年 ZK. All rights reserved.
//

#import "ZKPlayANDStarTableVC.h"
#import "ZKDataTools.h"
#import <MJExtension/MJExtension.h>
#import "ZKDetailAbout.h"
#import "ZKHistoryANDStartCell.h"
#import "ZKVideoController.h"
#import "MBProgressHUD+Extend.h"
#import "ZKHttpTools.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface ZKPlayANDStarTableVC ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) NSMutableArray *historyAndStartArr;

@property (nonatomic, strong)  ZKDataTools *dataTools;

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, assign) ZKPlayANDStarttType thisType;

@property (nonatomic, assign) BOOL isNetWorking;


@end

@implementation ZKPlayANDStarTableVC

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (id)initControllerWithType:(ZKPlayANDStarttType)type{
    self = [super init];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(isNotNetWork) name:isNotNet object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(isNetWork) name:isNet object:nil];
    _isNetWorking = YES;
    [self setUpView];
    _dataTools = [ZKDataTools sharedZKDataTools];
    if (type == ZKPlayANDStartHistoryType ) {
        self.title  =  @"播放历史";
     _historyAndStartArr = [ZKDetailAbout  mj_objectArrayWithKeyValuesArray:[_dataTools getHistoryOrStartListArrWithType:getHistory]];
        _thisType = type;
        [self.tableView reloadData];
    }else{
        self.title  =  @"收藏列表";
        _historyAndStartArr = [ZKDetailAbout  mj_objectArrayWithKeyValuesArray:[_dataTools getHistoryOrStartListArrWithType:getStart]];
        _thisType = type;
        [self.tableView reloadData];
    }
    if (_historyAndStartArr.count == 0 ) {
        UILabel *label = [[UILabel alloc] init];
        label.size = CGSizeMake(120, 60);
        label.center = self.view.center;
        label.textAlignment = NSTextAlignmentCenter;
        label.text = @"暂无记录！";
        [self.view addSubview:label];
    }
 [self performSelector:@selector(detectionNetWork) withObject:nil afterDelay:0.5f];
 [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getOutVideoNoti) name:@"outVideo" object:nil];
    
    return self;
}

//从记录进入播放后返回时更新数据
- (void)getOutVideoNoti{
    if (_thisType ==  ZKPlayANDStartHistoryType) {
        _historyAndStartArr = [ZKDetailAbout  mj_objectArrayWithKeyValuesArray:[_dataTools getHistoryOrStartListArrWithType:getHistory]];
        [self.tableView reloadData];
    }else{
        _historyAndStartArr = [ZKDetailAbout  mj_objectArrayWithKeyValuesArray:[_dataTools getHistoryOrStartListArrWithType:getStart]];
        [self.tableView reloadData];
    }
}

- (void)setUpView{
    _tableView = ({
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, screenW, self.view.height - 48) style:UITableViewStylePlain];
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        tableView.tableFooterView =[[UIView alloc] initWithFrame:CGRectZero];
        tableView;
        });
    [self.view addSubview:_tableView];
    
}

 //初始化无法获得网络状态,暂时使用此方法判断网络
- (void)detectionNetWork{
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:@"https://m.baidu.com/"]];
    if (data) {
        _isNetWorking = YES;
    }else{
        _isNetWorking = NO;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _historyAndStartArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ZKHistoryANDStartCell *cell = [ZKHistoryANDStartCell cellWithTableView:tableView];
    ZKDetailAbout *model = self.historyAndStartArr[indexPath.row];
    [cell.imgView sd_setImageWithURL:[NSURL URLWithString:model.src] placeholderImage:[UIImage imageNamed:@"Management_Mask"]];
    cell.titleLabel.text = model.title;
    cell.currentLabel.text = [NSString stringWithFormat:@"更新至 %@",model.current];
    cell.playLabel.text = [NSString stringWithFormat:@"观看至 %@",model.currentplaytitle];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if (_isNetWorking) {
        ZKDetailAbout *model = self.historyAndStartArr[indexPath.row];
        ZKVideoController *vc = [[ZKVideoController alloc] initWithAddress:model.href];
        [self.navigationController pushViewController:vc animated:YES];

    }else{
        [MBProgressHUD showError:@"您的网络已断开"];
    }
}

//header高
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 3;
}

//table分割线
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 3)];
    headerView.backgroundColor = [UIColor whiteColor];
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 90;
}


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
     ZKHomeList *homeList = self.historyAndStartArr[indexPath.row];
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [_historyAndStartArr removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        if (_thisType == ZKPlayANDStartHistoryType) {
             [_dataTools deleteOneHistoryOrStartWithTitle:homeList.title withType:getHistory];
        }else{
             [_dataTools deleteOneHistoryOrStartWithTitle:homeList.title withType:getStart];
        }
    }
}

#pragma mark - 网络判断后加载数据
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
