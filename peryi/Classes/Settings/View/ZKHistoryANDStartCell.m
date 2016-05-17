//
//  ZKHistoryANDStartCell.m
//  peryi
//
//  Created by k on 16/5/13.
//  Copyright © 2016年 ZK. All rights reserved.
//

#import "ZKHistoryANDStartCell.h"

@interface ZKHistoryANDStartCell()

@end

@implementation ZKHistoryANDStartCell


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    return self;
    
    
}

+(instancetype)cellWithTableView:(UITableView *)tableView{
    
    static NSString *ID = @"cell";
    
    id cell = [tableView dequeueReusableCellWithIdentifier:ID];
    
    if (cell == nil) {
        
        cell = [[NSBundle mainBundle] loadNibNamed:@"ZKHistoryANDStartCell" owner:nil options:nil][0];
    }
    return cell;
}

//自定义分割线
- (void)drawRect:(CGRect)rect{
    
    CGContextRef context = UIGraphicsGetCurrentContext(); CGContextSetFillColorWithColor(context, [UIColor clearColor].CGColor); CGContextFillRect(context, rect);
    //上分割线，
    CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor); CGContextStrokeRect(context, CGRectMake(0, -1, rect.size.width, 3));
    //下分割线
    CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor); CGContextStrokeRect(context, CGRectMake(0, rect.size.height, rect.size.width, 3));
    
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    _imgView.layer.cornerRadius = 10;
    _imgView.layer.masksToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
