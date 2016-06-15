//
//  ZKVideoController.m
//  peryi
//
//  Created by k on 16/4/28.
//  Copyright © 2016年 ZK. All rights reserved.
//

#import "ZKVideoController.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import "ZFPlayer.h"
#import "ZKHttpTools.h"
#import "MBProgressHUD+Extend.h"
#import <RDVTabBarController/RDVTabBarController.h>
#import "ZKDetailListView.h"
#import "ZKDataTools.h"
#import "ZKDetailAbout.h"
#import "ZKSettingModel.h"
#import "ZKSettingModelTool.h"
#import <MJExtension/MJExtension.h>
@interface ZKVideoController()<UIWebViewDelegate,UIScrollViewDelegate,UIAlertViewDelegate>

/**
 *  详情页面
 */
@property (nonatomic, strong) NSString *strUrl;


@property (nonatomic, strong) ZFPlayerView *playView;

@property (nonatomic, strong) NSDictionary *detailList;

@property (nonatomic, strong) UIWebView *webView;

@property (nonatomic, strong) NSURL *videoUrl;

@property (nonatomic, strong) NSTimer *timer;

@property (nonatomic, strong) ZKDetailListView *detailListView;

@property (nonatomic, assign) BOOL isCreate;


@property (nonatomic, assign) BOOL isStart;

@property (nonatomic, strong) ZKDataTools *dataTools;

@property (nonatomic, strong) UIActivityIndicatorView *activity;

@property (nonatomic, assign) BOOL isNetWorking;
@end

@implementation ZKVideoController


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(isNetWork) name:isNet object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(isNotNetWork) name:isNotNet object:nil];
    //加载完网页后播放视频时才接收通知是否为4G网络
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(is4GWAAN) name:isNotNet object:nil];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
    self.navigationController.navigationBarHidden = YES;
    [[self rdv_tabBarController] setTabBarHidden:YES animated:YES];

}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = NO;
    [UIApplication sharedApplication].statusBarHidden = NO;
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    [[self rdv_tabBarController] setTabBarHidden:NO animated:YES];
}

-(id)initWithAddress:(NSString *)addresUrlStr{
    if (self = [super init]) {
        _isCreate = NO;
        [self setUpAllView];
        _dataTools = [ZKDataTools sharedZKDataTools];
        if ([addresUrlStr rangeOfString:@"html"].location == NSNotFound) {
            _playView.videoURL = [NSURL URLWithString:addresUrlStr];
            _playView.hidden = NO;
            }else{
            _strUrl = addresUrlStr;
            [self loadListDataWithstrUrl:addresUrlStr];
        }
    }
    return self;
}

- (void)viewDidLoad{
    [super viewDidLoad];
}

//缓存的动漫加载相关数据
- (void)setLocalHtml:(NSString *)localHtml{
     _localHtml = localHtml;
     [self loadListDataWithstrUrl:_localHtml];
}

//初始界面
- (void)setUpAllView{
     UIView *topView = [[UIView alloc] init];
     topView.backgroundColor = [UIColor blackColor];
     [self.view addSubview:topView];
    
     [topView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.view);
         make.height.equalTo(@20);
     }];
    //由于zfplayer里，没有写入url就不能初始化点击按钮。因此自定义一个以防视频url为加载出的等待
    UIImageView *imageView = [[UIImageView alloc] init];
    [imageView setImage:[UIImage imageNamed:@"loading_bg"]];
    imageView.userInteractionEnabled = YES;
    [topView addSubview:imageView];
    
    UIButton *backBtn = [[UIButton alloc] init];
    backBtn.enabled = YES;
    [backBtn setImage:[UIImage imageNamed:@"play_back"] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(backtoRootVC) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backBtn];
    
    _activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [self.view addSubview:_activity];
    
    
    //加载播放界面
    if (!_playView) {
         _playView = [[ZFPlayerView alloc] init];
        _playView.backgroundColor = [UIColor blackColor];
        _playView.hidden = YES;
        _playView.hasDownload = YES;
        _isCreate = NO;
        [self.view addSubview:self.playView];
        [self.playView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view).offset(20);
            make.left.right.equalTo(self.view);
            // 注意此处，宽高比16：9优先级比1000低就行，在因为iPhone 4S宽高比不是16：9
            make.height.equalTo(self.playView.mas_width).multipliedBy(9.0f/16.0f).with.priority(750);
        }];
        }
    
      self.playView.playerLayerGravity = ZFPlayerLayerGravityResizeAspect;
      WeakSelf;
      self.playView.goBackBlock = ^(){
          dispatch_async(dispatch_get_main_queue(), ^{
              //退出当前控制器的通知
              [weakSelf outViewControllerNoti];
              [weakSelf.navigationController popViewControllerAnimated:YES];
              [weakSelf deleteAll];
          });
        };
    
    if (!_detailListView) {
        _detailListView = [[ZKDetailListView alloc] init];
        _detailListView.backgroundColor = RGB(241, 241, 241);
        _detailListView.scrollsToTop = YES;
        _detailListView.delegate = self;
        _detailListView.bounces = YES;
        _detailListView.scrollEnabled = YES;
        _detailListView.showsHorizontalScrollIndicator = YES;
        _detailListView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 5, 0, 0);
        [_detailListView flashScrollIndicators];
        _detailListView.directionalLockEnabled = YES;
        WeakSelf;
        _detailListView.myHeight =^(CGFloat myHeight){
            [weakSelf.detailListView setContentSize:CGSizeMake(0, myHeight)];
        };
        _detailListView.playAndDownView.action = ^(NSString *url){
            if (![url hasPrefix:@"http://"]) {
                [weakSelf.view bringSubviewToFront:weakSelf.activity];
                [weakSelf.activity startAnimating];
                [weakSelf getVideoInfoWithUrl:url];
            }else{
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
            }
        };
        //猜你喜欢点击处理
        _detailListView.likeListView.btClick =^(NSString *url){
             [weakSelf loadListDataWithstrUrl:url];
        };
        //收藏按钮
        [_detailListView.infoView.start addTarget:self action:@selector(startOnClick) forControlEvents:UIControlEventTouchDown];
        [self.view addSubview:_detailListView];
    }
    
    
    [self.detailListView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.playView.mas_bottom);
        make.left.right.equalTo(self.view);
        make.bottom.equalTo(@0);
    }];
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(topView).offset(20);
        make.left.right.equalTo(topView);
        make.height.equalTo(imageView.mas_width).multipliedBy(9.0f/16.0f).with.priority(750);
    }];
    [backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(imageView.mas_leading).offset(15);
        make.top.equalTo(imageView.mas_top).offset(5);
        make.width.height.mas_equalTo(30);
    }];
    [_activity mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(imageView);
    }];
    
}

