//
//  ZKZKSettingModelTool.m
//  peryi
//
//  Created by k on 16/5/19.
//  Copyright © 2016年 ZK. All rights reserved.
//

#import "ZKSettingModelTool.h"
#import "NSFileManager+ZKCache.h"


@implementation ZKSettingModelTool
static  ZKSettingModel *_settingModel;

+ (void)saveSettingWithModel:(ZKSettingModel *)model{
    
      [NSKeyedArchiver archiveRootObject:model toFile:ZKSettingModelPath];
}
//读取数据
+ (ZKSettingModel *)getSettingWithModel{
    if (_settingModel == nil) {
        _settingModel = [NSKeyedUnarchiver unarchiveObjectWithFile:ZKSettingModelPath];
    }
    return _settingModel;
}


@end
