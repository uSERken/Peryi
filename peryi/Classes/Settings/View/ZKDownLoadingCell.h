//
//  ZKDownLoading.h
//  peryi
//
//  Created by k on 16/5/19.
//  Copyright © 2016年 ZK. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ZFPlayer/ZFPlayer.h>

typedef void(^ZFDownloadBlock)(void);

@interface ZKDownLoadingCell : UITableViewCell


+(instancetype)cellWithTableView:(UITableView *)tableView;

@property (weak, nonatomic) IBOutlet UILabel *fileNameLabel;

@property (weak, nonatomic) IBOutlet UIProgressView *progress;

@property (weak, nonatomic) IBOutlet UILabel *progressLabel;

@property (weak, nonatomic) IBOutlet UILabel *speedLabel;

@property (weak, nonatomic) IBOutlet UIButton *downloadBtn;

@property (nonatomic, copy) ZFDownloadBlock downloadBlock;

@property (nonatomic, strong) ZFSessionModel *sessionModel;

- (void)addDownloadAnimation;
- (void)removeDownloadAnimtion;

@end
