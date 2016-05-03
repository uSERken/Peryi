//
//  ZKSlideView.m
//  peryi
//
//  Created by k on 16/4/26.
//  Copyright © 2016年 ZK. All rights reserved.
//

#import "ZKSlideView.h"
#import "SMPageControl.h"
#import "AutoSlideScrollView.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "Masonry.h"

@interface ZKSlideView()
@property (nonatomic, strong) UILabel *title , *current;

@property (nonatomic, strong) UIView *bgVIew;

@property (nonatomic, strong)  SMPageControl *pageControl;

@property (nonatomic, strong) AutoSlideScrollView *slideView;

@property (nonatomic, strong) NSMutableArray *imageArr;

@end

@implementation ZKSlideView

- (instancetype)init{
    self = [super init];
    if (self) {
        [self setSize:CGSizeMake(screenW, self.height)];
    }
    return self;
}

- (void)setListArr:(NSArray *)listArr{
    _listArr = listArr;
    _listArr = [self getThreeArrWithArr:_listArr];
    
    if (!_slideView) {
        _slideView=({
            AutoSlideScrollView *slideView = [[AutoSlideScrollView alloc] initWithFrame:self.bounds animationDuration:5.0];
//            slideView.layer.masksToBounds = YES;
            __weak typeof(self) weakSelf = self;
            slideView.totalPagesCount = ^NSInteger(){
                return weakSelf.listArr.count;
            };
            slideView.fetchContentViewAtIndex=^UIView *(NSInteger pageIndex){
                if (weakSelf.listArr.count > pageIndex) {
                    UIImageView *imageView = [weakSelf p_reseViewForIndex:pageIndex];
                    ZKHomeList *homeList = weakSelf.listArr[pageIndex];
                    [imageView sd_setImageWithURL:[NSURL URLWithString:homeList.src] placeholderImage:[UIImage imageNamed:@"Management_Mask"]];
                    return imageView;
                }else{
                    return [UIView new];
                }
            };
            slideView.currentPageIndexChangeBlock=^(NSInteger currentPageIndex){
                weakSelf.pageControl.currentPage = currentPageIndex;
                if (weakSelf.listArr.count > currentPageIndex) {
                    ZKHomeList *homeList = weakSelf.listArr[currentPageIndex];
                    weakSelf.title.text = homeList.title;
                    weakSelf.current.text = [NSString stringWithFormat:@"更新至%@",homeList.current];
                    [weakSelf.title sizeToFit];
                    [weakSelf.current sizeToFit];
                    [weakSelf.current setOrigin:CGPointMake(CGRectGetMaxX(_title.frame) + 15, CGRectGetMaxY(_title.frame)-CGRectGetHeight(_current.frame))];
                }else{
                    weakSelf.title.text = weakSelf.current.text = @"...";
                }
            };
            slideView.tapActionBlock=^(NSInteger pageIndex){
                if (weakSelf.tapActionBlock && weakSelf.listArr.count > pageIndex) {
                    weakSelf.tapActionBlock(weakSelf.listArr[pageIndex]);
                }
            };
            
            slideView;
        });
        [self addSubview:_slideView];
    }
    
    if (!_bgVIew) {
        _bgVIew=({
            UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, self.height - 30, self.width, 30)];
            view.backgroundColor = [UIColor blackColor];
            view.alpha = 0.8f;
            view;
        });
        [self addSubview:_bgVIew];
    }
    
    if (!_title) {
        _title=({
            UILabel *title = [[UILabel alloc] init];
            title.textColor =[UIColor whiteColor];
            title.font = [UIFont systemFontOfSize:15];
            title.textAlignment = NSTextAlignmentCenter;
            title.text = @"一拳超人";
            [title sizeToFit];
            [title setOrigin:CGPointMake(15, (30-CGRectGetMaxY(title.frame))/2)];
            title;
        });
        [self.bgVIew addSubview:_title];
    }
    if (!_current) {
        _current=({
            UILabel *current = [[UILabel alloc] init];
            current.textColor = [UIColor whiteColor];
            current.font = [UIFont systemFontOfSize:12];
            current.textAlignment = NSTextAlignmentCenter;
            current.text = @"更新至N集";
            [current sizeToFit];
            [current setOrigin:CGPointMake(CGRectGetMaxX(_title.frame) + 15, CGRectGetMaxY(_title.frame)-CGRectGetHeight(_current.frame))];
            current;
        });
        [self.bgVIew addSubview:_current];
    }
    
    if (!_pageControl) {
        _pageControl=({
            SMPageControl *pageControl = [[SMPageControl alloc] init];
            pageControl.userInteractionEnabled = NO;
            pageControl.backgroundColor = [UIColor clearColor];
            pageControl.pageIndicatorImage = [UIImage imageNamed:@"banner__page_unselected"];
            pageControl.currentPageIndicatorImage = [UIImage imageNamed:@"banner__page_selected"];
            pageControl.numberOfPages = _listArr.count;
            pageControl.currentPage = 0;
            pageControl.alignment = SMPageControlAlignmentCenter;
            pageControl.frame = CGRectMake(self.width - 65, 0, 60, 30);
            pageControl;
        });
        [self.bgVIew addSubview:_pageControl];
    }
    
    [self reloadData];
    
}

