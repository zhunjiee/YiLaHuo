//
//  ELHNewFeatureViewController.m
//  ELaHuo
//
//  Created by elahuo on 16/3/9.
//  Copyright © 2016年 elahuo. All rights reserved.
//

#import "ELHNewFeatureViewController.h"
#import "ELHCollectionViewCell.h"

#define maxImageCount 1
@interface ELHNewFeatureViewController () <UIScrollViewDelegate>

@end

@implementation ELHNewFeatureViewController

static NSString * const reuseIdentifier = @"Cell";

// 重写init方法创建
- (instancetype)init {
    // 流水布局
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    // 设置cell的尺寸
    layout.itemSize = [UIScreen mainScreen].bounds.size;
    // 设置每一行的间距
    layout.minimumLineSpacing = 0;
    // 设置每个cell的间距
    layout.minimumInteritemSpacing = 0;
    // 设置滚动方向
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    
    return [self initWithCollectionViewLayout:layout];
}


- (void)viewDidLoad {
    [super viewDidLoad];

    // 初始化CollectionView
    [self setUpCollectionView];
    
    // 注册cell
    [self.collectionView registerClass:[ELHCollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
    
    // Do any additional setup after loading the view.
}

// 设置CollectionView
- (void)setUpCollectionView{
    
    // 注意:self.collectionView 不等于 self.view
    
    self.collectionView.backgroundColor = [UIColor whiteColor];
    
    // 注册cell
    [self.collectionView registerClass:[ELHCollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
    
    
    // 取消弹簧效果
    self.collectionView.bounces = NO;
    // 取消显示指示器
    self.collectionView.showsHorizontalScrollIndicator = NO;
    // 开启分页模式
    self.collectionView.pagingEnabled = YES;
}


#pragma mark <UICollectionViewDataSource>
// 返回有多少个cell
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return maxImageCount;
}



// 返回每个cell长什么样子
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ELHCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
//    NSString *imageName = [NSString stringWithFormat:@"guide%ldBackground", indexPath.item + 1];
    
    cell.image = [UIImage imageNamed:@"guide4Background"];
    
    [cell setIndexPath:indexPath count:maxImageCount];
    
    
    return cell;
}


@end
