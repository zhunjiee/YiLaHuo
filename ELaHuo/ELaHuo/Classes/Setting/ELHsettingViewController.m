//
//  ELHsettingViewController.m
//  ELaHuo
//
//  Created by elahuo on 16/3/9.
//  Copyright © 2016年 elahuo. All rights reserved.
//

#import "ELHsettingViewController.h"
#import <SVProgressHUD.h>
#import "ELHAboutUsViewController.h"
#import "ELHServiceViewController.h"
#import "FAQViewController.h"

@interface ELHsettingViewController ()
@property (weak, nonatomic) IBOutlet UIButton *logoutButton;
@property (weak, nonatomic) IBOutlet UILabel *servicePhoneLabel; // 客服电话
@property (weak, nonatomic) IBOutlet UILabel *versionLabel;

@end

@implementation ELHsettingViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setUpNav];

    self.versionLabel.text = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
}

- (void)setUpNav {
    self.navigationItem.title = @"系统设置";
}

/**
 *  服务条款
 */
- (IBAction)clearCaches {
    // 跳转到服务条款页面
    ELHServiceViewController *serviceVC = [[ELHServiceViewController alloc] init];
    
    [self.navigationController pushViewController:serviceVC animated:YES];
}

/**
 *  常见问题
 */
- (IBAction)moreProducts {
    // 跳转到常见问题页面
    FAQViewController *FAQVC = [UIStoryboard storyboardWithName:NSStringFromClass([FAQViewController class]) bundle:nil].instantiateInitialViewController;
    [self.navigationController pushViewController:FAQVC animated:YES];

}

/**
 *  咨询客服
 */
- (IBAction)feedbackCenter {
    NSString *message = self.servicePhoneLabel.text;
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"联系客服" message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"呼叫" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        // 打电话
        NSURL *telURL = [[NSURL alloc] initWithString:@"tel:4000528810"];
        if ([UIApplication.sharedApplication canOpenURL:telURL]) {
            [UIApplication.sharedApplication openURL:telURL];
        }
    }];
    
    [alertController addAction:cancelAction];
    [alertController addAction:confirmAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

/**
 *  退出登录
 */
- (IBAction)logoutButtonClick {
    // 清除用户数据
    [self clearAllUserDefaultsData];
    
    [SVProgressHUD showImage:nil status:@"退出登录成功"];
    
    // 发送退出登录通知
    [[NSNotificationCenter defaultCenter] postNotificationName:ELHCancelLoginNotification object:nil];
    
    [self.navigationController popViewControllerAnimated:YES];
}



/**
 *  清除所有的存储本地的数据
 */
- (void)clearAllUserDefaultsData {
    // 清除偏好设置缓存
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *dic = [userDefaults dictionaryRepresentation];
    for (id  key in dic) {
        if ([key isEqualToString:@"registrationID"]) {
            continue;
        }
        [userDefaults removeObjectForKey:key];
    }
    [userDefaults synchronize];
    
    // 清除Caches目录缓存
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSString *cachesPath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject;
        NSFileManager *fileManager = [NSFileManager defaultManager];
        // 获取文件夹的遍历器 : 可以遍历这个文件夹下的所有子路径
        NSDirectoryEnumerator *fileEnumerator = [fileManager enumeratorAtPath:cachesPath];
        for (NSString *subpath in fileEnumerator) {
            // 拼接获取文件全路径
            NSString *fullSubpath = [cachesPath stringByAppendingPathComponent:subpath];
            // 获得属性
            [fileManager removeItemAtPath:fullSubpath error:nil];
        }
        
    });
}

/**
 *  关于我们
 */
- (IBAction)aboutUsButtonClick {
    ELHAboutUsViewController *aboutUsVC = [[ELHAboutUsViewController alloc] init];
    [self.navigationController pushViewController:aboutUsVC animated:YES];
}


@end
