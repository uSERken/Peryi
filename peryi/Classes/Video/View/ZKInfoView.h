//
//  ZKInfoView.h
//  peryi
//
//  Created by k on 16/4/29.
//  Copyright © 2016年 ZK. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ZKDetailAbout;
@interface ZKInfoView : UIView

+(instancetype)view;

@property (nonatomic, strong) ZKDetailAbout *infoModel;

@property (nonatomic, strong) NSString *synopsis;

@end
