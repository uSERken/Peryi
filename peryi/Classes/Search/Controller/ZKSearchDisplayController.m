//
//  ZKSearchDisplayController.m
//  peryi
//
//  Created by k on 16/5/9.
//  Copyright © 2016年 ZK. All rights reserved.
//

#import "ZKSearchDisplayController.h"

@interface ZKSearchDisplayController()<UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate>

@property (nonatomic, strong) UIView *contentView;

@property (nonatomic, strong) UITableView *tableView;

- (void)initSearchHistoryView;

@property (nonatomic, assign) NSInteger count;


@property (nonatomic, strong) NSArray *histroryArr;

@end


@implementation ZKSearchDisplayController



- (void)setActive:(BOOL)visible animated:(BOOL)animated{
    

    
    if (!visible) {
        [_tableView  removeFromSuperview];
        [_contentView removeFromSuperview];
        _tableView = nil;
        _contentView = nil;
       [super setActive:visible animated:animated];
    }else{
        [super setActive:visible animated:animated];
        _histroryArr = [NSArray arrayWithObjects:@"姐",@"妹",@"哥", nil];
        
        __weak typeof(self) weakSelf = self;
        self.searchBar.delegate = weakSelf;
        
        NSArray *subViews = self.searchContentsController.view.subviews;
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0f) {
            for (UIView *view in subViews) {
                if ([view isKindOfClass:NSClassFromString(@"UISearchDisplayControllerContainerView")]) {
                    NSArray *sub = view.subviews;
                    ((UIView*)sub[2]).hidden = YES;
                }
            }
        } else {
            [[subViews lastObject] removeFromSuperview];
        }//删除原有tableview
        _histroryArr = [NSMutableArray array];
        _count = 1;
        if(!_contentView) {
            _contentView = ({
                UIView *view = [[UIView alloc] init];
                view.frame = CGRectMake(0.0f, 64, screenW, screenH - 40.0f);
                view.backgroundColor = [UIColor blackColor];
                view.alpha = 0.3;
                view.userInteractionEnabled = YES;
                UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didClickedContentView:)];
                [view addGestureRecognizer:tapGestureRecognizer];
                view;
            });
            [self.parentVC.view addSubview:_contentView];
        }
        
    }
}



- (void)initSearchHistoryView{
    if (!_tableView) {
        _tableView = ({
         UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, 64.0f, screenW, screenH - 40.0f) style:UITableViewStylePlain];
            tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
            tableView.delegate = self;
            tableView.dataSource = self;
            tableView;
        });
        [self.parentVC.view addSubview:_tableView];
    }
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        NSLog(@"%ld",_histroryArr.count);
         return self.histroryArr.count;
    }else{
         return 1;
    }
   
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *ID = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
    }
    if (indexPath.section == 0) {
        cell.textLabel.text = _histroryArr[indexPath.row];
    }else{
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        cell.textLabel.text = @"清楚历史记录";
    }
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    if (indexPath.section == 0) {
        if (_actionBlock) {
            _actionBlock(_histroryArr[indexPath.row]);
        }
    }else{
        _histroryArr = nil;
        [_tableView reloadData];
    }
}

- (void)didClickedContentView:(UIGestureRecognizer *)sender{
    self.active = NO;
}

#pragma mark - searchBar delegate
//不知为何执行两次
-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    if (_count != 1) {
        [self.searchBar resignFirstResponder];
        
        [_histroryArr arrayByAddingObject:searchBar.text];
        if (_actionBlock) {
            _actionBlock(searchBar.text);
        }
        
        _count = 1;
    }
    ++_count;
}




-(BOOL)searchBar:(UISearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    
    [self initSearchHistoryView];
      
    return YES;
}



@end
