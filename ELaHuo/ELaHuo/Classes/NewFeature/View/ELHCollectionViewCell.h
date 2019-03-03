//
//  ELHCollectionViewCell.h
//  ELaHuo
//
//  Created by elahuo on 16/3/9.
//  Copyright © 2016年 elahuo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ELHCollectionViewCell : UICollectionViewCell
@property (nonatomic, strong) UIImage *image;

// 最后一页设置"立即体验"按钮
- (void)setIndexPath:(NSIndexPath *)indexPath count:(NSInteger)count;
@end
