//
//  ELHMenuView.m
//  ElaHuo
//
//  Created by elahuo on 16/3/7.
//  Copyright © 2016年 elahuo. All rights reserved.
//

#import "ELHMenuView.h"
#import "UIImage+Circle.h"
#import "ELHViewController.h"
#import "ELHLoginViewController.h"
#include "ELHHistoryViewController.h"
#import "ELHViewController.h"

@interface ELHMenuView ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topViewConstraint;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *orderHistoryButtonWith;

@end

@implementation ELHMenuView

- (void)awakeFromNib {
    self.trueNameIdentity.userInteractionEnabled = NO;
    self.companyIdentity.userInteractionEnabled = NO;
}


/**
 *  根据offsetX计算菜单视图的位置
 */
- (CGRect)frameWithOffsetX:(CGFloat)offsetX {
    CGRect tempFrame = self.frame;
    tempFrame.origin.x += offsetX;
    self.frame = tempFrame;
    return self.frame;
}


- (void)layoutSubviews {
    [super layoutSubviews];
    // 设置按钮的尺寸
    self.orderHistoryButtonWith.constant = self.width - 20;
    self.topViewConstraint.constant = ScreenH * 0.1;
    
    [self layoutIfNeeded];
}


@end
