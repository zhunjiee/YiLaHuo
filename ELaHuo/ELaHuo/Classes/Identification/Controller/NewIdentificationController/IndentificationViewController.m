//
//  IndentificationViewController.m
//  ELaHuo
//
//  Created by elahuo on 16/7/5.
//  Copyright © 2016年 elahuo. All rights reserved.
//

#import "IndentificationViewController.h"
#import "IdentificationTableViewController.h"
#import "ELHUploadFile.h"
#import <SVProgressHUD.h>
#import "ELHHTTPSessionManager.h"
#import "ELHOCToJson.h"
#import "ELHViewController.h"

@interface IndentificationViewController ()
/** 网络请求管理者 */
@property (nonatomic, strong) ELHHTTPSessionManager *manager;
@end

@implementation IndentificationViewController
#pragma mark - 懒加载
/** manager的懒加载 */
- (ELHHTTPSessionManager *)manager {
    if (_manager == nil) {
        _manager = [ELHHTTPSessionManager manager];
    }
    return _manager;
}


#pragma mark - 初始化
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setUpNav];
    
    
}

- (void)viewDidAppear:(BOOL)animated {
    BSLog(@"\nself.companyName = %@\nself.licenseNumber = %@", self.companyName, self.licenseNumber);
}

/**
 *  确认提交
 */
- (IBAction)confirmSubmitUserInfo:(UIButton *)button {
    
    NSString *userID = [[NSUserDefaults standardUserDefaults] stringForKey:@"GOId"]; // 用户ID
    NSString *idCardPictureName = [NSString stringWithFormat:@"GOCardPicture%@.jpg", userID]; // 身份证照片名称
    NSString *licenseNumPicName = [NSString stringWithFormat:@"GOZZPicture%@.jpg", userID]; // 营业执照照片名称
    
    if (self.companyName == nil || self.companyName.length == 0 || self.licenseNumber == nil || self.licenseNumber.length == 0) { // 跳过企业认证,个人用户
        [SVProgressHUD showWithStatus:@"正在提交中..."];
        
        // 上传用户信息
        NSDictionary *dict = @{
                               @"GOId" : userID, // 货主ID
                               @"GOName" : self.trueName, // 真实姓名
                               @"GOCardPicture" : idCardPictureName // 身份证照片名称
                               };
        NSDictionary *params = [ELHOCToJson ocToJson:dict];
        NSString *URL = [NSString stringWithFormat:@"%@GoodsOwner_updateGO.action", ELHBaseURL];
        [self.manager POST:URL parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {

            if ([responseObject[@"resultSign"] intValue] == 1) {
                [SVProgressHUD showImage:nil status:@"提交数据成功,等待审核"];
                [button setTitle:@"提交成功，等待审核" forState:UIControlStateNormal];
            } else {
                [SVProgressHUD showImage:nil status:@"未知状态"];
            }
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            BSLog(@"%@", error);
        }];
        
    } else { // 企业用户
        [SVProgressHUD showWithStatus:@"正在提交中..."];
        
        // 上传用户信息
        NSDictionary *dict = @{
                               @"GOId" : userID, // 货主ID
                               @"GOName" : self.trueName, // 真实姓名
                               @"GOCardPicture" : idCardPictureName // 身份证照片名称
                               };
        NSDictionary *params = [ELHOCToJson ocToJson:dict];
        NSString *URL = [NSString stringWithFormat:@"%@GoodsOwner_updateGO.action", ELHBaseURL];
        ELHWeakSelf;
        [self.manager POST:URL parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            
            if ([responseObject[@"resultSign"] intValue] == 1) {
                // 上传企业认证信息
                NSDictionary *dict = @{
                                       @"GOId" : userID, // 货主ID
                                       @"GOQYMC" : weakSelf.companyName, // 公司名称
                                       @"GOZZH" : weakSelf.licenseNumber, // 营业执照号
                                       @"GOZZPicture" : licenseNumPicName // 营业执照照片名称
                                       };
                
                NSDictionary *params = [ELHOCToJson ocToJson:dict];
                NSString *URL = [NSString stringWithFormat:@"%@GoodsOwner_updateGO.action", ELHBaseURL];
                [weakSelf.manager POST:URL parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
                    if ([responseObject[@"resultSign"] intValue] == 1) {
                        [SVProgressHUD showImage:nil status:@"提交数据成功,等待审核"];
                        [button setTitle:@"提交成功，等待审核" forState:UIControlStateNormal];
                    } else {
                        [SVProgressHUD showImage:nil status:@"未知状态"];
                    }
                } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                    BSLog(@"%@", error);
                }];

            } else {
                [SVProgressHUD showImage:nil status:@"未知状态"];
            }
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            BSLog(@"%@", error);
        }];
    }
}

/**
 *  加载图片
 */
- (UIImage *)loadPictureFromCachesPath:(NSString *)pictureName {
    NSString *cachesPath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject;
    NSString *file = [cachesPath stringByAppendingPathComponent:pictureName];
    NSData *imageData = [NSData dataWithContentsOfFile:file];
    UIImage *image = [UIImage imageWithData:imageData];
    return image;
}


- (void)setUpNav {
    self.navigationItem.title = @"认证信息";
    
    // 自定义返回按钮
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setImage:[UIImage imageNamed:@"icon_NavBackItem"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backFormViewController) forControlEvents:UIControlEventTouchUpInside];
    backButton.frame = CGRectMake(0, 0, 6, 22);
    [backButton setImageEdgeInsets:UIEdgeInsetsMake(0, -8, 0, 0)];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.navigationItem.leftBarButtonItem = item;
    
    // 关闭按钮
    UIBarButtonItem *item2 = [[UIBarButtonItem alloc] initWithTitle:@"关闭" style:UIBarButtonItemStylePlain target:self action:@selector(closeIdentificationViewController)];
    self.navigationItem.rightBarButtonItem = item2;
}


/**
 *  跳转到主界面
 */
- (void)closeIdentificationViewController {
    UIViewController *target = nil;
    for (UIViewController *controller in self.navigationController.viewControllers) { //遍历
        if ([controller isKindOfClass:[ELHViewController class]]) { //这里判断是否为你想要跳转的页面
            target = controller;
        }
    }
    if (target) {
        [self.navigationController popToViewController:target animated:YES]; //跳转
    }
    
}


- (void)backFormViewController {
    [self.navigationController popViewControllerAnimated:NO];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    IdentificationTableViewController *identificationVC = segue.destinationViewController;
    identificationVC.sectionCount = self.sectionCount;
    identificationVC.trueName = self.trueName;
    identificationVC.companyName = self.companyName;
    identificationVC.licenseNumber = self.licenseNumber;
}


@end
