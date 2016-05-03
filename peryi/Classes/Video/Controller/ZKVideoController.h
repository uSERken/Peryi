//
//  ZKVideoController.h
//  peryi
//
//  Created by k on 16/4/28.
//  Copyright © 2016年 ZK. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef NS_ENUM(NSInteger, requestType) {
    defaultWebData,
    urlData
};

@interface ZKVideoController : UIViewController

/**
 *  详情页面
 */
@property (nonatomic, strong) NSString *strUrl;

@end
