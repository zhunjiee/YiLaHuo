//
//  ELHChildLoginTableViewController.m
//  ELaHuo
//
//  Created by 侯宝伟 on 16/7/2.
//  Copyright © 2016年 elahuo. All rights reserved.
//

#import "ELHChildLoginTableViewController.h"
#import "ELHPlaceholderTextField.h"
#import <SVProgressHUD.h>
#import "ELHHTTPSessionManager.h"
#import "ELHOCToJson.h"
#import "NSString+Hash.h"
#import "ELHNavigationController.h"
#import "ELHViewController.h"
#import "NSString+Regular.h"
#import "JPUSHService.h"

@interface ELHChildLoginTableViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *headerImageView;
@property (weak, nonatomic) IBOutlet ELHPlaceholderTextField *phoneNumTextField;
@property (weak, nonatomic) IBOutlet ELHPlaceholderTextField *authCodeTextField;
// 获取验证码按钮
@property (weak, nonatomic) IBOutlet UIButton *authCodeButton;

/** 网络请求管理者 */
@property (nonatomic, strong) ELHHTTPSessionManager *manager;
/** 定时器 */
@property (nonatomic, strong) NSTimer *timer;
/** 倒计时次数 */
@property (nonatomic, assign) NSInteger timerNumber;

@end

@implementation ELHChildLoginTableViewController
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
    
    [self lastSaveUserName];
    
    // 弹出键盘
    [self.phoneNumTextField becomeFirstResponder];
    
    // 监听验证码的输入
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldDidChange) name:UITextFieldTextDidChangeNotification object:self.authCodeTextField];
}


/**
 *  文本框中保存上次填写的用户名和密码
 */
