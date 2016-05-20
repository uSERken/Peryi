//
//  ZKDMListTouchVC.m
//  peryi
//
//  Created by k on 16/5/19.
//  Copyright © 2016年 ZK. All rights reserved.
//

#import "ZKDMListTouchVC.h"
#import "ZKVideoController.h"
#import "AppDelegate.h"
#import "ZKMainController.h"
#import "ZKNavigationController.h"
#import "ZKMainController.h"
#import "ZKDMListTouchView.h"
#import "ZKHttpTools.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "ZKDataTools.h"
#import "ZKHomeList.h"
#import "ZKDetailAbout.h"
#import <MJExtension/MJExtension.h>
@interface ZKDMListTouchVC ()

@property (nonatomic, strong) NSString *urlStr;

@property (nonatomic, strong) ZKDMListTouchView *infoView;

@property (nonatomic, strong) UIActivityIndicatorView *activity;



@end

@implementation ZKDMListTouchVC

- (instancetype)initWithUrlStr:(NSString *)urlStr bgColor:(UIColor *)bgc
{
    if (self = [super init]) {
        _urlStr = urlStr;
        [self setUpView];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    
}

- (void)setUpView{
    self.view.backgroundColor = [UIColor whiteColor];
    _infoView = [ZKDMListTouchView initViewWithFrame:self.view.frame];
    _infoView.hidden = YES;
     [self.view addSubview:_infoView];
    _activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [_activity setCenter:self.view.center];
    [self.view addSubview:_activity];
    [_activity startAnimating];
   
}

- (void)setDetailList:(NSDictionary *)detailList{
    _detailList = detailList;
    if (_detailList != nil) {
        _infoView.hidden = NO;
        ZKDetailAbout *about = [ZKDetailAbout mj_objectWithKeyValues:_detailList[@"dmAbout"]];
        _infoView.titleLabel.text = about.alt;
        _infoView.typeLabel.text = about.about[@"classification"];
        _infoView.currentLabel.text = about.about[@"update"];
        _infoView.timeLabel.text = about.about[@"updateTime"];
        _infoView.sourceLabel.text = about.souce;
        _infoView.infoLabel.text = _detailList[@"dmSynopsis"];
        [_infoView.imgView sd_setImageWithURL:[NSURL URLWithString:about.src]];
        
    }else{
        UILabel *label = [[UILabel alloc] initWithFrame:self.view.frame];
        label.textAlignment = NSTextAlignmentCenter;
        label.text = @"您的网络好像断开了😭";
        [self.view addSubview:label];
    }
     [_activity stopAnimating];
}

#pragma mark - 选择代理
- (NSArray<id<UIPreviewActionItem>> *)previewActionItems{
    UIPreviewAction *watch = [UIPreviewAction actionWithTitle:@"观看" style:UIPreviewActionStyleDestructive handler:^(UIPreviewAction * _Nonnull action, UIViewController * _Nonnull previewViewController) {
        ZKVideoController *viewVc = [[ZKVideoController alloc] initWithAddress:self.urlStr];
        [(UINavigationController *)[self topViewController] pushViewController:viewVc animated:YES];
    }];
    NSArray * actions = @[watch];
    
    return actions;
}

- (UIViewController *)topViewController{
    ZKMainController *VC = (ZKMainController *)[AppDelegate appDelegate].window.rootViewController;
    return VC.selectedViewController ;
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
