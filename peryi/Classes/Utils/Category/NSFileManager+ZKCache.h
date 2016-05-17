//
//  NSFileManager+ZKCache.h
//  peryi
//
//  Created by k on 16/5/17.
//  Copyright © 2016年 ZK. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSFileManager (ZKCache)

/**
 * 根据文件路劲 计算单个文件大小
 */
+(float)fileSizeAtPath:(NSString *)path;

/**
 * 根据目录 计算目录大小
 */
+(float)folderSizeAtPath:(NSString *)path;


/**
 *  根据目录 清楚缓存文件
 */
+(void)clearCache:(NSString *)path;

/**
 *  删除图片
 */
+(void)clearPicture;

/**
 *  获取图片目录大小
 */
+(float)getPictureCacheSize;

@end
