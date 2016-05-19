//
//  ZKDownloadCompleteCell.h
//  peryi
//
//  Created by k on 16/5/19.
//  Copyright © 2016年 ZK. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ZFPlayer/ZFPlayer.h>

@interface ZKDownloadCompleteCell : UITableViewCell


+(instancetype)cellWithTableView:(UITableView *)tableView;


@property (weak, nonatomic) IBOutlet UILabel *fileNameLabel;

@property (weak, nonatomic) IBOutlet UILabel *sizeLabel;

@property (nonatomic, strong) ZFSessionModel *sessionModel;

@end
