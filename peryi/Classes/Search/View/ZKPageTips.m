//
//  ZKPageTips.m
//  peryi
//
//  Created by k on 16/5/17.
//  Copyright © 2016年 ZK. All rights reserved.
//

#import "ZKPageTips.h"

@interface ZKPageTips()

@property (weak, nonatomic) IBOutlet UILabel *currentPage;


@property (weak, nonatomic) IBOutlet UILabel *lastPage;


@end

@implementation ZKPageTips


+(instancetype)initView{
    
    return [[NSBundle mainBundle] loadNibNamed:@"ZKPageTips" owner:nil options:nil][0];
}

- (void)awakeFromNib{
    
}

- (void)setCurrentPageStr:(NSString *)currentPageStr{
    _currentPageStr = currentPageStr;
    
    _currentPage.text = _currentPageStr;
}

- (void)setLastPageStr:(NSString *)lastPageStr{
    _lastPageStr = lastPageStr;
    
    _lastPage.text = _lastPageStr;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
