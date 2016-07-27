//
//  ZKDownLoading.m
//  peryi
//
//  Created by k on 16/5/19.
//  Copyright © 2016年 ZK. All rights reserved.
//

#import "ZKDownLoadingCell.h"
#import <MJExtension/MJExtension.h>
#import "ZKDetailAbout.h"
#import "ZFDownloadManager.h"

@interface ZKDownLoadingCell()

@property (nonatomic, assign) BOOL hasDownloadAnimation;

@end

@implementation ZKDownLoadingCell

+(instancetype)cellWithTableView:(UITableView *)tableView{
    
    static NSString *ID = @"downloadingCell";
    
    id cell = [tableView dequeueReusableCellWithIdentifier:ID];
    
    if (cell == nil) {
        
        cell = [[NSBundle mainBundle] loadNibNamed:@"ZKDownLoadingCell" owner:nil options:nil][0];
    }
    return cell;
}

- (void)awakeFromNib{
    
    self.downloadBtn.clipsToBounds = YES;
    [self.downloadBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [self.downloadBtn setTitle:@"🕘" forState:UIControlStateNormal];
    [self.downloadBtn setTitle:@"↓" forState:UIControlStateSelected];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}


- (IBAction)clickDownloading:(id)sender {
    if (self.downloadBlock) {
        self.downloadBlock();
    }
}

- (void)setSessionModel:(ZFSessionModel *)sessionModel{
    _sessionModel = sessionModel;
    
    NSUInteger receivedSize = ZFDownloadLength(sessionModel.url);
    NSString *writtenSize = [NSString stringWithFormat:@"%.2f %@",
                             [sessionModel calculateFileSizeInUnit:(unsigned long long)receivedSize],
                             [sessionModel calculateUnit:(unsigned long long)receivedSize]];
    CGFloat progress = 1.0 * receivedSize / sessionModel.totalLength;
    _progressLabel.text = [NSString stringWithFormat:@"%@/%@ (%.2f%%)",writtenSize,sessionModel.totalSize,progress*100];
    _progress.progress = progress;
    _speedLabel.text = @"已暂停";
    
    ZKDetailAbout *model = [ZKDetailAbout mj_objectWithKeyValues:sessionModel.aboutDict];
    _fileNameLabel.text = [NSString stringWithFormat:@"%@ - %@",model.title,model.currentplaytitle];
}


@end
