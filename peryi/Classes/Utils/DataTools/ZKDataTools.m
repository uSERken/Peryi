//
//  ZKDataTools.m
//  peryi
//
//  Created by k on 16/5/13.
//  Copyright © 2016年 ZK. All rights reserved.
//

#import "ZKDataTools.h"
#import <FMDB/FMDB.h>

#import <MJExtension/MJExtension.h>

@interface ZKDataTools()

@end

@implementation ZKDataTools

static FMDatabase *_db;
SingletonM(ZKDataTools);

/**
 *  存储首页的数据
 */
- (void)saveHomeDMListWithArry:(NSArray *)arry{
    
    NSString *dispath = dbpaths;
    _db = [FMDatabase databaseWithPath:dispath];
    if ([_db open]) {
        //每次从网络存储前删除之前数据
        NSString *deleteSql = @"delete from home";
        [_db executeUpdate:deleteSql];
        
         NSString *sql = @"insert into home (current, href,src,title) values(?,?,?,?)";
         NSMutableArray *arr = [NSMutableArray array];
         arr = [ZKHomeList mj_objectArrayWithKeyValuesArray:arry];
         for (ZKHomeList *model in arr) {
              [_db executeUpdate:sql,model.current,model.href,model.src,model.title];
         }
    }
    [_db close];
}


/**
 *  获得动漫首页数据
 */
-(NSArray *)getHomeDMlist{
    NSMutableArray *arr = [NSMutableArray array];
    NSString *dispath = dbpaths;
    _db = [FMDatabase databaseWithPath:dispath];
    if ([_db open]) {
         NSString *selectSql = @"select * from home";
        FMResultSet *set = [_db executeQuery:selectSql];
        while ([set next]) {
             NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            for (int i = 0; i<set.columnCount; i++) {
                dict[[set columnNameForIndex:i]] = [set stringForColumnIndex:i];
            }
            [arr addObject:dict];
        }
     }
    [_db close];
    
    return  arr;
}

/**
 *  点击进播放页面即保存为播放记录
 *
 *  @param id 保存的模型
 */
- (void)saveHistroyOrStartWithModel:(id)model withType:(ZKSaveFromType)from{
   
    NSString *dbpath = dbpaths;
    _db = [FMDatabase databaseWithPath:dbpath];
    if ([_db open]) {
    NSString *sql = @"insert into history (title, src,current,href) values(?,?,?,?)";
    if (from == saveHome) {
        ZKHomeList *homeList = model;
        if ([self isRepateWithHistoryOrStartWithTitle:homeList.title withType:getHistory]) {
            [_db executeUpdate:sql,homeList.title,homeList.src,homeList.current,homeList.href];
        }
        
    }else if (from == saveList){
        ZKListModel *listModel = model;
        if ([self isRepateWithHistoryOrStartWithTitle:listModel.alt withType:getHistory]) {
        [_db executeUpdate:sql,listModel.alt,listModel.src,listModel.about[@"update"],listModel.href];
            }
        
    }else if(from == saveStart){
        NSString *startSql = @"insert into start (title, src,current,href) values(?,?,?,?)";
        ZKHomeList *homeList = model;
        if ([self isRepateWithHistoryOrStartWithTitle:homeList.title withType:getStart]) {
            [_db executeUpdate:startSql,homeList.title,homeList.src,homeList.current,homeList.href];
        }
    }
        
    }//数据库打开结束
    
    [_db close];
    
        
}

/**
 *  获取历史记录或收藏的字典数组
 *
 *  @param from 选择是历史或收藏
 */
