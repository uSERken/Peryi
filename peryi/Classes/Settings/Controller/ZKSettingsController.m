//
//  ZKSettingsController.m
//  peryi
//
//  Created by k on 16/4/25.
//  Copyright © 2016年 ZK. All rights reserved.
//

#import "ZKSettingsController.h"
#import "ZKDownLoadController.h"
#import "ZKPlayANDStarTableVC.h"
#import "ZKAboutVC.h"
#import "NSFileManager+ZKCache.h"
#import <SDImageCache.h>

@interface ZKSettingsController()<UITableViewDelegate,UITableViewDataSource,UIAlertViewDelegate>

@property (nonatomic, strong) UITableView *tabelView;

@property (nonatomic, strong) NSArray *functionArr;


@end

@implementation ZKSettingsController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self.tabelView reloadData];
}

- (void)viewDidLoad{
    [super viewDidLoad];
    self.title = @"设置";
    [self initView];
    
    
}

- (void)initView{
    self.view.backgroundColor = RGB(238, 238, 244);
    if (!_tabelView) {
        _tabelView = ({
            UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStyleGrouped];
            tableView.backgroundColor = [UIColor clearColor];
            tableView.delegate = self;
            tableView.dataSource = self;
            tableView.scrollEnabled = NO;
            tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
            tableView.tableFooterView =[[UIView alloc] initWithFrame:CGRectZero];
            tableView;
        });
        [self.view addSubview:_tabelView];
    }
}



#pragma mark - tableview delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if (section == 0) {
        return 1;
    }else if(section == 1){
        return 2;
    }else if(section == 2){
        return 2;
    }else{
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *ID = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:ID];
    }
    cell.textLabel.textAlignment = NSTextAlignmentLeft;
    if (indexPath.section == 0) {
        cell.textLabel.text = @"离线缓存";
    }else if(indexPath.section == 1){
        if (indexPath.row == 0) {
            cell.textLabel.text = @"收藏列表";
        }else{
            cell.textLabel.text = @"播放历史";
        }
    }else if(indexPath.section == 2){
        if (indexPath.row == 0) {
//            NSInteger cacheSize = [[SDImageCache sharedImageCache] getSize] /1024.0/1024.0;
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%.2f MB",[NSFileManager getPictureCacheSize]];
            cell.textLabel.text = @"清除缓存";
        }else{
         UISwitch *switchview = [[UISwitch alloc] initWithFrame:CGRectZero];
         [switchview addTarget:self action:@selector(updateSwitchAtIndexPath:) forControlEvents:UIControlEventValueChanged];
         cell.accessoryView = switchview;
         cell.textLabel.text = @"是否允许3G/4G播放";
        }
    }else{
//        cell.textLabel.textAlignment = NSTextAlignmentCenter;
         cell.textLabel.text = @"关于";
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    UIViewController *viewVC = [UIViewController new];
    if (indexPath.section == 0) {
        ZKDownLoadController *downC = [[ZKDownLoadController alloc] init];
        viewVC = downC;
    }else if(indexPath.section == 1){
        if (indexPath.row == 0) {
            ZKPlayANDStarTableVC *StartVC = [[ZKPlayANDStarTableVC alloc] initControllerWithType:ZKPlayANDStartCollectionType];
            viewVC = StartVC;
        }else{
            ZKPlayANDStarTableVC *HisttoryVC = [[ZKPlayANDStarTableVC alloc] initControllerWithType:ZKPlayANDStartHistoryType];
            viewVC = HisttoryVC;
        }
    }else if(indexPath.section == 2){
        if (indexPath.row == 0) {
            UIAlertView *aler =[[UIAlertView alloc] initWithTitle:@"提示" message:@"您确定清除缓存吗？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
            [aler show];
         }
    }else{
        ZKAboutVC  *aboutVC = [[ZKAboutVC alloc] init];
        viewVC = aboutVC;
    }
    if (indexPath.section != 2) {
     [self.navigationController pushViewController:viewVC animated:YES];
    }
    
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    
    return @"";
}

- (void)updateSwitchAtIndexPath:(id)sender{
    UISwitch *switchView = (UISwitch *)sender;
    if ([switchView isOn]){
        NSLog(@"开");
    }
    else{
        NSLog(@"关");
    }
}

#pragma mark - 提示代理
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1) {
        [NSFileManager clearPicture];
        [self.tabelView reloadData];
    }
}

@end
