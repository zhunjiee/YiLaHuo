//
//  ELHRegisterViewController.m
//  ELaHuo
//
//  Created by elahuo on 16/3/9.
//  Copyright © 2016年 elahuo. All rights reserved.
//

#import "ELHRegisterViewController.h"
#import "NSString+Regular.h"
#import <SVProgressHUD.h>
#import "ELHHTTPSessionManager.h"
#import "ELHOCToJson.h"
#import "ELHViewController.h"
#import "ELHLoginViewController.h"
#import "ELHNavigationController.h"
#import "ELHCaptcheButon.h"
#import "ELHServiceViewController.h"
#import "JPUSHService.h"

@interface ELHRegisterViewController ()
// 手机号
@property (weak, nonatomic) IBOutlet UITextField *phoneNumTextField;
// 邀请码
@property (weak, nonatomic) IBOutlet UITextField *onlyCodeTextField;
// 验证码
@property (weak, nonatomic) IBOutlet UITextField *authCodeTextField;
// 获取验证码按钮
@property (weak, nonatomic) IBOutlet UIButton *authCodeButton;


/** 定时器 */
@property (nonatomic, strong) NSTimer *timer;
/** 倒计时次数 */
@property (nonatomic, assign) NSInteger timerNumber;

/** 网络请求管理者 */
@property (nonatomic, strong) ELHHTTPSessionManager *manager;

@end

@implementation ELHRegisterViewController

#pragma mark - 懒加载
/** manager的懒加载 */
- (ELHHTTPSessionManager *)manager {
    if (_manager == nil) {
        _manager = [ELHHTTPSessionManager manager];
    }
    return _manager;
}

#pragma mark - 初始化
static NSString * const registerCellID = @"registerCell";
static NSString * const stipulationCellID = @"stipulationCell";
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setUpNav];

    [self.phoneNumTextField becomeFirstResponder];
    
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.showsHorizontalScrollIndicator = NO;
}



/**
 *  初始化导航栏
 */
- (void)setUpNav {
    self.navigationItem.title = @"注册界面";
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"注册" style:UIBarButtonItemStyleDone target:self action:@selector(registerButtonClick)];
    self.navigationItem.rightBarButtonItem = item;
}


#pragma mark - UITableView相关
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 10;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (section == 0) {
        return 0.000001;
    } else {
        return 10;
    }
}



#pragma mark - 定时器相关
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.timerNumber != 0) {
        [self startTimer];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self stopTimer];
}
- (void)startTimer
{
    if (self.timer)
    {
        [self.timer invalidate];
        self.timer = nil;
    }
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                  target:self
                                                selector:@selector(delayGetCode)
                                                userInfo:nil
                                                 repeats:YES];
}

- (void)stopTimer
{
    if (self.timer)
    {
        [self.timer invalidate];
        self.timer = nil;
    }
}

- (void)delayGetCode
{
    self.timerNumber--;
    
    if (self.timerNumber > 0)
    {
        [self.authCodeButton setTitle:[NSString stringWithFormat:@"重新获取(%ldS)",(long)self.timerNumber] forState:UIControlStateNormal];
    }else
    {
        [self.authCodeButton setTitle:@"获取" forState:UIControlStateNormal];
        self.authCodeButton.enabled = YES;
        [self stopTimer];
    }
}

#pragma mark - 监听方法
/**
 *  点击了获取验证码按钮
 */
static NSString *randomNumber;

