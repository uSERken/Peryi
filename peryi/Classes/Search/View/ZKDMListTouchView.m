//
//  ZKDMListTouchView.m
//  peryi
//
//  Created by k on 16/5/20.
//  Copyright © 2016年 ZK. All rights reserved.
//

#import "ZKDMListTouchView.h"

@implementation ZKDMListTouchView


+(instancetype)initViewWithFrame:(CGRect)frame{
    
    ZKDMListTouchView *view = [[NSBundle mainBundle] loadNibNamed:@"ZKDMListTouchView" owner:nil options:nil][0];
    [view setFrame:frame];
    
    return view;
}



- (void)awakeFromNib{
    _imgView.layer.masksToBounds = YES;
    _imgView.layer.cornerRadius = 10.0;
    
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
