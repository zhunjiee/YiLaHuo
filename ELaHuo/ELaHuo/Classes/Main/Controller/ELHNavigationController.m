//
//  ELHNavigationController.m
//  ElaHuo
//
//  Created by elahuo on 16/3/7.
//  Copyright © 2016年 elahuo. All rights reserved.
//

#import "ELHNavigationController.h"

@interface ELHNavigationController () <UIGestureRecognizerDelegate>

@end

@implementation ELHNavigationController
+ (void)initialize {
    // 统一设置导航栏属性
    UINavigationBar *bar = [UINavigationBar appearance];
    
    // 设置title文字属性
    NSMutableDictionary *titleAttrs = [NSMutableDictionary dictionary];
    titleAttrs[NSFontAttributeName] = [UIFont systemFontOfSize:20];
    titleAttrs[NSForegroundColorAttributeName] = ELHGlobalColor;
    [bar setTitleTextAttributes:titleAttrs];
    // 设置导航栏文字颜色
    [bar setTintColor:ELHGlobalColor];

    
    // 设置UIBarButtonItem相关属性
    UIBarButtonItem *item = [UIBarButtonItem appearance];
//    // 正常状态
    NSMutableDictionary *normalAttrs = [NSMutableDictionary dictionary];
    normalAttrs[NSFontAttributeName] = [UIFont systemFontOfSize:17];
//    normalAttrs[NSForegroundColorAttributeName] = ELHGlobalColor;
    [item setTitleTextAttributes:normalAttrs forState:UIControlStateNormal];
    // 高亮状态
    NSMutableDictionary *highlightAttrs = [NSMutableDictionary dictionary];
    highlightAttrs[NSForegroundColorAttributeName] = ELHGlobalColor;
    [item setTitleTextAttributes:highlightAttrs forState:UIControlStateHighlighted];
    // 隐藏"back"文字
    [item setBackButtonTitlePositionAdjustment:UIOffsetMake(0, -60) forBarMetrics:UIBarMetricsDefault];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.interactivePopGestureRecognizer.delegate =self;
    
}


#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    return self.childViewControllers.count > 1;
}

@end
