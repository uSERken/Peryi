//
//  ZKNavigationController.m
//  peryi
//
//  Created by k on 16/4/25.
//  Copyright © 2016年 ZK. All rights reserved.
//

#import "ZKNavigationController.h"
#import "UIBarButtonItem+Common.h"
@interface ZKNavigationController()

@end

@implementation ZKNavigationController


+ (void)initialize{
//    UIBarButtonItem *btnItem = [UIBarButtonItem appearance];
//    NSMutableDictionary *textDict = [NSMutableDictionary dictionary];
//    textDict[NSForegroundColorAttributeName] = [UIColor grayColor];
    
    UINavigationBar *barItem = [UINavigationBar appearance];
    NSMutableDictionary *textDict = [NSMutableDictionary dictionary];
        textDict[NSForegroundColorAttributeName] = [UIColor blackColor];
    [barItem setTitleTextAttributes:textDict];
    
}

- (void)viewDidLoad{
    [super viewDidLoad];
    self.navigationBar.barTintColor = RGB(237, 237, 238);
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated{
    [super pushViewController:viewController animated:animated];
    //判断是否是根控制器
    if (self.viewControllers.count > 1) {
        UIBarButtonItem *popPre = [UIBarButtonItem itemWithImage:[UIImage imageNamed:@"navigationbar_back"] highImage:[UIImage imageNamed:@"navigationbar_back_highlighted"] target:self action:@selector(popPre)];
        viewController.navigationItem.leftBarButtonItem = popPre;
    }
    
}

- (void)popPre
{
    // 回到上一个控制器
    [self popViewControllerAnimated:YES];
}

@end
