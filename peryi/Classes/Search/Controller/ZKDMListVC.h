//
//  ZKDMListVC.h
//  peryi
//
//  Created by k on 16/5/10.
//  Copyright © 2016年 ZK. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    ZKGetDataTypeUrl,
    ZKGetDataTypeText,
}ZKGetDataType;

@interface ZKDMListVC : UIViewController

@property (nonatomic, strong) NSDictionary *dmListDict;

@property (nonatomic, strong) NSString *navTitle;

@property (nonatomic, strong) NSString *pageStyle;

@property (nonatomic, assign)  ZKGetDataType getDataType;

@end