//载入动漫相关数据
- (void)loadListDataWithstrUrl:(NSString *)strUrl{
    ZKHttpTools *http = [ZKHttpTools sharedZKHttpTools];
    //加载列表数据
    WeakSelf;
    [MBProgressHUD showMessage:@"正在加载，请稍候..."];
    [http getDetailDMWithURL:strUrl getDatasuccess:^(NSDictionary *listData) {
        
        [weakSelf getDetailListWithlistdict:listData];
        [MBProgressHUD hideHUD];
        [weakSelf.activity startAnimating];
    }];
}

//=========================================获取视屏网址================================//
//由于需要网页加载后才可得到播放地址。因此添加uiwebview类根据url进入播放页面并得到数据。
- (void)getVideoInfoWithUrl:(NSString *)url{
    url = [NSString stringWithFormat:@"%@%@",baseURL,url];
    self.webView = [[UIWebView alloc] init];
    _webView.delegate = self;
    NSURL* videoUrl = [NSURL URLWithString:url];//创建URL
    NSURLRequest* request = [NSURLRequest requestWithURL:videoUrl];//创建NSURLRequest
    [_webView loadRequest:request];//加载
}

#pragma mark - webview的代理。加载网页完成后获取播放地址并删除uiwebview
- (void)webViewDidFinishLoad:(UIWebView *)webView{

    //加载网页完成后还需加载视频连接
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    NSString *docStr=[webView stringByEvaluatingJavaScriptFromString:@"document.getElementById('cciframe').getAttribute('src')"];//获取
        [_activity stopAnimating];
        _playView.hidden = NO;
        //用于重置播放
        if ([docStr rangeOfString:@"mp4"].location != NSNotFound){
            _playView.hasDownload = YES;
            //从保存里的当前播放数据传递给下载
            NSDictionary *playHistory = [_dataTools getDetailAboutWithTitle:_detailList[@"dmAbout"][@"alt"]];
            _playView.aboutDict = playHistory;
            _playView.urlStr = playHistory[@"href"];
        }else{
            _playView.hasDownload = NO;
        }
        if (_isCreate) {
            [self.playView resetToPlayNewURL];
            self.playView.videoURL = [NSURL URLWithString:docStr];
        }else{
            _isCreate = YES;
            self.playView.videoURL = [NSURL URLWithString:docStr];
        }
        if (docStr != nil){
            [self.webView removeFromSuperview];
            [MBProgressHUD hideHUD];
        }
    });
}


