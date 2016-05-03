//
//  ZKHttpTools.h
//  peryi
//
//  Created by k on 16/4/26.
//  Copyright © 2016年 ZK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Singelon.h"

@interface ZKHttpTools : NSObject

SingletonH(ZKHttpTools)

/**
 *  获取 m.preyi.com 主页数据
 */
-(NSArray *)getDMLIST;

/**
 *  根据对应的某部动漫网页获数据
 *
 *  @param url
 */
- (void)getDetailDMWithURL:(NSString *)url getDatasuccess:(void (^)(NSDictionary *listData))dict;


/**
 *  按标签搜索页面
 *
 *  @param url
 *
 *  @return
 */
- (NSDictionary *)searchWithUrl:(NSString *)url;

/**
 *  获取新番页面数据
 *
 *  @return
 */
-(NSDictionary *)getNewPageList;


/**
 *  动漫类型分类标签
 *
 *  @return 
 */
-(NSDictionary *)searchHomeList;

/**
 *  根据关键词查询
 *
 *  @param keyword 关键字
 *
 *  @return 
 */
- (NSDictionary *)serarchWithString:(NSString *)keyword;

@end