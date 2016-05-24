//
//  ZKDownloadCompleteCell.m
//  peryi
//
//  Created by k on 16/5/19.
//  Copyright © 2016年 ZK. All rights reserved.
//

#import "ZKDownloadCompleteCell.h"
#import <MJExtension/MJExtension.h>
#import "ZKDetailAbout.h"
@implementation ZKDownloadCompleteCell


+(instancetype)cellWithTableView:(UITableView *)tableView{
    
    static NSString *ID = @"completeCell";
    
    id cell = [tableView dequeueReusableCellWithIdentifier:ID];
    
    if (cell == nil) {
        
        cell = [[NSBundle mainBundle] loadNibNamed:@"ZKDownloadCompleteCell" owner:nil options:nil][0];
    }
    return cell;
}

- (void)setSessionModel:(ZFSessionModel *)sessionModel{
    _sessionModel = sessionModel;
    ZKDetailAbout *model = [ZKDetailAbout mj_objectWithKeyValues:sessionModel.aboutDict];
    _fileNameLabel.text = [NSString stringWithFormat:@"%@ - %@",model.title,model.currentplaytitle];
    _sizeLabel.text = sessionModel.totalSize;
}

@end
