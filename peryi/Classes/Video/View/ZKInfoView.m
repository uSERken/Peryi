//
//  ZKInfoView.m
//  peryi
//
//  Created by k on 16/4/29.
//  Copyright © 2016年 ZK. All rights reserved.
//

#import "ZKInfoView.h"

@interface ZKInfoView()

@property (weak, nonatomic) IBOutlet UILabel *title;

@property (weak, nonatomic) IBOutlet UILabel *source;

@property (weak, nonatomic) IBOutlet UIButton *start;

@property (weak, nonatomic) IBOutlet UILabel *synopsis;

@end

@implementation ZKInfoView

- (instancetype)init{
    self = [super init];
    
    
    return self;
}

- (void)awakeFromNib{
    [super awakeFromNib];
}

+ (instancetype)view{
    return [[NSBundle mainBundle] loadNibNamed:@"ZKInfoView" owner:nil options:nil].firstObject;
}




@end
