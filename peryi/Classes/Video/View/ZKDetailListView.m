//
//  ZKDetailListView.m
//  peryi
//
//  Created by k on 16/4/29.
//  Copyright © 2016年 ZK. All rights reserved.
//

#import "ZKDetailListView.h"
#import "ZKDetailAbout.h"
#import "ZKDetailPlay.h"
#import "ZKDetailDown.h"
#import "ZKDetailYourLike.h"
#import <MJExtension/MJExtension.h>
#import "Masonry.h"



@interface ZKDetailListView()

@property (nonatomic, strong) UIView *catalogBg;

//简介
@property (nonatomic, strong) NSString *synopsis;

@property (nonatomic, strong) ZKDetailAbout *detailAbout;

/**
 *  播放列表模型数组
 */
@property (nonatomic, strong) NSMutableArray *detailPlayList;






@property (nonatomic, assign) CGFloat playY;


@end

@implementation ZKDetailListView

- (instancetype)init{
   self =  [super init];
    if (self) {
      [self setUpAllView];
    }
    return self;
}

- (void)setDetailList:(NSDictionary *)detailList{
    _detailList = detailList;
    [self getListModelFromDict];
}


- (void)setUpAllView{
    if (!_infoView) {
        _infoView = [ZKInfoView view];
        _infoView.backgroundColor = [UIColor whiteColor];
        _infoView.frame = CGRectMake(0, 0, screenW, 80);
        [self addSubview:_infoView];
    }
    
    if (!_playAndDownView) {
        _playAndDownView = [ZKPlayAndDownloadView view];
        [self addSubview:_playAndDownView];
        [_playAndDownView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.infoView.mas_bottom).offset(8);
            make.right.and.right.equalTo(self.infoView);
            make.size.mas_equalTo(CGSizeMake(screenW, 300));
        }];
    }
   
    if (!_likeListView) {
        _likeListView = [ZKLikeListView view];
        _likeListView.backgroundColor = [UIColor whiteColor];
        [self addSubview:_likeListView];
        [_likeListView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.playAndDownView.mas_bottom).offset(8);
            make.right.and.right.equalTo(self.infoView);
            make.size.mas_equalTo(CGSizeMake(screenW, 900));
        }];
    }
}

//获取数据
- (void)getListModelFromDict{
    self.detailPlayList = [NSMutableArray array];
    _infoView.synopsis = _detailList[@"dmSynopsis"];
    _infoView.infoModel = [ZKDetailAbout mj_objectWithKeyValues:_detailList[@"dmAbout"]];
    //猜你喜欢
    _likeListView.likeArr = [ZKDetailYourLike mj_objectArrayWithKeyValuesArray:_detailList[@"dmYourLike"]];
    
    //下载
    _playAndDownView.downModelList = [ZKDetailDown mj_objectArrayWithKeyValuesArray:_detailList[@"dmDownload"]];
    //当前动画名字
    _playAndDownView.title = _detailList[@"dmAbout"][@"alt"];
    //播放列表数组
    NSArray *playArr = _detailList[@"dmPlay"];
    for (int i = 0; i < playArr.count; i ++) {
        NSArray *modelArr = [ZKDetailPlay mj_objectArrayWithKeyValuesArray:playArr[i]];
        [self.detailPlayList addObject:modelArr];
    }
    _playAndDownView.playModelList = self.detailPlayList;
    if (_myHeight) {
         CGFloat height = CGRectGetHeight(_likeListView.frame) + CGRectGetHeight(_playAndDownView.frame) + CGRectGetHeight(_infoView.frame) - 20;
        _myHeight(height);
    }

}

@end
