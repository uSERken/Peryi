//
//  ZKHomeList.h
//  peryi
//
//  Created by k on 16/4/26.
//  Copyright © 2016年 ZK. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZKHomeList : NSObject

//当前跟新集数
@property (nonatomic, strong) NSString *current;

//动漫详情页面
@property (nonatomic, strong) NSString *href;

//动漫图片地址
@property (nonatomic, strong) NSString *src;

//动漫名称
@property (nonatomic, strong) NSString *title;


@end
