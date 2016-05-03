//
//  ZKDetailAbout.h
//  peryi
//
//  Created by k on 16/4/29.
//  Copyright © 2016年 ZK. All rights reserved.
//

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

@end
