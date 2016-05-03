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
#import "ZKInfoView.h"



@interface ZKDetailListView()

@property (nonatomic, strong) UIView *catalogBg;

//简介
@property (nonatomic, strong) NSString *synopsis;

@property (nonatomic, strong) ZKDetailAbout *detailAbout;

/**
 *  你喜欢列表模型数组
 */
@property (nonatomic, strong) NSArray *detailYourLike;

/**
 *  播放列表模型数组
 */
@property (nonatomic, strong) NSMutableArray *detailPlayList;

/**
 *  下载列表模型数组
 */
@property (nonatomic, strong) NSMutableArray *detailDownList;

//界面
@property (nonatomic, strong)  ZKInfoView *infoView;


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
        _infoView.frame = CGRectMake(0, 0, screenW, 210);
        [self addSubview:_infoView];
    }
   
    
}

//获取数据
- (void)getListModelFromDict{
    self.detailPlayList = [NSMutableArray array];
    self.detailDownList = [NSMutableArray array];
    
    self.synopsis = _detailList[@"dmSynopsis"];
    _infoView.synopsis = self.synopsis;
    
    
    self.detailAbout = [ZKDetailAbout mj_objectWithKeyValues:_detailList[@"dmAbout"]];
    _infoView.infoModel = self.detailAbout;
    
    self.detailYourLike = [ZKDetailYourLike mj_objectArrayWithKeyValuesArray:_detailList[@"dmYourLike"]];
    
    for (NSArray *playArr in _detailList[@"dmPlay"]) {
        NSArray *modelArr = [ZKDetailPlay mj_objectArrayWithKeyValuesArray:playArr];
        [self.detailPlayList addObject:modelArr];
    }
    self.detailDownList = [ZKDetailDown mj_objectArrayWithKeyValuesArray:_detailList[@"dmDownload"]];;

//    [_detailList writeToFile:@"/Users/k/Desktop/test.plist" atomically:YES];
    
}

@end
