//
//  ZKPlayANDStarTableVC.h
//  peryi
//
//  Created by k on 16/5/12.
//  Copyright © 2016年 ZK. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    ZKPlayANDStartHistoryType,
    ZKPlayANDStartCollectionType
}ZKPlayANDStarttType;

@interface ZKPlayANDStarTableVC : UIViewController
- (id)initControllerWithType:(ZKPlayANDStarttType)type;
//网络状态
@property (nonatomic,assign) netWorkStatus netWorkStatus;

@end
