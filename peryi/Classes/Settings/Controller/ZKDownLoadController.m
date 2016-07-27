//
//  ZKDownLoadController.m
//  peryi
//
//  Created by k on 16/5/12.
//  Copyright © 2016年 ZK. All rights reserved.
//

#import "ZKDownLoadController.h"
#import "ZFPlayer.h"
#import "ZKDownLoadingCell.h"
#import "ZKDownloadCompleteCell.h"
#import "ZKVideoController.h"
#import "MBProgressHUD+Extend.h"
@interface ZKDownLoadController ()<UITableViewDelegate,UITableViewDataSource,ZFDownloadDelegate,UIAlertViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *donwloadArr;
//判断是否已经提醒
@property (nonatomic,assign) BOOL  isAlert;
@end

@implementation ZKDownLoadController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"DownLoadPage"];
    _isAlert = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(isNotNetWork) name:isNotNet object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(isNetWork) name:isNet object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(is4GWAAN) name:isWWAN object:nil];
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [MobClick endLogPageView:@"DownLoadPage"];
}
- (void)viewDidLoad {
     [super viewDidLoad];
      self.title = @"离线缓存";
     [self setUpView];
     self.view.backgroundColor = [UIColor whiteColor];
     [self initData];
    
}

- (void)setUpView{
    _tableView = ({
        UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain];
        tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.tableFooterView =[[UIView alloc] initWithFrame:CGRectZero];
        tableView;
    });
    [self.view addSubview:_tableView];
}

- (void)initData{
    self.donwloadArr = nil;
    [self.tableView reloadData];
}

- (NSMutableArray *)donwloadArr{
    if (!_donwloadArr) {
        NSMutableArray *downloads = [[ZFDownloadManager sharedInstance] getSessionModels].mutableCopy;
        NSMutableArray *downladed = @[].mutableCopy;
        NSMutableArray *downloading = @[].mutableCopy;
        for (ZFSessionModel *obj in downloads) {
            if ([[ZFDownloadManager sharedInstance] isCompletion:obj.url]) {
                [downladed addObject:obj];
            }else {
                [downloading addObject:obj];
            }
        }
        _donwloadArr = @[].mutableCopy;
        [_donwloadArr addObject:downladed];
        [_donwloadArr addObject:downloading];
    }
    return _donwloadArr;
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *sectionArray = self.donwloadArr[section];
    return sectionArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    __block ZFSessionModel *downloadObject = self.donwloadArr[indexPath.section][indexPath.row];
    if (indexPath.section == 0) {
        ZKDownloadCompleteCell *cell = [ZKDownloadCompleteCell cellWithTableView:tableView];
        cell.sessionModel = downloadObject;
        return cell;
    }else{
        ZKDownLoadingCell *cell = [ZKDownLoadingCell cellWithTableView:tableView];
        cell.sessionModel = downloadObject;
        [ZFDownloadManager sharedInstance].delegate = self;
        cell.downloadBlock = ^ {
            [[ZFDownloadManager sharedInstance] download:downloadObject.url withHtmlStr:(NSString *)downloadObject.urlStr withAbout:downloadObject.aboutDict progress:^(CGFloat progress, NSString *speed, NSString *remainingTime, NSString *writtenSize, NSString *totalSize) {} state:^(DownloadState state) {}];
        };
        
        [self setDownLoadBtnForCell:cell];
        return cell;
    }
}

- (void)setDownLoadBtnForCell:(ZKDownLoadingCell *)cell{
    if (_is4G && !_is4GSwitchOpen) {
        cell.downloadBtn.enabled = NO;
        if (_isAlert) {
            _isAlert = NO;
            [self alertMessage];
        }
    }else if((_is4G = nil)){
        [MBProgressHUD showError:@"您的网络已断开"];
        cell.downloadBtn.enabled = NO;
    }else{
        cell.downloadBtn.enabled = YES;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    ZFSessionModel *model= self.donwloadArr[indexPath.section][indexPath.row];
    BOOL isDownCompleted = [[ZFDownloadManager sharedInstance] isCompletion:model.url];
    if (isDownCompleted) {
        NSString *url = [NSString stringWithFormat:@"file://%@",ZFFileFullpath(model.fileName)];
            ZKVideoController *videoVC = [[ZKVideoController alloc] initWithAddress:url];
            videoVC.localHtml = model.urlStr;
            videoVC.is4G = _is4G;
            [self.navigationController pushViewController:videoVC animated:YES];
        }
}



-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableArray *downloadArray = _donwloadArr[indexPath.section];
    ZFSessionModel * downloadObject = downloadArray[indexPath.row];
    // 根据url删除该条数据
    [[ZFDownloadManager sharedInstance] deleteFile:downloadObject.url];
    [downloadArray removeObject:downloadObject];
    [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationBottom];
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath{
    return @"删除";
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @[@"下载完成",@"下载中"][section];
}


#pragma mark - 下载代理
- (void)downloadResponse:(ZFSessionModel *)sessionModel{
    if (self.donwloadArr) {
        // 取到对应的cell上的model
        NSArray *downloadings = self.donwloadArr[1];
        for (ZFSessionModel *model in downloadings) {
            if ([model.url isEqualToString:sessionModel.url]) {
                // 取到当前下载model在数组的位置，来确定cell的具体位置
                NSInteger index = [downloadings indexOfObject:model];
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:1];
                __weak ZKDownLoadingCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
                __weak typeof(self) weakSelf = self;
                sessionModel.progressBlock = ^(CGFloat progress, NSString *speed, NSString *remainingTime, NSString *writtenSize, NSString *totalSize) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        cell.progressLabel.text = [NSString stringWithFormat:@"%@/%@ (%.2f%%)",writtenSize,totalSize,progress*100];
                        cell.speedLabel.text    = speed;
                        cell.progress.progress  = progress;
                        cell.downloadBtn.selected = YES;
                    });
                };
               
                sessionModel.stateBlock = ^(DownloadState state){
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (state == DownloadStateStart) {
                        }else if (state == DownloadStateCompleted) {
                            // 更新数据源
                            [weakSelf initData];
                        }else if (state == DownloadStateSuspended) {
                            //延迟0.1秒，以免下载进程关闭后仍未完全关闭
                            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                    cell.speedLabel.text = @"已暂停";
                                    cell.downloadBtn.selected = NO;
                            });
                        }
                    });
                };
            }
        }
    }
    
    
}



#pragma mark - 网络判断后加载数据
- (void)isNetWork{
    _is4G = NO;
    [self.tableView reloadData];
}

- (void)isNotNetWork{
    _is4G = nil;
    [self.tableView reloadData];
}

- (void)is4GWAAN{
    _is4G = YES;
    if (!_is4GSwitchOpen) {
        NSArray *downArr = _donwloadArr[1];
        for (int i = 0; i < downArr.count; i++) {
            ZFSessionModel *model = downArr[i];
            [[ZFDownloadManager sharedInstance] pause:model.url];
        }
        [self alertMessage];
    }
    [self.tableView reloadData];
}

- (void)alertMessage{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"注意" message:@"您正使用4G 网络。如需使用4G下载，请在设置中开启！" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alert show];
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
