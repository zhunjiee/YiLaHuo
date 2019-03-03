//
//  ELHChooseGuideTool.m
//  ELaHuo
//
//  Created by 侯宝伟 on 16/3/11.
//  Copyright © 2016年 elahuo. All rights reserved.
//

#import "ELHChooseGuideTool.h"
#import "ELHNewFeatureViewController.h"
#import "ELHNavigationController.h"
#import "ELHViewController.h"


#define ELHCurVersionKey @"curVersion"

@implementation ELHChooseGuideTool

+ (UIViewController *)chooseRootViewController{
    
    UIViewController *rootVc = nil;
    // *****新特性界面*****
    // 获取info.plist字典
    NSDictionary *dict = [NSBundle mainBundle].infoDictionary;
    
    // 获取最新的版本号
    NSString *curVersion = dict[@"CFBundleShortVersionString"];
    // 获取上一次的版本号
    NSString *lastVersion = [[NSUserDefaults standardUserDefaults] objectForKey:ELHCurVersionKey];
    
    
    if ([curVersion isEqualToString:lastVersion]) {
        
        // 如果没有新版本那么进入主框架界面
        rootVc = [[ELHNavigationController alloc] initWithRootViewController:[[ELHViewController alloc] init]];
        
        
    }else{
        rootVc = [[ELHNewFeatureViewController alloc] init];
        
        
        // 将最新的版本号保存到偏好设置中
        [[NSUserDefaults standardUserDefaults] setObject:curVersion forKey:ELHCurVersionKey];
        
    }
    
    return rootVc;
}

@end
