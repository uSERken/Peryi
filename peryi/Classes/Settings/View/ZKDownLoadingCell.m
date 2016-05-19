//
//  ZKDownLoading.m
//  peryi
//
//  Created by k on 16/5/19.
//  Copyright © 2016年 ZK. All rights reserved.
//

#import "ZKDownLoadingCell.h"

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
    
}

- (void)addDownloadAnimation{
    if (self.downloadBtn && !self.hasDownloadAnimation) {
        CAKeyframeAnimation *keyframeAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
        
        NSValue *key1 = [NSValue valueWithCGPoint:CGPointMake(self.downloadBtn.centerX, self.downloadBtn.centerY)];
        
        NSValue *key2 = [NSValue valueWithCGPoint:CGPointMake(self.downloadBtn.centerX, self.downloadBtn.height+self.downloadBtn.y)];
        
        NSArray *varlues = @[key1,key2];
        
        keyframeAnimation.values = varlues;
        
        keyframeAnimation.duration = 1;
        keyframeAnimation.repeatCount = MAXFLOAT;
        
        [self.downloadBtn.layer addAnimation:keyframeAnimation forKey:@"downloadBtn"];
        [self.downloadBtn setTitle:@"↓" forState:UIControlStateNormal];
        
    }
    
}

- (void)removeDownloadAnimtion{
    _hasDownloadAnimation = NO;
    [self.downloadBtn.layer removeAnimationForKey:@"downloadBtn"];
    [self.downloadBtn setTitle:@"🕛" forState:UIControlStateNormal];
}

- (IBAction)clickDownloading:(id)sender {
    if (self.downloadBlock) {
        self.downloadBlock();
    }
}

- (void)setSessionModel:(ZFSessionModel *)sessionModel{
    _sessionModel = sessionModel;
    _fileNameLabel.text = sessionModel.fileName;
    
    NSUInteger receivedSize = ZFDownloadLength(sessionModel.url);
    NSString *writtenSize = [NSString stringWithFormat:@"%.2f %@",
                             [sessionModel calculateFileSizeInUnit:(unsigned long long)receivedSize],
                             [sessionModel calculateUnit:(unsigned long long)receivedSize]];
    CGFloat progress = 1.0 * receivedSize / sessionModel.totalLength;
    _progressLabel.text = [NSString stringWithFormat:@"%@/%@ (%.2f%%)",writtenSize,sessionModel.totalSize,progress*100];
    _progress.progress = progress;
    _speedLabel.text = @"已暂停";
    
    
}


@end
