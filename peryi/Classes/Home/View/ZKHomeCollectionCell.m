//
//  ZKHomeCollectionCell.m
//  peryi
//
//  Created by k on 16/4/28.
//  Copyright © 2016年 ZK. All rights reserved.
//

#import "ZKHomeCollectionCell.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface ZKHomeCollectionCell()

@property (nonatomic, strong) UIImageView *img;

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UILabel *currentLabel;

@end

@implementation ZKHomeCollectionCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    [self setUpAllView];
    }
    return self;
}

- (void)setImgUrl:(NSString *)imgUrl{
    _imgUrl = imgUrl;
    [_img sd_setImageWithURL:[NSURL URLWithString:_imgUrl] placeholderImage:[UIImage imageNamed:@"Management_Mask"]];
}

- (void)setTitle:(NSString *)title{
    _title = title;
    _titleLabel.text = _title;
  
}

- (void)setCurrent:(NSString *)current{
    _current = current;
    _currentLabel.text = [NSString stringWithFormat:@"更新至%@",_current];
    [_currentLabel sizeToFit];
}

-(void)setUpAllView{
    if (!_img) {
        _img = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height - 30)];
        
        [self addSubview:_img];
    }
    _img.layer.cornerRadius = 5.0f;
    
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_img.frame), (self.width/3 )*2, 30)];
        _titleLabel.font = [UIFont systemFontOfSize:12];
         _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.numberOfLines = 0;
   
        _titleLabel.textColor = [UIColor blackColor];
        [self addSubview:_titleLabel];
    }
    
    if (!_currentLabel) {
        _currentLabel = [[UILabel alloc] init];
        _currentLabel.font = [UIFont systemFontOfSize:11];
        _currentLabel.textAlignment = NSTextAlignmentCenter;
        [_currentLabel sizeToFit];
        [_currentLabel setOrigin:CGPointMake((self.width/3)*2, CGRectGetMaxY(_img.frame)+10)];
        _currentLabel.textColor = [UIColor blackColor];
        [self addSubview:_currentLabel];
        
    }
    
}


@end
