//
//  ZKInfoView.m
//  peryi
//
//  Created by k on 16/4/29.
//  Copyright © 2016年 ZK. All rights reserved.
//

#import "ZKInfoView.h"
#import "ZKDetailAbout.h"
#import "Masonry.h"

@interface ZKInfoView()

@property (weak, nonatomic) IBOutlet UILabel *title;

@property (weak, nonatomic) IBOutlet UILabel *source;

@property (weak, nonatomic) IBOutlet UIButton *start;




@end

@implementation ZKInfoView

- (instancetype)init{
    self = [super init];
    return self;
}


- (void)setInfoModel:(ZKDetailAbout *)infoModel{
    _infoModel = infoModel;
    _title.text = _infoModel.alt;
    _source.text = _infoModel.souce;
    _synopsisLabel.text = _synopsis;
    
    CGFloat maxY = [_synopsisLabel systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
    [self setHeight:maxY + 80];
    
}

- (void)awakeFromNib{
    [super awakeFromNib];
}

+ (instancetype)view{
    return [[NSBundle mainBundle] loadNibNamed:@"ZKInfoView" owner:nil options:nil].firstObject;
}




@end
