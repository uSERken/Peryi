//
//  ZKDetailAbout.h
//  peryi
//
//  Created by k on 16/4/29.
//  Copyright © 2016年 ZK. All rights reserved.
//  用于detail数组中的about

#import <Foundation/Foundation.h>

@interface ZKDetailAbout : NSObject

/**
 *  标题
 */
@property (nonatomic, strong) NSString *alt;

/**
 *  评分
 */
@property (nonatomic, strong) NSString *souce;

/**
 *  图片地址
 */
@property (nonatomic, strong) NSString *src;

/**
 *  其他信息
 */

@property (nonatomic, strong) NSDictionary *about;

//处理从数据库过来的信息///
@property (nonatomic, strong) NSString *title;
//动漫地址
@property (nonatomic, strong) NSString *href;
//当前播放的集数
@property (nonatomic, strong) NSString *currentplaytitle;
//播放集数的地址
@property (nonatomic, strong) NSString *currentplayhref;

@property (nonatomic, strong) NSString *current;

@end
