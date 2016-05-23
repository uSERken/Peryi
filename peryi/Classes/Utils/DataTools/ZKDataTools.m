//
//  ZKDataTools.m
//  peryi
//
//  Created by k on 16/5/13.
//  Copyright © 2016年 ZK. All rights reserved.
//

#import "ZKDataTools.h"
#import <FMDB/FMDB.h>
#import "ZKDetailAbout.h"
#import <MJExtension/MJExtension.h>

@interface ZKDataTools()

@end

@implementation ZKDataTools

static FMDatabase *_db;
SingletonM(ZKDataTools);


#pragma mark - 存获取首页数据
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

#pragma mark - 存获播放历史，收藏历史记录
/**
 *  点击进播放页面即保存为播放记录
 *
 *  @param id 保存的模型
 */
- (void)saveHistroyOrStartWithModel:(ZKDetailAbout *)model withType:(ZKSaveFromType)from{
   
    NSString *dbpath = dbpaths;
    _db = [FMDatabase databaseWithPath:dbpath];
    if ([_db open]) {
     // 历史
    if(from == saveList){
        [self saveHistoryAndStartWithModel:model withType:saveList];
    }else{ //收藏
        //将默认存储的历史数据保存为收藏的数据
        NSString *sql = @"select * from history where title=?";
        FMResultSet *set = [_db executeQuery:sql,model.alt];
        if ([set next]) {
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            for (int i = 0; i < set.columnCount; i++) {
                dict[[set columnNameForIndex:i]] = [set stringForColumnIndex:i];
            }
            
            ZKDetailAbout *saveModel = [ZKDetailAbout mj_objectWithKeyValues:dict];
            //收藏时将历史里的数据保存至收藏
            [self saveHistoryAndStartWithModel:saveModel withType:saveStart];
          }
        }
    }
    //数据库打开结束
    [_db close];
}

- (void)saveHistoryAndStartWithModel:(ZKDetailAbout*)model withType:(ZKSaveFromType)fromType{
    NSString *savesSql =  nil;
    if (fromType == saveList) {
        if ([self isRepateWithHistoryOrStartWithTitle:model.alt withType:getHistory]) {
            savesSql = @"insert into history (title, src,current,href,currentplaytitle,currentplayhref) values(?,?,?,?,?,?)";
            [_db executeUpdate:savesSql,model.alt,model.src,model.about[@"update"],model.href,model.currentplaytitle,model.currentplayhref];
        }
    }else{
        if ([self isRepateWithHistoryOrStartWithTitle:model.title withType:getStart]) {
            savesSql = @"insert into start (title, src,current,href,currentplaytitle,currentplayhref) values(?,?,?,?,?,?)";
            [_db executeUpdate:savesSql,model.title,model.src,model.current,model.href,model.currentplaytitle,model.currentplayhref];
        }
    }
    
}

//根据名字保存播放的集数
- (void)saveCurrentPlayWithTitle:(NSString*)title withplayTitle:(NSString *)playTitle withHref:(NSString *)href{
    NSString *dbpath = dbpaths;
    _db = [FMDatabase databaseWithPath:dbpath];
    if ([_db open]) {
        //更新历史
        NSString *hissSql = @"update history set currentplaytitle=?, currentplayhref=? where title=?";
        [_db executeUpdate:hissSql,playTitle,href,title];
        //先查询在收藏是否有再更新
        NSString *selStartSql = @"select * from start where title=?";
        FMResultSet *startSet = [_db executeQuery:selStartSql,title];
        if ([startSet next]) {
            NSString *sql = @"update start set currentplaytitle=?, currentplayhref=? where title=?";
            [_db executeUpdate:sql,playTitle,href,title];
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

/**
 *  存储搜索类型
 *
 */
- (void)saveSearchTypeWithArr:(NSArray *)array{
    NSString *dbpath = dbpaths;
    _db = [FMDatabase databaseWithPath:dbpath];
    if ([_db open]) {
        //每次从网络存储前删除之前数据
        NSString *deleteSql = @"delete from searchtype";
        [_db executeUpdate:deleteSql];
         NSString *sql = @"insert into searchtype (type) values(?)";
        for (NSArray *listArr in array) {
            NSData *data = [NSKeyedArchiver archivedDataWithRootObject:listArr];
            [_db executeUpdate:sql,data,nil];
        }  
    }
    [_db close];
}

/**
 *  获取搜索类型的数组
 *
 */
- (NSArray *)getSearchType{
    NSString *dbpath = dbpaths;
    _db = [FMDatabase databaseWithPath:dbpath];
    NSMutableArray *arr = [NSMutableArray array];
    if ([_db open]) {
        
        NSString *selectSql = @"select * from searchtype";
        FMResultSet *set = [_db executeQuery:selectSql];
        while ([set next]) {
            NSArray *arrDict = [NSKeyedUnarchiver unarchiveObjectWithData:[set dataForColumn:@"type"]];
            [arr addObject:arrDict];
        }
    }
    [_db close];
    return arr;

}


@end
