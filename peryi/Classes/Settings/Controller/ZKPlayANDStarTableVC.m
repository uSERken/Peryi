//
//  ZKPlayANDStarTableVC.m
//  peryi
//
//  Created by k on 16/5/12.
//  Copyright © 2016年 ZK. All rights reserved.
//

#import "ZKPlayANDStarTableVC.h"
#import "ZKDataTools.h"
#import <MJExtension/MJExtension.h>
#import "ZKHomeList.h"
#import "ZKHistoryANDStartCell.h"
#import "ZKVideoController.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface ZKPlayANDStarTableVC ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) NSMutableArray *historyAndStartArr;

@property (nonatomic, strong)  ZKDataTools *dataTools;

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, assign) ZKPlayANDStarttType thisType;


@end

@implementation ZKPlayANDStarTableVC

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (id)initControllerWithType:(ZKPlayANDStarttType)type{
    self = [super init];
    [self setUpView];
    _dataTools = [ZKDataTools sharedZKDataTools];
    if (type == ZKPlayANDStartHistoryType ) {
        self.title  =  @"播放历史";
     _historyAndStartArr = [ZKHomeList  mj_objectArrayWithKeyValuesArray:[_dataTools getHistoryOrStartListArrWithType:getHistory]];
        _thisType = type;
        [self.tableView reloadData];
    }else{
        self.title  =  @"收藏列表";
        _historyAndStartArr = [ZKHomeList  mj_objectArrayWithKeyValuesArray:[_dataTools getHistoryOrStartListArrWithType:getStart]];
        _thisType = type;
        [self.tableView reloadData];
    }
    return self;
}

- (void)setUpView{
    _tableView = ({
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, screenW, self.view.height - 48) style:UITableViewStylePlain];
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        tableView.tableFooterView =[[UIView alloc] initWithFrame:CGRectZero];
        tableView;
        });
    [self.view addSubview:_tableView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _historyAndStartArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ZKHistoryANDStartCell *cell = [ZKHistoryANDStartCell cellWithTableView:tableView];
    ZKHomeList *model = self.historyAndStartArr[indexPath.row];
    [cell.imgView sd_setImageWithURL:[NSURL URLWithString:model.src] placeholderImage:[UIImage imageNamed:@"Management_Mask"]];
    cell.titleLabel.text = model.title;
    cell.currentLabel.text = model.current;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    ZKHomeList *model = self.historyAndStartArr[indexPath.row];
    ZKVideoController *vc = [[ZKVideoController alloc] initWithAddress:model.href];
    [self.navigationController pushViewController:vc animated:YES];
}

//header高
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 3;
}

//table分割线
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 3)];
    headerView.backgroundColor = [UIColor whiteColor];
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 90;
}



/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
     ZKHomeList *homeList = self.historyAndStartArr[indexPath.row];
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [_historyAndStartArr removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        if (_thisType == ZKPlayANDStartHistoryType) {
             [_dataTools deleteOneHistoryOrStartWithTitle:homeList.title withType:getHistory];
        }else{
             [_dataTools deleteOneHistoryOrStartWithTitle:homeList.title withType:getStart];
        }
    }
}


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here, for example:
    // Create the next view controller.
    <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:<#@"Nib name"#> bundle:nil];
    
    // Pass the selected object to the new view controller.
    
    // Push the view controller.
    [self.navigationController pushViewController:detailViewController animated:YES];
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
