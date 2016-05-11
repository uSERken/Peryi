//
//  ZKSegmentedControl.m
//  peryi
//
//  Created by k on 16/5/4.
//  Copyright © 2016年 ZK. All rights reserved.
//

#import "ZKSegmentedControl.h"

@implementation ZKSegmentedControl

- (void)awakeFromNib {
    [super awakeFromNib];
    self.sectionTitles = @[@"播放列表",@"下载列表"];
    self.selectionStyle = HMSegmentedControlSelectionStyleBox;
    self.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationDown;
    self.selectionIndicatorHeight = 3.0;
    self.borderType = HMSegmentedControlBorderTypeBottom;
    self.borderColor = [UIColor lightGrayColor];
    self.borderWidth = 0.3;
    self.alpha = 0.9;
    self.titleTextAttributes = @{NSFontAttributeName: [UIFont systemFontOfSize:14.0]};
    self.selectedTitleTextAttributes = @{NSFontAttributeName: [UIFont boldSystemFontOfSize:17.0]};
}

@end
