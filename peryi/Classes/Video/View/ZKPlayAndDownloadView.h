//
//  ZKPlayAndDownloadView.h
//  peryi
//
//  Created by k on 16/5/3.
//  Copyright © 2016年 ZK. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^ZKPlayAndDownloadViewActionBlock)(NSString *url);

@interface ZKPlayAndDownloadView : UIView

+(instancetype)view;

@property (nonatomic, strong) NSString *title;

@property (nonatomic, strong) NSArray *playModelList;

@property (nonatomic, strong) NSArray *downModelList;

@property (nonatomic, copy) ZKPlayAndDownloadViewActionBlock action;


@end