- (UIImageView *)p_reseViewForIndex:(NSInteger)pageIndex{
    if (!_imageArr) {
        _imageArr = [[NSMutableArray alloc] initWithCapacity:3];
        for (int i = 0;i < 3 ; i++) {
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height)];
            imageView.backgroundColor = [UIColor colorWithHexString:@"0xe5e5e5"];
            imageView.clipsToBounds = YES;
            imageView.contentMode = UIViewContentModeScaleToFill;
            [_imageArr addObject:imageView];
        }
    }
    UIImageView *imageVIew = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height)];
    NSInteger  currentPageIndex = self.slideView.currentPageIndex;
    if (pageIndex == currentPageIndex) {
        imageVIew = _imageArr[1];
    }else if (pageIndex == currentPageIndex +1 || (labs(pageIndex - currentPageIndex) > 1 && pageIndex< currentPageIndex)){
        imageVIew = _imageArr[2];
    }else{
        imageVIew = _imageArr[0];
    }
    return imageVIew;
}

//不重复的随机选择
-(NSArray *)getThreeArrWithArr:(NSArray*)arr{
    NSMutableArray *returnArr = [NSMutableArray array];
    NSInteger old = 0;
    for (int i = 0; i<3; i++) {
        NSInteger num = [self getRandomNumber:0 to:arr.count-4];
        if (num == old) {
            num = [self getRandomNumber:0 to:arr.count-4];
        }
        [returnArr addObject:[arr objectAtIndex:num]];
        old = num;
    }
    
    return returnArr;
}

//随机数
-(NSInteger)getRandomNumber:(NSInteger)from to:(NSInteger)to{
    
    return  (from + (arc4random() % (to - from + 1)));
        
    }

- (void)reloadData{
    self.hidden = _listArr.count <= 0;
    if (_listArr.count <= 0) {
        return;
    }
    NSInteger currentPageIndex =MIN(self.slideView.currentPageIndex, _listArr.count-1);
    ZKHomeList *list = _listArr[currentPageIndex];
    _title.text = list.title;
    _current.text = [NSString stringWithFormat:@"更新至%@",list.current];
    [_title sizeToFit];
    [_current sizeToFit];
    [_current setOrigin:CGPointMake(CGRectGetMaxX(_title.frame) + 15, CGRectGetMaxY(_title.frame)-CGRectGetHeight(_current.frame))];
    _pageControl.numberOfPages = _listArr.count;
    _pageControl.currentPage = currentPageIndex;
    [_slideView reloadData];
    
}

@end
