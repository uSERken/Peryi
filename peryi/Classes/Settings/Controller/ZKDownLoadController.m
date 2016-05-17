//
//  ZKDownLoadController.m
//  peryi
//
//  Created by k on 16/5/12.
//  Copyright © 2016年 ZK. All rights reserved.
//

#import "ZKDownLoadController.h"
#import <ZFPlayer/ZFDownloadManager.h>
@interface ZKDownLoadController ()

@property (nonatomic, strong) ZFDownloadManager *donwMgr;

@end

@implementation ZKDownLoadController

- (void)viewDidLoad {
     [super viewDidLoad];
     self.title = @"离线缓存";
     self.view.backgroundColor = [UIColor whiteColor];

}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
