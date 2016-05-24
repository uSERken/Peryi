//
//  ZKAboutView.m
//  peryi
//
//  Created by k on 16/5/24.
//  Copyright © 2016年 ZK. All rights reserved.
//

#import "ZKAboutView.h"


@implementation ZKAboutView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
      self  = [[NSBundle mainBundle] loadNibNamed:@"ZKAboutView" owner:nil options:nil][0];
        self.frame = frame;
    }
    return self;
}

@end
