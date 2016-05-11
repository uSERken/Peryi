//
//  ZKCollectionTypeCell.m
//  peryi
//
//  Created by k on 16/5/9.
//  Copyright © 2016年 ZK. All rights reserved.
//

#import "ZKCollectionTypeCell.h"

@interface ZKCollectionTypeCell()

@property (nonatomic, strong) UILabel *titleLabel;

@end


@implementation ZKCollectionTypeCell


- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        
        _titleLabel  = [[UILabel alloc] initWithFrame:self.bounds];
        _titleLabel.font = [UIFont systemFontOfSize:14];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_titleLabel];
        
    }
    return self;
}

- (void)setTitle:(NSString *)title{
    _title = title;
    _titleLabel.text = _title;
}

@end
