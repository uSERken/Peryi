//
//  ZKTypeCollection.m
//  peryi
//
//  Created by k on 16/5/9.
//  Copyright © 2016年 ZK. All rights reserved.
//

#import "ZKTypeCollection.h"

@interface ZKTypeCollection()<UICollectionViewDelegateFlowLayout>

@end

@implementation ZKTypeCollection

- (instancetype)init{
    if (self = [super init]) {
        [self setUpView];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        
    UICollectionViewFlowLayout *collectionViewFlow = [[UICollectionViewFlowLayout alloc] init];
    [collectionViewFlow setScrollDirection:UICollectionViewScrollDirectionVertical];
        self.collectionViewLayout = collectionViewFlow;
        
    }
    return self;
}

- (void)setUpView{
    
}

@end
