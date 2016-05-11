//
//  ZKSearchDisplayController.h
//  peryi
//
//  Created by k on 16/5/9.
//  Copyright © 2016年 ZK. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^ZKSearchActionBlock)(NSString *text);

@interface ZKSearchDisplayController : UISearchDisplayController {
    
}

@property (nonatomic, strong) UIViewController *parentVC;

@property (nonatomic, copy)  ZKSearchActionBlock actionBlock;


@end
