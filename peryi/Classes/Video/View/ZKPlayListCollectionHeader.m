//
//  ZKZPlayListCollectionHeader.m
//  peryi
//
//  Created by k on 16/5/5.
//  Copyright © 2016年 ZK. All rights reserved.
//

#import "ZKPlayListCollectionHeader.h"

@interface ZKPlayListCollectionHeader()

@property (nonatomic, strong) UILabel *titleLabel;

@end


@implementation ZKPlayListCollectionHeader

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        _titleLabel = [[UILabel alloc ]initWithFrame:CGRectMake(8, 0, self.width, self.height)];
        _titleLabel.font = [UIFont systemFontOfSize:15];
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        [self addSubview:_titleLabel];
    }
    return self;
}

- (void)layoutSubviews{
    [_titleLabel setWidth:self.width];
}

- (void)setTitleStr:(NSString *)titleStr{
    _titleStr = titleStr;
    _titleLabel.text = _titleStr;
    [self layoutIfNeeded];
}




@end
