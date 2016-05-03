//
//  ZKVideoController.m
//  peryi
//
//  Created by k on 16/4/28.
//  Copyright © 2016年 ZK. All rights reserved.
//

#import "ZKVideoController.h"
#import <VBFPopFlatButton/VBFPopFlatButton.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import <ZFPlayer/ZFPlayer.h>
#import "ZKHttpTools.h"
#import "MBProgressHUD+Extend.h"
#import <RDVTabBarController/RDVTabBarController.h>
#import "ZKDetailListView.h"
@interface ZKVideoController()<UIWebViewDelegate,UIScrollViewDelegate>

@property (nonatomic, strong) VBFPopFlatButton *playBtn;

@property (nonatomic, strong) ZFPlayerView *playView;

@property (nonatomic, strong) NSDictionary *detailList;

@property (nonatomic, strong) UIWebView *webView;

@property (nonatomic, strong) NSURL *videoUrl;

@property (nonatomic, strong) NSTimer *timer;

@property (nonatomic, strong) ZKDetailListView *detailListView;

@end

@implementation ZKVideoController


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
    self.navigationController.navigationBarHidden = YES;
    
    [[self rdv_tabBarController] setTabBarHidden:YES animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = NO;
    [UIApplication sharedApplication].statusBarHidden = NO;
    [[self rdv_tabBarController] setTabBarHidden:NO animated:YES];
}

- (void)viewDidLoad{
    [super viewDidLoad];
    
    [self setUpAllView];
    
    [self loadListDataWithstrUrl:self.strUrl];
}


- (void)setUpAllView{
    [self.navigationController.navigationBar setHidden:YES];
    
     UIView *topView = [[UIView alloc] init];
     topView.backgroundColor = [UIColor blackColor];
     [self.view addSubview:topView];
     [topView mas_updateConstraints:^(MASConstraintMaker *make) {
     make.top.left.right.equalTo(self.view);
     make.height.mas_offset(20);
     }];
     
    if (!_playView) {
         _playView = [[ZFPlayerView alloc] init];
        _playView.backgroundColor = [UIColor blackColor];
        [self.view addSubview:self.playView];
        
        [self.playView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view).offset(20);
            make.left.right.equalTo(self.view);
            // 注意此处，宽高比16：9优先级比1000低就行，在因为iPhone 4S宽高比不是16：9
            make.height.equalTo(self.playView.mas_width).multipliedBy(9.0f/16.0f).with.priority(750);
        }];
        
        }

    
      self.playView.hasDownload = YES;
      self.playView.playerLayerGravity = ZFPlayerLayerGravityResizeAspect;
      __weak typeof(self) weakSelf = self;
      self.playView.goBackBlock = ^(){
        [weakSelf.navigationController popViewControllerAnimated:YES];
        };
    
    
    if (!_detailListView) {
        _detailListView = [[ZKDetailListView alloc] init];
        _detailListView.backgroundColor = [UIColor grayColor];
        
        //    scrollView.scrollsToTop = NO;
        _detailListView.delegate = self;
        // 设置内容大小
        _detailListView.contentSize = CGSizeMake(0, 460*3);
        // 是否反弹
        _detailListView.bounces = YES;
        // 是否滚动
        _detailListView.scrollEnabled = YES;
        _detailListView.showsHorizontalScrollIndicator = YES;
        _detailListView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 5, 0, 0);
        // 提示用户,Indicators flash
        [_detailListView flashScrollIndicators];
        // 是否同时运动,lock
        _detailListView.directionalLockEnabled = YES;
        
        [self.view addSubview:_detailListView];
        [self.detailListView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.playView.mas_bottom);
            make.left.right.equalTo(self.view);
            make.bottom.equalTo(@0);
        }];
    }
    /*
    
    if (!_playBtn) {
        _playBtn = [[VBFPopFlatButton alloc] initWithFrame:CGRectMake((self.playView.width - 64)/2, (self.playView.height - 64)/2,44,44) buttonType:buttonRightTriangleType buttonStyle:buttonPlainStyle animateToInitialState:YES];
        [_playBtn addTarget:self action:@selector(playVideo) forControlEvents:UIControlEventTouchUpInside];
        _playBtn.roundBackgroundColor = RGB(92, 149, 219);
        _playBtn.lineThickness = 2;
        _playBtn.tintColor = [UIColor whiteColor];
        
        [_playView addSubview:_playBtn];
    }
    [self.playBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.playView);
        
    }];
     */

    
}


- (void)loadListDataWithstrUrl:(NSString *)strUrl{
    ZKHttpTools *http = [ZKHttpTools sharedZKHttpTools];
    
    //加载列表数据
    WeakSelf;
    [http getDetailDMWithURL:strUrl getDatasuccess:^(NSDictionary *listData) {
        weakSelf.detailList = listData;
        [weakSelf timerToGetValue];
        //         NSLog(@"%@,",listData);
        //视屏播放
    }];
    

    

}



- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
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


//=========================================获取视屏网址================================//
//由于需要网页加载后才可得到播放地址。因此添加uiwebview类根据url进入播放页面并得到数据。
- (void)getVideoInfoWithUrl:(NSString *)url{
    [MBProgressHUD showMessage:@"正在加载，请稍候..."];
    url = [NSString stringWithFormat:@"%@%@",baseURL,url];
    self.webView = [[UIWebView alloc] init];
    _webView.delegate = self;
    NSURL* videoUrl = [NSURL URLWithString:url];//创建URL
    NSURLRequest* request = [NSURLRequest requestWithURL:videoUrl];//创建NSURLRequest
    [_webView loadRequest:request];//加载
}
//webview的代理。加载网页完成后获取播放地址并删除uiwebview
- (void)webViewDidFinishLoad:(UIWebView *)webView{
  
    //加载网页完成后还需加载视频连接
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    NSString *docStr=[webView stringByEvaluatingJavaScriptFromString:@"document.getElementById('cciframe').getAttribute('src')"];//获取
//        self.videoUrl=
        self.playView.videoURL = [NSURL URLWithString:docStr];
        NSLog(@"%@",docStr);
        if (docStr != nil){
            [self.webView removeFromSuperview];
            [MBProgressHUD hideHUD];
        }
    });
}



#pragma mark - 其他
/*
 -(void)playVideo{
 //防止多次点击
 NSInteger count = 0;
 if (count == 0) {
 self.playView.videoURL = self.videoUrl;
 }
 ++count;
 [self.playBtn  removeFromSuperview];
 }
 */

- (void)timerToGetValue{
    [MBProgressHUD showMessage:@"正在加载,请稍候"];
    //定时器
    self.timer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(timerAction) userInfo:nil repeats:YES];
    //加入循环进程
    [[NSRunLoop mainRunLoop] addTimer:_timer forMode:NSDefaultRunLoopMode];
    //立即触发
    [_timer fire];
}

- (void)timerAction{
    if (self.detailList.count > 0) {
        _detailListView.detailList = self.detailList;
        [MBProgressHUD hideHUD];
        
        NSDictionary *playVideoUrl = self.detailList[@"dmPlay"][0][0];
        
        [self getVideoInfoWithUrl:playVideoUrl[@"href"]];
        
        NSLog(@"%@",playVideoUrl[@"href"]);
        
         [self.timer invalidate];
        
    }
}


- (void)dealloc{
    [self.playView cancelAutoFadeOutControlBar];
}


@end
