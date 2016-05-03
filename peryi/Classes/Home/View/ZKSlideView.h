//
//  ZKSlideView.h
//  peryi
//
//  Created by k on 16/4/26.
//  Copyright © 2016年 ZK. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZKHomeList.h"

@interface ZKSlideView : UIView

@property (nonatomic, strong) NSArray *listArr;

@property (nonatomic , copy) void (^tapActionBlock)(ZKHomeList *hoemList);

@property (nonatomic, assign) CGRect slideRect;

- (void)reloadData;

@end
