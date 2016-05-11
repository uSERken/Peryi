//
//  ZKLikeListView.h
//  peryi
//
//  Created by k on 16/5/6.
//  Copyright © 2016年 ZK. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void(^ZKLikeActionBlock)(NSString *href);

@interface ZKLikeListView : UIView

+(instancetype)view;

@property (nonatomic, strong) NSArray *likeArr;

@property (nonatomic, copy) ZKLikeActionBlock  btClick;

@end
