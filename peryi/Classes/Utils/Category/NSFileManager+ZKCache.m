//
//  NSFileManager+ZKCache.m
//  peryi
//
//  Created by k on 16/5/17.
//  Copyright © 2016年 ZK. All rights reserved.
//

#import "NSFileManager+ZKCache.h"
#import <SDImageCache.h>

#define cachePath  [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingString:@"/default"]

@implementation NSFileManager (ZKCache)

/**
 *  计算单个文件大小
 */
+(float)fileSizeAtPath:(NSString *)path{
    NSFileManager *fileManager=[NSFileManager defaultManager];
    if([fileManager fileExistsAtPath:path]){
        long long size=[fileManager attributesOfItemAtPath:path error:nil].fileSize;
        return size/1024.0/1024.0;
    }
    return 0;
}

/**
 *  计算目录大小
 */
+(float)folderSizeAtPath:(NSString *)path{
    NSFileManager *fileManager=[NSFileManager defaultManager];
    float folderSize = 0;
    if ([fileManager fileExistsAtPath:path]) {
        NSArray *childerFiles=[fileManager subpathsAtPath:path];
        for (NSString *fileName in childerFiles) {
            NSString *absolutePath=[path stringByAppendingPathComponent:fileName];
            folderSize +=[self fileSizeAtPath:absolutePath];
        }
        //SDWebImage框架自身计算缓存的实现
//        folderSize+=[[SDImageCache sharedImageCache] getSize]/1024.0/1024.0;
        return folderSize;
    }
    return 0;
}

/**
 *  清楚缓存文件
 */
+(void)clearCache:(NSString *)path{
    NSFileManager *fileManager=[NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:path]) {
        NSArray *childerFiles=[fileManager subpathsAtPath:path];
        for (NSString *fileName in childerFiles) {
            //如有需要，加入条件，过滤掉不想删除的文件
            NSString *absolutePath=[path stringByAppendingPathComponent:fileName];
            [fileManager removeItemAtPath:absolutePath error:nil];
        }
    }
//    [[SDImageCache sharedImageCache] cleanDisk];
}

/**
 *  删除图片
 */
+(void)clearPicture{
    [self clearCache:cachePath];
}

/**
 *  获取图片目录大小
 */
+(float)getPictureCacheSize{
    return [self folderSizeAtPath:cachePath];
}

@end
