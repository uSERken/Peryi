//
//  ZKSettingModel.m
//  peryi
//
//  Created by k on 16/5/19.
//  Copyright © 2016年 ZK. All rights reserved.
//

#import "ZKSettingModel.h"



@interface ZKSettingModel()<NSCoding>

@end
@implementation ZKSettingModel


- (void)encodeWithCoder:(NSCoder *)aCoder //将属性进行编码
{
    [aCoder encodeObject:self.isOpenNetwork forKey:@"isOpenNetwork"];
}

- (id)initWithCoder:(NSCoder *)aDecoder //将属性进行解码
{
    self = [super init];
    if (self) {
        self.isOpenNetwork = [aDecoder decodeObjectForKey:@"isOpenNetwork"];
    }
    return self;
}


@end
