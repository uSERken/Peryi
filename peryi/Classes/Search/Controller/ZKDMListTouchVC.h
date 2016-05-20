//
//  ZKDMListTouchVC.h
//  peryi
//
//  Created by k on 16/5/19.
//  Copyright © 2016年 ZK. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZKDMListTouchVC : UIViewController

- (instancetype)initWithUrlStr:(NSString *)urlStr bgColor:(UIColor *)bgc;

@property (nonatomic, strong) NSDictionary *detailList;

@end