- (IBAction)getAuthCodeButtonClick {

    if (self.phoneNumTextField.text == nil || self.phoneNumTextField.text.length == 0) {
        [SVProgressHUD showImage:nil status:@"请先填入您的手机号"];
        return;
        
    } else if ([self.phoneNumTextField.text checkPhoneNumInput] == NO) {
        [SVProgressHUD showImage:nil status:@"请检查手机号格式"];
        return;
        
    } else {
        [self.authCodeTextField becomeFirstResponder];
        
        self.authCodeButton.enabled = NO;
        self.timerNumber = 60;
        [self startTimer];
        
        // 创建网络请求管理者
        ELHHTTPSessionManager *manager = [ELHHTTPSessionManager manager];
        // 告诉AFN，支持接受 text/xml 的数据
        _manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/xml"];
        // 告诉AFN, 将返回的数据当做XML来处理
        _manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        
        
        // 生成4位验证码
        int num = (arc4random() % 10000);
        randomNumber = [NSString stringWithFormat:@"%.4d", num];
        BSLog(@"%@", randomNumber);
        
            // 请求参数
            NSDictionary *params = @{
                                   @"userid" : @"4039",
                                   @"account" : @"易拉货",
                                   @"password" : @"elahuo123NET",
                                   @"mobile" : self.phoneNumTextField.text,
                                   @"content" : [NSString stringWithFormat:@"您当前获取的验证码是：%@。您的验证码仅在当前时间有效,请妥善保管。【e拉货】", randomNumber],
                                   @"sendTime" : @"", // 为空表示立即发送，定时发送格式2010-10-24 09:08:10
                                   @"action" : @"send",
                                   @"extno" : @""
                                   };
        
        
            NSString *URL = @"http://211.147.242.161:8888/sms.aspx";
        

            [manager POST:URL parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
                BSLog(@"%@", [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
        
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                BSLog(@"%@", error);
            }];
    }
    
}

/**
 *  点击了注册按钮
 */
- (void)registerButtonClick {
    // 退出键盘
//    [self.view endEditing:YES];
    
    NSString *phoneNum = self.phoneNumTextField.text;
    NSString *onlyCode = self.onlyCodeTextField.text;
    NSString *authCode = self.authCodeTextField.text;
    
    // 注册相关逻辑判断
    if (phoneNum == nil || phoneNum.length == 0) {
        [SVProgressHUD showImage:nil status:@"请输入手机号"];
        [self.phoneNumTextField becomeFirstResponder];
        return;
    } else if ([phoneNum checkPhoneNumInput] == NO) {
        [SVProgressHUD showImage:nil status:@"请输入正确的手机号码"];
        [self.phoneNumTextField becomeFirstResponder];
        return;
    } else if (authCode.length != 4) {
        [SVProgressHUD showImage:nil status:@"请输入正确的验证码"];
        [self.authCodeTextField becomeFirstResponder];
        return;
    } else if (![authCode isEqual: randomNumber]) {
        [SVProgressHUD showImage:nil status:@"验证码错误,请重新输入"];
        [self.authCodeTextField becomeFirstResponder];
        return;
    } else {
        
        [SVProgressHUD showWithStatus:@"正在注册中,请稍等..."];
        
        NSString *registrationID = [JPUSHService registrationID];
        BSLog(@"registrationID = %@", registrationID);
        if (registrationID.length == 0 || registrationID == nil) {
            registrationID = @"NULL";
        }
        
        NSDictionary *dict = @{
                               @"GOMobile" : phoneNum,
                               @"GOClientId" : registrationID,
                               @"GOOnlyCodeF" : onlyCode
                               };
        
        NSDictionary *params = [ELHOCToJson ocToJson:dict];
        
        
        NSString *URL = [NSString stringWithFormat:@"%@GoodsOwner_registerGO.action", ELHBaseURL];
        
        
        
        ELHWeakSelf;
        [self.manager POST:URL parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            BSLog(@"%@", responseObject);
            
            if ([responseObject[@"resultSign_register"] intValue] == 0) {
                [SVProgressHUD showImage:nil status:@"当前手机已被注册"];
                return;
            } else if ([responseObject[@"resultSign_register"] intValue] == -1) {
                [SVProgressHUD showImage:nil status:@"未知异常,请联系客服查看"];
                return;
            }else if ([responseObject[@"resultSign_register"] intValue] == -2) {
                [SVProgressHUD showImage:nil status:@"没有有效数据,请联系客服查看"];
                return;
            } else if ([responseObject[@"resultSign_register"] intValue] == 1) {
                [SVProgressHUD showImage:nil status:@"注册成功"];
                
                // 保存用户信息
                NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                [userDefaults setObject:weakSelf.phoneNumTextField.text forKey:@"name"];
                
                // 发送注册成功的通知
                [[NSNotificationCenter defaultCenter] postNotificationName:ELHRegisterSuccessNotification object:nil];
                
                // 跳转到主界面
                ELHNavigationController *navVC = [[ELHNavigationController alloc] initWithRootViewController:[[ELHViewController alloc] init]];
                [weakSelf.navigationController presentViewController:navVC animated:YES completion:nil];
            }
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            BSLog(@"%@", error);
        }];
        
    }
    
}

/**
 *  点击了服务条款
 */
- (IBAction)termsOfServiceClick {
    // 跳转到服务条款页面
    ELHServiceViewController *serviceVC = [[ELHServiceViewController alloc] init];
    
    [self.navigationController pushViewController:serviceVC animated:YES];
}

/**
 *  滚动退出键盘
 */
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.view endEditing:YES];
}
@end
