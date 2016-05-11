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
#import <SVWebViewController/SVWebViewController.h>
@interface ZKVideoController()<UIWebViewDelegate,UIScrollViewDelegate>

/**
 *  详情页面
 */
@property (nonatomic, strong) NSString *strUrl;

@property (nonatomic, strong) VBFPopFlatButton *playBtn;

@property (nonatomic, strong) ZFPlayerView *playView;

@property (nonatomic, strong) NSDictionary *detailList;

@property (nonatomic, strong) UIWebView *webView;

@property (nonatomic, strong) NSURL *videoUrl;

@property (nonatomic, strong) NSTimer *timer;

@property (nonatomic, strong) ZKDetailListView *detailListView;

@property (nonatomic, assign) BOOL isCreate;

@property (nonatomic, strong) SVWebViewController *webViewController;



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
{   _isCreate = NO;
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

-(id) initWithAddress:(NSString *)addresUrlStr{
    if (self = [super init]) {
        self.strUrl = addresUrlStr;
    }
    return self;
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
        _isCreate = NO;
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
        _detailListView.backgroundColor = RGB(241, 241, 241);
        _detailListView.scrollsToTop = YES;
        _detailListView.delegate = self;
        _detailListView.bounces = YES;
        _detailListView.scrollEnabled = YES;
        _detailListView.showsHorizontalScrollIndicator = YES;
        _detailListView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 5, 0, 0);
        [_detailListView flashScrollIndicators];
        _detailListView.directionalLockEnabled = YES;
//        _detailListView.contentSize = CGSizeMake(0, 460*3);
        WeakSelf;
        _detailListView.myHeight =^(CGFloat myHeight){
            [weakSelf.detailListView setContentSize:CGSizeMake(0, myHeight)];
        };
        _detailListView.playAndDownView.action = ^(NSString *url){
            if (![url hasPrefix:@"http://"]) {
                [weakSelf getVideoInfoWithUrl:url];
            }else{
                SVModalWebViewController *webViewController = [[SVModalWebViewController alloc] initWithAddress:url];
                [weakSelf presentViewController:webViewController animated:YES completion:NULL];
            }
        };
        _detailListView.likeListView.btClick =^(NSString *url){
             [weakSelf loadListDataWithstrUrl:url];
        };
        [self.view addSubview:_detailListView];
        
        [self.detailListView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.playView.mas_bottom);
            make.left.right.equalTo(self.view);
            make.bottom.equalTo(@0);
        }];  
    }
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
        
        //用于重置播放
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
