//
//  ZKDataTools.h
//  peryi
//
//  Created by k on 16/5/13.
//  Copyright © 2016年 ZK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Singelon.h"
#import "ZKHomeList.h"
#import "ZKListModel.h"

typedef enum : NSUInteger {
    saveList,
    saveStart,
} ZKSaveFromType;


typedef enum : NSUInteger {
    getHistory,
    getStart,
} ZKGetFromType;


@interface ZKDataTools : NSObject

SingletonH(ZKDataTools);

/**
 *  存储首页的数据
 */
- (void)saveHomeDMListWithArry:(NSArray *)arry;

/**
 *  获得动漫首页数据
 */
-(NSArray *)getHomeDMlist;

/**
 *  点击进播放页面即保存为播放记录
 *
 *  @param id 保存的模型
 */
- (void)saveHistroyOrStartWithModel:(id)model withType:(ZKSaveFromType)from;

/**
 *  根据名字保存播放的地址和集数
 *
 */
- (void)saveCurrentPlayWithTitle:(NSString*)title withplayTitle:(NSString *)playTitle withHref:(NSString *)href;
/**
 *  获取历史记录或收藏的字典数组
 *
 *  @param from 选择是历史或收藏
 */
- (NSArray*)getHistoryOrStartListArrWithType:(ZKGetFromType)from;


/**
 *  删除历史纪录或收藏的某一条
 */
- (void)deleteOneHistoryOrStartWithTitle:(NSString *)title withType:(ZKGetFromType)from;

/**
 *  判断是否是收藏
 */
- (BOOL)isStartWithTitle:(NSString *)title;

/**
 *  插入搜索记录
 */
- (void)saveSearchHistortWithStr:(NSString *)str;
/**
 *  获取搜索记录
 */
- (NSArray *)getSearchHistory;

/**
 *  删除单条搜索记录
 *
 *  @param str 若为nil 时删除全部
 */
- (void)removeSearchHistoryWithStr:(NSString *)str;

/**
 *  存储搜索类型
 *
 */
- (void)saveSearchTypeWithArr:(NSArray *)array;

/**
 *  获取搜索类型的数组
 *
 */
- (NSArray *)getSearchType;

@end