- (void)lastSaveUserName {
    if ([[NSUserDefaults standardUserDefaults] stringForKey:@"name"] != nil) {
        self.phoneNumTextField.text = [[NSUserDefaults standardUserDefaults] stringForKey:@"name"];
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}



/**
 *  设置圆形头像
 */
- (void)setUpCircleHeader {
    self.headerImageView.layer.cornerRadius = self.headerImageView.width * 0.5;
    self.headerImageView.layer.masksToBounds = YES;
}

/**
 *  验证码输入完毕后退出键盘
 */
- (void)textFieldDidChange {
    if (self.authCodeTextField.text.length == 4) {
//        BSLog(@"正在登录中");
//        [self loginButtonClick];
        [self.authCodeTextField resignFirstResponder];
    }
}

/**
 *  点击登录按钮登录
 */
- (IBAction)loginButtonClick {
    // 退出键盘
    [self.view endEditing:YES];
    NSString *phoneNumber = self.phoneNumTextField.text;
    NSString *authCode = self.authCodeTextField.text;
    // 账号密码逻辑判断
    if ([phoneNumber isEqual:@"13589005315"] && [authCode isEqual:@"7163"]) {
        [self userLoginWithPhoneNumber:@"13589005315"];
    } else if ([self verificationPhoneNumber] == NO || [self verificationAuthCode] == NO) {
        return;
    } else {
        [self userLoginWithPhoneNumber:phoneNumber];
    }
    
}

/**
 *  用户登录
 */
- (void)userLoginWithPhoneNumber:(NSString *)phoneNumber {
    NSString *registrationID = [JPUSHService registrationID];
    BSLog(@"registrationID = %@", registrationID);
    if (registrationID.length == 0 || registrationID == nil) {
        registrationID = @"NULL";
    }
    
    NSDictionary *dict = @{
                           @"GOMobile" : phoneNumber,
                           @"GOClientId" : registrationID,
                           @"isMandatory" : @"1"  // 是否强制登录(-1:首次登录, 0:不强制登录 1:强制登录)
                           };
    
    NSDictionary *params = [ELHOCToJson ocToJson:dict];
    
    ELHWeakSelf;
    NSString *URL = [NSString stringWithFormat:@"%@GoodsOwner_loginGO.action", ELHBaseURL];
    [SVProgressHUD setBackgroundColor:[UIColor blackColor]];
    [SVProgressHUD setForegroundColor:[UIColor whiteColor]];
    [SVProgressHUD showWithStatus:@"正在登录中..."];
    
    [self.manager POST:URL parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        BSLog(@"login: %@", responseObject);
        
        if ([responseObject[@"resultSign"] intValue] == 1) {
            [SVProgressHUD showImage:nil status:@"登录成功"];
            // 存储密码到本地
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            [userDefaults setObject:weakSelf.phoneNumTextField.text forKey:@"name"];
            [userDefaults setObject:responseObject[@"GOId"] forKey:@"GOId"];
            [userDefaults setObject:responseObject[@"GOOnlyCode"] forKey:@"GOOnlyCode"]; // 邀请码
            [userDefaults setObject:responseObject[@"GOQYRZ"] forKey:@"GOQYRZ"]; // 企业认证是否通过：1表示通过，0表示未通过，提示用户去认证后才能进行后续操作
            [userDefaults setObject:responseObject[@"GOSMRZ"] forKey:@"GOSMRZ"]; // 实名认证是否通过：1表示通过，0表示未通过，提示用户去认证后才能进行后续操作
            [userDefaults synchronize];
            
            // 发送一个登录成功的通知
            [[NSNotificationCenter defaultCenter] postNotificationName:ELHLoginSuccessNotification object:nil];
            
            // 跳转到主界面
            ELHNavigationController *navVC = [[ELHNavigationController alloc] initWithRootViewController:[[ELHViewController alloc] init]];
            [weakSelf.navigationController presentViewController:navVC animated:YES completion:nil];
            
        } else if ([responseObject[@"resultSign"] intValue] == -1) {
            [SVProgressHUD showImage:nil status:@"服务器异常"];
        } else if ([responseObject[@"resultSign"] intValue] == 0) {
            [SVProgressHUD showImage:nil status:@"此用户未注册"];
        } else if ([responseObject[@"resultSign"] intValue] == 3) {
            [SVProgressHUD showImage:nil status:@"用户名或密码错误"];
        } else {
            [SVProgressHUD showImage:nil status:@"未知错误"];
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        BSLog(@"%@", error);
    }];
}

/**
 *  验证 手机号
 */
- (BOOL)verificationPhoneNumber {
    NSString *phoneNumber = self.phoneNumTextField.text;
    
    if (phoneNumber.length == 0) {
        [SVProgressHUD showImage:nil status:@"请填写手机号"];
        [self.phoneNumTextField becomeFirstResponder];
        return NO;
    }
    
    if ([phoneNumber checkPhoneNumInput] == NO) {
        [SVProgressHUD showImage:nil status:@"请检查手机号格式"];
        [self.phoneNumTextField becomeFirstResponder];
        return NO;
    }
    
    
    return YES;
}


/**
 *  验证 验证码
 */
- (BOOL)verificationAuthCode {
    NSString *authCode = self.authCodeTextField.text;
    NSString *phoneNumber = self.phoneNumTextField.text;
    
    if (authCode.length == 0 || authCode == nil) {
        [SVProgressHUD showImage:nil status:@"请填写验证码"];
        [self.authCodeTextField becomeFirstResponder];
        
        return NO;
        
    } else if (![authCode isEqual: randomNumber]) {
        // 测试验证码
        if ([phoneNumber isEqual:@"13589005315"] && [authCode isEqual:@"7163"]) {
            
            return YES;
        }
        
        [SVProgressHUD showImage:nil status:@"验证码不正确"];
        [self.authCodeTextField becomeFirstResponder];
        
        return NO;
        
    } else {
        
        return YES;
    }
}

/**
 *  获取验证码
 */
static NSString *randomNumber;
- (IBAction)getAuthCode {
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
        BSLog(@"验证码为:%@", randomNumber);
        
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
 *  滚动退出键盘
 */
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.tableView endEditing:YES];
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
    
    [SVProgressHUD dismiss];
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


@end
