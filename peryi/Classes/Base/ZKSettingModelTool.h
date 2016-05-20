//
//  ZKZKSettingModelTool.h
//  peryi
//
//  Created by k on 16/5/19.
//  Copyright © 2016年 ZK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZKSettingModel.h"
@class ZKSettingModel;

@interface ZKSettingModelTool : NSObject

+ (void)saveSettingWithModel:(ZKSettingModel *)model;
//读取数据
+ (ZKSettingModel *)getSettingWithModel;

@end
