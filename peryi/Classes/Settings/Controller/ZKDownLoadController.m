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
@interface ZKDownLoadController ()<UITableViewDelegate,UITableViewDataSource,ZFDownloadDelegate>

@property (nonatomic, strong) UITableView *tableView;


@property (nonatomic, strong) NSMutableArray *donwloadArr;

@end

@implementation ZKDownLoadController

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
                    });
                };
                sessionModel.stateBlock = ^(DownloadState state){
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (state == DownloadStateStart) {
                            [cell addDownloadAnimation];
                        }else if (state == DownloadStateCompleted) {
                            // 更新数据源
                            [weakSelf initData];
                            [cell removeDownloadAnimtion];
                        }else if (state == DownloadStateSuspended) {
                            [cell removeDownloadAnimtion];
                            cell.speedLabel.text = @"已暂停";
                        }
                    });
                };
            }
        }
    }

    
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
        return cell;
    }
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    ZFSessionModel *model= self.donwloadArr[indexPath.section][indexPath.row];
    NSString *url = [NSString stringWithFormat:@"file://%@",ZFFileFullpath(model.fileName)];
    ZKVideoController *videoVC = [[ZKVideoController alloc] initWithAddress:url];
    videoVC.localHtml = model.urlStr;
    [self.navigationController pushViewController:videoVC animated:YES];
    
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


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
