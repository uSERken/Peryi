//
//  ZKListModel.h
//  peryi
//
//  Created by k on 16/5/10.
//  Copyright © 2016年 ZK. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZKListModel : NSObject

/**
 *  动漫名称
 */
@property (nonatomic, strong) NSString *alt;

/**
 *  动漫地址
 */
@property (nonatomic, strong) NSString *href;

/**
 *  图片地址
 */
@property (nonatomic, strong) NSString *src;

/**
 *  动漫相关信息 包含：关注度 attention ，简介：synopsis 当前更新的集数：update
 */

@property (nonatomic, strong) NSDictionary *about;



@end
