//
//  ZKDownLoadController.h
//  peryi
//
//  Created by k on 16/5/12.
//  Copyright © 2016年 ZK. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZKDownLoadController : UIViewController
//网络状态
@property (nonatomic,assign) netWorkStatus netWorkStatus;
//判断是否开启4G 播放下载
@property (nonatomic,assign) BOOL is4GSwitchOpen;

@end
