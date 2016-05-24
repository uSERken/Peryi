//
//  ZKSearchDisplayController.m
//  peryi
//
//  Created by k on 16/5/9.
//  Copyright © 2016年 ZK. All rights reserved.
//

#import "ZKSearchDisplayController.h"
#import "ZKDataTools.h"
#import <MJExtension/MJExtension.h>
#import "ZKSearchModel.h"

@interface ZKSearchDisplayController()<UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate>

@property (nonatomic, strong) UIView *contentView;

@property (nonatomic, strong) UITableView *tableView;

- (void)initSearchHistoryView;

@property (nonatomic, assign) NSInteger count;


@property (nonatomic, strong) NSMutableArray *histroryArr;

@property (nonatomic, strong) ZKDataTools *dataTools;

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

        __weak typeof(self) weakSelf = self;
        self.searchBar.delegate = weakSelf;
        
        NSArray *subViews = self.searchContentsController.view.subviews;
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0f) {
            for (UIView *view in subViews) {
                if ([view isKindOfClass:NSClassFromString(@"UISearchDisplayControllerContainerView")]) {
                    NSArray *sub = view.subviews;
                    ((UIView*)sub[2]).hidden = NO;
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
            tableView.tableFooterView =[[UIView alloc] initWithFrame:CGRectZero];
            tableView.delegate = self;
            tableView.dataSource = self;
            tableView;
        });
        [self.parentVC.view addSubview:_tableView];
    }
    _dataTools = [ZKDataTools sharedZKDataTools];
    _histroryArr = [ZKSearchModel mj_objectArrayWithKeyValuesArray:[_dataTools getSearchHistory]];
    [self.tableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
         return self.histroryArr.count;
    }else{
         return 1;
    }
   
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *ID = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
    }
    if (indexPath.section == 0) {
        ZKSearchModel *searchModel = _histroryArr[indexPath.row];
        cell.textLabel.text = searchModel.title;
    }else{
        cell.textLabel.text = @"清楚历史记录";
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
    }
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    ZKSearchModel *searchModel = _histroryArr[indexPath.row];
    if (indexPath.section == 0) {
        if (_actionBlock) {
            _actionBlock(searchModel.title);
        }
    }else{
        _histroryArr = nil;
        [_dataTools removeSearchHistoryWithStr:nil];
        [_tableView reloadData];
    }
}

//
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
     ZKSearchModel *searchModel = _histroryArr[indexPath.row];
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [_histroryArr removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [_dataTools removeSearchHistoryWithStr:searchModel.title];
    }
}

/*
- (void)deleteCell:(UIButton *)button{
    NSArray *visiblecells = [self.tableView visibleCells];
    for(UITableViewCell *cell in visiblecells){
        if(cell.tag == button.tag){
            NSLog(@"cellTAG：%ld",cell.tag);
            NSLog(@"btnTAG：%ld",button.tag);
            [_histroryArr removeObjectAtIndex:[cell tag]];
            NSLog(@"%@",cell.textLabel.text);
//            [_dataTools removeSearchHistoryWithStr:cell.textLabel.text];
//            [self.tableView reloadData];
            break;
        }
    }
}
*/

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
            [_dataTools saveSearchHistortWithStr:searchBar.text];
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