- (NSArray *)getHistoryOrStartListArrWithType:(ZKGetFromType)from{
    NSMutableArray *arr = [NSMutableArray array];
    NSString *selectSql = nil;
    if (from == getHistory) {
        selectSql = @"select * from history";
    }else{
        selectSql = @"select * from start";
    }
    NSString *dispath = dbpaths;
    _db = [FMDatabase databaseWithPath:dispath];
    if ([_db open]) {
        FMResultSet *set = [_db executeQuery:selectSql];
        while ([set next]) {
              NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            for (int i = 0; i < set.columnCount; i++) {
                dict[[set columnNameForIndex:i]] = [set stringForColumnIndex:i];
            }
             [arr addObject:dict];
        }
    }
    [_db close];
    
    return arr;
}

/**
 *  删除历史纪录或收藏的某一条
 */
- (void)deleteOneHistoryOrStartWithTitle:(NSString *)title withType:(ZKGetFromType)from{
    
    NSString *sql = nil;
    if (from == getHistory) {
        sql = @"delete from history where title=?";
    }else{
        sql = @"delete from start where title=?";

    }
    NSString *dbpath = dbpaths;
    _db = [FMDatabase databaseWithPath:dbpath];
    //打开数据库
    if ([_db open]) {
        [_db executeUpdate:sql,title];
    }
    [_db close];

}

/**
 *  判断是否是收藏
 */
- (BOOL)isStartWithTitle:(NSString *)title{
    
    BOOL isStart;
    NSString *sql = @"select * from start where title=?";
    NSString *dbpath = dbpaths;
    _db = [FMDatabase databaseWithPath:dbpath];
    //打开数据库
    if ([_db open]) {
        FMResultSet *set = [_db executeQuery:sql,title];
        if ([set next]) {
                isStart = YES;
            }else{
                isStart = NO;
        }
    }
    [_db close];
    return isStart;
}

/**
 *  查询是否重复
 */
- (BOOL)isRepateWithHistoryOrStartWithTitle:(NSString *)title withType:(ZKGetFromType)from{
    BOOL isNeedSave = NO;
    NSString *sql = nil;
    if (from == getHistory) {
        sql =  @"select * from history where title=?";
            FMResultSet *set = [_db executeQuery:sql,title];
            if ([set next]) {
                isNeedSave = NO;
            }else{
                isNeedSave = YES;
            }
        }else if(from == getStart){
            sql =  @"select * from start where title=?";
            FMResultSet *set = [_db executeQuery:sql,title];
            if ([set next]) {
                    isNeedSave = NO;
            }else{
               isNeedSave = YES;
            }   
     }
    return isNeedSave;
}


/**
 *  插入搜索记录
 */
- (void)saveSearchHistortWithStr:(NSString *)str{
    NSString *dbpath = dbpaths;
    _db = [FMDatabase databaseWithPath:dbpath];
    if ([_db open]) {
        NSString *sql = @"insert into search (title,time) values(?,?)";
        [_db executeUpdate:sql,str,nil];
    }
    [_db close];
}

/**
 *  获取搜索记录
 */
- (NSArray *)getSearchHistory{
    NSString *dbpath = dbpaths;
    _db = [FMDatabase databaseWithPath:dbpath];
    NSMutableArray *arr = [NSMutableArray array];
    if ([_db open]) {

    NSString *selectSql =  @"select * from search";
    FMResultSet *set = [_db executeQuery:selectSql];
   
    while ([set next]) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        for (int i = 0; i<set.columnCount; i++) {
            dict[[set columnNameForIndex:i]] = [set stringForColumnIndex:i];
        }
        [arr addObject:dict];
    }
        
        }
    [_db close];
    return arr;
}

/**
 *  删除单条搜索记录
 *
 *  @param str 若为nil 时删除全部
 */
- (void)removeSearchHistoryWithStr:(NSString *)str{
    NSString *sql = nil;
    if (sql != nil) {
        sql = @"delete from search where title=?";
    }else{
        sql = @"delete from search ";
        
    }
    NSString *dbpath = dbpaths;
    _db = [FMDatabase databaseWithPath:dbpath];
    //打开数据库
    if ([_db open]) {
        [_db executeUpdate:sql,str];
    }
    [_db close];

}

@end
