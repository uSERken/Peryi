//
//  ZKDownloadCompleteCell.m
//  peryi
//
//  Created by k on 16/5/19.
//  Copyright © 2016年 ZK. All rights reserved.
//

#import "ZKDownloadCompleteCell.h"

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
    _fileNameLabel.text = sessionModel.fileName;
    _sizeLabel.text = sessionModel.totalSize;
}

@end
