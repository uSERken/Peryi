//
//  ZKMainController.m
//  peryi
//
//  Created by k on 16/4/25.
//  Copyright © 2016年 ZK. All rights reserved.
//

#import "ZKMainController.h"
#import "ZKNavigationController.h"
#import "ZKHomeController.h"
#import "ZKSearchController.h"
#import "ZKNewController.h"
#import "ZKSettingsController.h"
#import "ZKVideoController.h"
#import "RDVTabBarItem.h"
#import "MBProgressHUD+Extend.h"
#import <ZFPlayer/ZFPlayer.h>

@interface ZKMainController ()

@end

@implementation ZKMainController

- (void)viewDidLoad{
    [super viewDidLoad];
    [self setupViewControllers];
    
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        if (status == AFNetworkReachabilityStatusNotReachable || status == AFNetworkReachabilityStatusUnknown) {
            [MBProgressHUD showError:@"您的网络已断开"];
            [[NSNotificationCenter defaultCenter] postNotificationName:isNotNet object:nil];
        }else if (status == AFNetworkReachabilityStatusReachableViaWWAN){
            [[NSNotificationCenter defaultCenter] postNotificationName:isWWAN object:nil];
        }else{
            [[NSNotificationCenter defaultCenter] postNotificationName:isNet object:nil];
        }
    }];
}

// 哪些页面支持自动转屏
- (BOOL)shouldAutorotate{
    
    UINavigationController *nav = self.viewControllers[self.selectedIndex];
    
    if ([nav.topViewController isKindOfClass:[ZKVideoController class]]) {
        // 调用ZFPlayerSingleton单例记录播放状态是否锁定屏幕方向
        return !ZFPlayerShared.isLockScreen;
    }
    return NO;
}
/**
 *  这是tabbarcontroller
 */
- (void)setupViewControllers{
    
    ZKHomeController *home = [[ZKHomeController alloc] init];
    home.view.backgroundColor = RGB(238, 238, 244);
    UINavigationController *nav_home = [[ZKNavigationController alloc] initWithRootViewController:home];
    
    ZKSearchController *search = [[ZKSearchController alloc] init];
    search.view.backgroundColor = RGB(238, 238, 244);
    UINavigationController *nav_search = [[ZKNavigationController alloc] initWithRootViewController:search];
    
    ZKSettingsController *settings = [[ZKSettingsController alloc] init];
    settings.view.backgroundColor = RGB(238, 238, 244);
    UINavigationController *nav_settings =[[ZKNavigationController alloc] initWithRootViewController:settings];
    
    [self setViewControllers:@[nav_home,nav_search,nav_settings]];
    
    [self setCustomizeTabBar];
    
     self.delegate = self;
    
}

/**
 *  设置tabbar button样式
 */
- (void)setCustomizeTabBar{
    UIImage *backgroundImage = [UIImage imageNamed:@"tabbar_background"];
    NSArray *tabBarItemImages = @[@"home",@"search",@"setting"];
    NSArray *tabBarItemTitles = @[@"首页",@"搜索",@"设置"];
    NSInteger index = 0;
    for (RDVTabBarItem *item in [[self tabBar] items]) {
        item.titlePositionAdjustment = UIOffsetMake(0, 3);
        [item setBackgroundSelectedImage:backgroundImage withUnselectedImage:backgroundImage];
        UIImage *selectedImage = [UIImage imageNamed:[NSString stringWithFormat:@"%@_selected",[tabBarItemImages objectAtIndex:index]]];
        
        UIImage *nomalImage = [UIImage imageNamed:[NSString stringWithFormat:@"%@_normal",[tabBarItemImages objectAtIndex:index]]];
        [item setFinishedSelectedImage:selectedImage withFinishedUnselectedImage:nomalImage];
        [item setTitle:[tabBarItemTitles objectAtIndex:index]];
        index++;
        
    }
    
}

- (BOOL)tabBarController:(RDVTabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController{
    
    if (tabBarController.selectedViewController != viewController) {
        return YES;
    }
    if (![viewController isKindOfClass:[UINavigationController class]]) {
        return YES;
    }
    UINavigationController *nav = (UINavigationController *)viewController;
    if (nav.topViewController != nav.viewControllers[0]) {
        return  YES;
    }
    
    
    return YES;
}


@end
