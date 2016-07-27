//
//  ZKDownLoadController.h
//  peryi
//
//  Created by k on 16/5/12.
//  Copyright © 2016年 ZK. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZKDownLoadController : UIViewController
//为 nil 时无网络，NO 时是 wifi，YES 时是4G 网络
@property (nonatomic,assign)BOOL is4G;
//判断是否开启4G 播放下载
@property (nonatomic,assign) BOOL is4GSwitchOpen;

@end
