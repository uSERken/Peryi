//
//  ZKAboutVC.m
//  peryi
//
//  Created by k on 16/5/12.
//  Copyright © 2016年 ZK. All rights reserved.
//

#import "ZKAboutVC.h"
#import "ZKAboutView.h"
@interface ZKAboutVC ()

@property (nonatomic, strong) UIView *aboutView;

@end

@implementation ZKAboutVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    // Do any additional setup after loading the view.
    self.title = @"关于Peryi";
    
    ZKAboutView *aboutView = [[ZKAboutView alloc] initWithFrame:self.view.frame];
    [self.view addSubview:aboutView];
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