#pragma mark - 其他
//将值传入其他界面显示,存储以及收藏按钮
- (void)getDetailListWithlistdict:(NSDictionary *)dict{
        _detailList = dict;
        _detailListView.detailList = dict;
    
        NSDictionary *aboutInfo = _detailList[@"dmAbout"];
        //不是本地进入播放界面时
        if (!self.localHtml) {
        NSDictionary *playHistory = [_dataTools getDetailAboutWithTitle:aboutInfo[@"alt"]];
            //收藏或播放历史中含有时动漫时从历史开始播放
            if (playHistory.count != 0) {
                ZKDetailAbout *model = [ZKDetailAbout mj_objectWithKeyValues:playHistory];
                [self getVideoInfoWithUrl:model.currentplayhref];
            }else{
                //第一次进入时观看,保存至播放历史
                NSDictionary *playVideoUrl = [NSDictionary dictionary];
                NSArray *playArr = self.detailList[@"dmPlay"];
                if (playArr.count > 2) {// 若播放列表超过1个则默认播放第二个列表第一个
                    playVideoUrl = playArr[1][0];
                }else{
                    playVideoUrl = playArr[0][0];
                }
                ZKDetailAbout *detailModel = [ZKDetailAbout mj_objectWithKeyValues:_detailList[@"dmAbout"]];
                detailModel.currentplaytitle = playVideoUrl[@"title"];
                detailModel.href = _strUrl;
                detailModel.currentplayhref = playVideoUrl[@"href"];
                [_dataTools saveHistroyOrStartWithModel:detailModel withType:saveList];
                //获取播放地址并播放
                [self getVideoInfoWithUrl:playVideoUrl[@"href"]];
            }
        }//判断是否本地进入结束
    
    
        //判断是否是收藏,显示收藏图标
        _isStart = [_dataTools isStartWithTitle:aboutInfo[@"alt"]];
        if (_isStart) {
            _detailListView.infoView.start.selected = YES;
        }else{
            _detailListView.infoView.start.selected = NO;
        }
}

//收藏按钮点击
- (void)startOnClick{
    //初始化后执行的判断
    if (_detailListView.infoView.start.selected) {
        _isStart = YES;
    }else{
        _isStart = NO;
    }
     NSDictionary *aboutInfo = self.detailList[@"dmAbout"];
    if (_isStart) {
        _detailListView.infoView.start.selected = NO;
        [_dataTools deleteOneHistoryOrStartWithTitle:aboutInfo[@"alt"] withType:getStart];
        [MBProgressHUD showSuccess:@"已从收藏移除"];
    }else{
        _detailListView.infoView.start.selected = YES;
        ZKDetailAbout *listModel = [[ZKDetailAbout alloc] init];
        //收藏时，只需传入标题
        listModel.alt = self.detailList[@"dmAbout"][@"alt"];
        [_dataTools saveHistroyOrStartWithModel:listModel withType:saveStart];
        [MBProgressHUD showSuccess:@"已添加至收藏"];
    }
}


#pragma mark - wifi 4g 网络处理
//启用4G网络的时候
- (void)is4GWAAN{
   
    ZKSettingModel *model = [ZKSettingModelTool getSettingWithModel];
    if (![model.isOpenNetwork isEqualToString:@"Yes"]) {
        UIAlertView *aler = [[UIAlertView alloc] initWithTitle:@"您正在使用2G/3G/4G网络" message:@"观看视频会好非大量流量，可能导致运营商向您收取更多费用，强烈建议您连接Wi-Fi后再观看视频。" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"继续播放", nil];
        [aler show];
    }

}

- (void)isNetWork{
    _isNetWorking = YES;
    _detailListView.hidden = NO;
    NSArray *dmPlay = _detailList[@"dmPlay"];
    //若离线进入播放后网络可用即重新加载数据
    if (dmPlay.count < 1) {
        [self loadListDataWithstrUrl:_localHtml];
    }
}

- (void)isNotNetWork{
    _isNetWorking = NO;
    _detailListView.hidden = YES;
}


#pragma mark - alert代理
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0) {
        [_playView pause];
    }
}


//返回按钮方法
- (void)backtoRootVC{
    //如果竖屏时强制改为横屏
    UIInterfaceOrientation oreientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (oreientation == UIInterfaceOrientationLandscapeRight || oreientation == UIInterfaceOrientationLandscapeLeft) {
        if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
            SEL selector             = NSSelectorFromString(@"setOrientation:");
            NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
            [invocation setSelector:selector];
            [invocation setTarget:[UIDevice currentDevice]];
            int val                  = UIInterfaceOrientationPortrait;
            [invocation setArgument:&val atIndex:2];
            [invocation invoke];
        }
    }else{
        //退出当前控制器的通知
        [self outViewControllerNoti];
        [self.navigationController popViewControllerAnimated:YES];
        [self deleteAll];
    }
}

//强制设置屏幕方向
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    if (toInterfaceOrientation == UIInterfaceOrientationPortrait) {
        self.view.backgroundColor = [UIColor whiteColor];
        [self.playView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view).offset(20);
        }];
    }else if (toInterfaceOrientation == UIInterfaceOrientationLandscapeRight || toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft) {
        [self.playView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view).offset(0);
        }];
        self.view.backgroundColor = [UIColor blackColor];
    }
}

- (void)outViewControllerNoti{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"outVideo" object:nil];
}

/**
 *  删除所有view及数据
 */
- (void)deleteAll{
    _strUrl = nil;
    _playView = nil;
    _detailList = nil;
    _webView = nil;
    _videoUrl = nil;
    _timer = nil;
    _detailListView = nil;
    _dataTools = nil;
}


- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.playView cancelAutoFadeOutControlBar];
}
@end
