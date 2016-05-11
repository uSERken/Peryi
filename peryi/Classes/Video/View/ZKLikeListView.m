//
//  ZKLikeListView.m
//  peryi
//
//  Created by k on 16/5/6.
//  Copyright © 2016年 ZK. All rights reserved.
//

#import "ZKLikeListView.h"
#import "ZKLikeCollectionViewCell.h"
#import "ZKDetailYourLike.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface ZKLikeListView()<UICollectionViewDelegate,UICollectionViewDataSource>

@property (weak, nonatomic) IBOutlet UICollectionView *colView;
//@property (nonatomic, strong) UICollectionView *colView;

@end

@implementation ZKLikeListView

+(instancetype)view{
    return [[NSBundle mainBundle] loadNibNamed:@"ZKLikeListView" owner:nil options:nil].firstObject;
}


- (void)awakeFromNib{
    [super awakeFromNib];
    
    UICollectionViewFlowLayout *collectionViewFlow = [[UICollectionViewFlowLayout alloc] init];
    [collectionViewFlow setScrollDirection:UICollectionViewScrollDirectionVertical];
    _colView.collectionViewLayout = collectionViewFlow;
    _colView.delegate = self;
    _colView.dataSource = self;
    _colView.backgroundColor = [UIColor whiteColor];
    
    [_colView registerNib:[UINib nibWithNibName:@"ZKLikeCollectionViewCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:@"Cell"];
}


- (void)setColView:(UICollectionView *)colView{
    _colView = colView;
}

- (void)setLikeArr:(NSArray *)likeArr{
    _likeArr = likeArr;
    [_colView reloadData];
}



- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    return self.likeArr.count;
    
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    ZKLikeCollectionViewCell *cell =(ZKLikeCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    ZKDetailYourLike *likeModel = self.likeArr[indexPath.row];
    cell.titleLabel.text = likeModel.title;
    [cell.imageVeiw sd_setImageWithURL:[NSURL URLWithString:likeModel.src]];

    return cell;
}




- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    ZKDetailYourLike *likeModel = self.likeArr[indexPath.row];
    
    if (_btClick) {
        _btClick(likeModel.href);
    }
    
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(5, 5, 5, 5);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    CGFloat ViewW = (screenW - 20)/2;
    return CGSizeMake(ViewW, 260);
    
}



@end
