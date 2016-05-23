//
//  ZKHistoryANDStartCell.h
//  peryi
//
//  Created by k on 16/5/13.
//  Copyright © 2016年 ZK. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZKHistoryANDStartCell : UITableViewCell

+(instancetype)cellWithTableView:(UITableView *)tableView;

@property (weak, nonatomic) IBOutlet UIImageView *imgView;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (weak, nonatomic) IBOutlet UILabel *currentLabel;

@property (weak, nonatomic) IBOutlet UILabel *playLabel;


@end
