//
//  ZKPageTips.h
//  peryi
//
//  Created by k on 16/5/17.
//  Copyright © 2016年 ZK. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZKPageTips : UIView

+(instancetype)initView;

@property (nonatomic, strong) NSString *currentPageStr;

@property (nonatomic, strong) NSString *lastPageStr;

@end
