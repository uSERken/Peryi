//
//  ZKDetailListView.h
//  peryi
//
//  Created by k on 16/4/29.
//  Copyright © 2016年 ZK. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "ZKPlayAndDownloadView.h"
#import "ZKLikeListView.h"

typedef void(^ZKDetailListViewContentBlock)(CGFloat height);

@interface ZKDetailListView : UIScrollView

@property (nonatomic, strong) NSDictionary *detailList;

//播放列表和下载列表界面
@property (nonatomic, strong) ZKPlayAndDownloadView *playAndDownView;

@property (nonatomic, strong) ZKLikeListView *likeListView;

@property (nonatomic, copy) ZKDetailListViewContentBlock myHeight;


@end
