//
//  ZKPlayAndDownCell.m
//  peryi
//
//  Created by k on 16/5/4.
//  Copyright © 2016年 ZK. All rights reserved.
//

#import "ZKPlayAndDownCell.h"

@interface ZKPlayAndDownCell()

@property (nonatomic, strong) UILabel *titleLabel;

@end

@implementation ZKPlayAndDownCell


- (instancetype)initWithFrame:(CGRect)frame{
    if (self == [super initWithFrame:frame]) {
        [self setUpView];
    }
    return self;
}

- (void)setUpView{
    
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.font = [UIFont systemFontOfSize:13];
    [self addSubview:self.titleLabel];
}



- (void)setTitle:(NSString *)title{
    _title = title;
    _titleLabel.text = _title;
    [self layoutIfNeeded];
}

- (void)layoutSubviews{
    [self.titleLabel setFrame:CGRectMake(0, 0, self.width, self.height)];
}

@end