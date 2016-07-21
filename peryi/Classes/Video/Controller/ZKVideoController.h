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

-(id) initWithAddress:(NSString *)addresUrlStr;

@property (nonatomic, strong) NSString *localHtml;

//为 nil 时无网络，NO 时是 wifi，YES 时是4G 网络
@property (nonatomic,assign)BOOL is4G;

@end
