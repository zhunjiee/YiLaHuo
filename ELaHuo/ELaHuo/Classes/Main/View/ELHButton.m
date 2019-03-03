//
//  ELHButton.m
//  ELaHuoSiJi
//
//  Created by elahuo on 16/3/8.
//  Copyright © 2016年 elahuo. All rights reserved.
//

#import "ELHButton.h"
#import "UIImage+Circle.h"



@implementation ELHButton
// 从xib加载调用
- (void)awakeFromNib {
    // 文字居中
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    
    // 设置图片为圆形
    self.imageView.layer.cornerRadius = ELHHeaderWidth * 0.5;
    self.imageView.layer.masksToBounds = YES;
}

// 通过代码创建调用
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.titleLabel.textAlignment = NSTextAlignmentCenter;

        self.imageView.layer.cornerRadius = ELHHeaderWidth * 0.5;
        self.imageView.layer.masksToBounds = YES;
    }
    return self;
}


- (void)layoutSubviews {
    [super layoutSubviews];

    // 调整图片位置
    self.imageView.width = ELHHeaderWidth;
    self.imageView.height = self.imageView.width;
    self.imageView.y = (self.height - self.imageView.height) * 0.5 * 0.5;
    self.imageView.centerX = self.width * 0.5;
    
    
    // 调整文字
    self.titleLabel.x = 0;
    self.titleLabel.y = self.imageView.height + 5;
    self.titleLabel.height = self.height - self.imageView.height;
    self.titleLabel.width = self.width;
}
@end
