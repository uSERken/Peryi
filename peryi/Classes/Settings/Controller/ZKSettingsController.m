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
#import "SDImageCache.h"
#import "MBProgressHUD+Extend.h"
#import "ZKSettingModel.h"
#import "ZKSettingModelTool.h"
#import <MessageUI/MessageUI.h>

@interface ZKSettingsController()<UITableViewDelegate,UITableViewDataSource,UIAlertViewDelegate,MFMailComposeViewControllerDelegate>

@property (nonatomic, strong) UITableView *tabelView;

@property (nonatomic, strong) NSArray *functionArr;

@property (nonatomic, strong) ZKSettingModel *model;

@property (nonatomic,assign)BOOL isNetWorking;
@end

@implementation ZKSettingsController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    _model = [ZKSettingModelTool getSettingWithModel];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(isNetWork) name:isNet object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(isNotNetWrok) name:isNotNet object:nil];
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
//            tableView.tableFooterView =[[UIView alloc] initWithFrame:CGRectZero];
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
        return 3;
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
            if ([_model.isOpenNetwork isEqualToString:@"Yes"]) {
                switchview.on = YES;
            }else{
                switchview.on = NO;
            }
        }
    }else{
        if (indexPath.row == 0) {
            cell.textLabel.text = @"吐槽反馈";
        }else if(indexPath.row == 1){
            cell.textLabel.text = @"给我们好评";
        }else{
            cell.textLabel.text = @"关于";
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    if (indexPath.section == 0) {
        ZKDownLoadController *downC = [[ZKDownLoadController alloc] init];
        [self pushControllerWithController:downC];
    }else if(indexPath.section == 1){
        if (indexPath.row == 0) {
            ZKPlayANDStarTableVC *StartVC = [[ZKPlayANDStarTableVC alloc] initControllerWithType:ZKPlayANDStartCollectionType];
            StartVC.isNetWorking = _isNetWorking;
            [self pushControllerWithController:StartVC];
        }else{
            ZKPlayANDStarTableVC *HisttoryVC = [[ZKPlayANDStarTableVC alloc] initControllerWithType:ZKPlayANDStartHistoryType];
             [self pushControllerWithController:HisttoryVC];
        }
    }else if(indexPath.section == 2){
        if (indexPath.row == 0) {
            UIAlertView *aler =[[UIAlertView alloc] initWithTitle:@"提示" message:@"您确定清除缓存吗？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
            [aler show];
         }
    }else{
        if (indexPath.row == 0) {
        #if TARGET_IPHONE_SIMULATOR//模拟器
            NSLog(@"模拟器无邮件服务");
        #elif TARGET_OS_IPHONE//真机
           [self tucao];
        #endif
           
        }else if(indexPath.row == 1){
            
        }else{
            ZKAboutVC  *aboutVC = [[ZKAboutVC alloc] init];
            [self pushControllerWithController:aboutVC];
        }
    }

    
}

- (void)pushControllerWithController:(UIViewController *)VC{
    [self.navigationController pushViewController:VC animated:YES];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    
    return @"";
}



- (void)updateSwitchAtIndexPath:(id)sender{
    UISwitch *switchView = (UISwitch *)sender;
    ZKSettingModel *model = [[ZKSettingModel alloc] init];
    if ([switchView isOn]){
        model.isOpenNetwork = @"Yes";
        [ZKSettingModelTool saveSettingWithModel:model];
        [MBProgressHUD showSuccess:@"开启3G/4G播放"];
    }
    else{
        model.isOpenNetwork = @"No";
        [ZKSettingModelTool saveSettingWithModel:model];
        [MBProgressHUD showSuccess:@"关闭3G/4G播放"];
    }
    _model = nil;
}

#pragma mark - 提示代理
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1) {
        [NSFileManager clearPicture];
        [self.tabelView reloadData];
    }
}


#pragma mark - 反馈吐槽
/** 模拟器回调试失败
 *  反馈吐槽
 */
- (void)tucao{
    MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
    mc.mailComposeDelegate = self;
    [mc setSubject:@"Peryi-反馈吐槽"];
    [mc setToRecipients:[NSArray arrayWithObjects:@"1413144585@qq.com", nil]];
    [self presentViewController:mc animated:YES completion:nil];
}

- (void)mailComposeController:(MFMailComposeViewController*)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError*)error {
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"取消发送");
            break;
        case MFMailComposeResultSaved:
            [MBProgressHUD showSuccess:@"保存成功"];
            break;
        case MFMailComposeResultSent:
            [MBProgressHUD showSuccess:@"邮件已发送"];
            break;
        case MFMailComposeResultFailed:
            [MBProgressHUD showError:@"发送失败，请重新发送"];
            break;
        default:
            break;
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)isNetWork{
    _isNetWorking = YES;
}

- (void)isNotNetWrok{
    _isNetWorking = NO;
}
- (void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

@end
