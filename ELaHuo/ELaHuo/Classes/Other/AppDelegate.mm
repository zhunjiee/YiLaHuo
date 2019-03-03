//
//  AppDelegate.m
//  ELaHuo
//
//  Created by elahuo on 16/3/7.
//  Copyright © 2016年 elahuo. All rights reserved.
//

#import "AppDelegate.h"
#import "ELHViewController.h"
#import "ELHNavigationController.h"
#import "ELHHistoryViewController.h"
#import "ELHChooseGuideTool.h"
#import "UPPaymentControl.h"
#import <CommonCrypto/CommonDigest.h>
#import "RSA.h"
#import "ELHHTTPSessionManager.h"
#import "ELHOCToJson.h"
#import "ELHPayViewController.h"
#import "JPUSHService.h"
#import <AdSupport/AdSupport.h>
#import "UMSocial.h"
#import "UMSocialWechatHandler.h"
#import "UMSocialQQHandler.h"
#import "UMSocialSinaSSOHandler.h"
#import "ELHLoginViewController.h"


@interface AppDelegate () <BMKGeneralDelegate>
/** 百度地图管理者 */
@property (nonatomic, strong) BMKMapManager *mapManager;
/** 网络请求管理者 */
@property (nonatomic, strong) ELHHTTPSessionManager *manager;


@end


@implementation AppDelegate
/** mapManager的懒加载 */
- (BMKMapManager *)mapManager{
    if (!_mapManager) {
        _mapManager = [[BMKMapManager alloc] init];
        
        // 如果要关注网络及授权验证事件，请设定     generalDelegate参数
        BOOL ret = [_mapManager start:@"40tGPkT2IGbh64tk5YAHbhjNFonwkXTd"  generalDelegate:nil];
        if (!ret) {
            BSLog(@"manager start failed!");
        }
    }
    return _mapManager;
}
/** manager的懒加载 */
- (ELHHTTPSessionManager *)manager{
    if (!_manager) {
        _manager = [ELHHTTPSessionManager manager];
        _manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    }
    return _manager;
}



- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    /**
     *  百度地图的相关配置
     */
    // 创建地图管理者对象
    [self mapManager];
    
    
    /**
     *  极光推送的相关配置
     */
    [JPUSHService registerForRemoteNotificationTypes:(UIUserNotificationTypeBadge |
                                                      UIUserNotificationTypeSound |
                                                      UIUserNotificationTypeAlert)
                                          categories:nil];
    //如不需要使用IDFA，advertisingIdentifier 可为nil
    [JPUSHService setupWithOption:launchOptions appKey:appKey
                          channel:channel
                 apsForProduction:isProduction
            advertisingIdentifier:nil];
    
    // 获取自定义消息推送内容
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter addObserver:self selector:@selector(networkDidReceiveMessage:) name:kJPFNetworkDidReceiveMessageNotification object:nil];
    [defaultCenter addObserver:self selector:@selector(networkDidLogin:) name:kJPFNetworkDidLoginNotification object:nil];
    
    
    /**
     *  友盟分享的相关配置
     */
    //设置友盟社会化组件appkey
    [UMSocialData setAppKey:UmengAppkey];
    
    //设置微信AppId、appSecret，分享url
    [UMSocialWechatHandler setWXAppId:@"wx60640b2d745504df" appSecret:@"15a5051abde45c443119f9890da0636a" url:@"http://www.umeng.com/social"];
    
    //设置手机QQ 的AppId，Appkey，和分享URL，需要#import "UMSocialQQHandler.h"
//    [UMSocialQQHandler setQQWithAppId:@"100424468" appKey:@"c7394704798a158208a74ab60104f0ba" url:@"http://www.umeng.com/social"];
    
    //打开新浪微博的SSO开关，设置新浪微博回调地址，这里必须要和你在新浪微博后台设置的回调地址一致。需要 #import "UMSocialSinaSSOHandler.h"
//    [UMSocialSinaSSOHandler openNewSinaSSOWithAppKey:@"3921700954" secret:@"04b48b094faeb16683c32669824ebdad" RedirectURL:@"http://sns.whalecloud.com/sina2/callback"];
    
    
    /**
     设置程序主界面
     */
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    ELHNavigationController *navigationVC = [[ELHNavigationController alloc] initWithRootViewController:[[ELHViewController alloc] init]];
    self.window.rootViewController = navigationVC;
//    self.window.rootViewController = [ELHChooseGuideTool chooseRootViewController];
    [self.window makeKeyAndVisible];
    
    return YES;
}


// 获取自定义消息推送内容后的处理
- (void)networkDidReceiveMessage:(NSNotification *)notification {
    NSDictionary * userInfo = [notification userInfo];
    NSString *content = [userInfo valueForKey:@"content"];
    NSDictionary *extras = [userInfo valueForKey:@"extras"];
    NSString *customizeField1 = [extras valueForKey:@"customizeField1"]; //自定义参数，key是自己定义的
    
    BSLog(@"收到自定义消息通知:content=[%@], extras=[%@], customizeField1=[%@]", content, extras, customizeField1);
    
    
    if ([content isEqual:@"1000"]) { // 强制登出
        // 清除用户信息
        [self clearAllUserDefaultsData];
        // 发送退出登录通知
        [[NSNotificationCenter defaultCenter] postNotificationName:ELHCancelLoginNotification object:nil];
        
        NSString *title = @"警告";
        NSString *message = @"您的账号已再其他地方登录,如继续使用请重新登录";
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"重新登录" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            // 发送强制登出的通知
            [[NSNotificationCenter defaultCenter] postNotificationName:forceLogoutNotification object:nil];
            
        }];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"退出" style:UIAlertActionStyleCancel handler:nil];
        [alertController addAction:cancelAction];
        [alertController addAction:confirmAction];
        [self.window.rootViewController presentViewController:alertController animated:YES completion:nil];
 
    }
    
    // 有新报价
    if ([content isEqual:@"1002"]) {
        // 有新报价的通知
        [[NSNotificationCenter defaultCenter] postNotificationName:ELHDeliverSuccessNotification object:nil];
    }
    
    // 订单 已通知司机 的个数
    if ([content isEqual:@"1004"]) { // extras{ ROBM : 123456 }
        // 发送已通知司机的通知
        [[NSNotificationCenter defaultCenter] postNotificationName:NoticeDirverNotification object:nil userInfo:extras];
    }
    
    // 施封成功
    if ([content isEqual:@"1005"]) {
        UIView *deliverView = [[UIView alloc] init];
        deliverView.frame = CGRectMake(0, ELHNavY, ScreenW, ScreenH - ELHNavY);
        NSString *lockPictureName = [extras valueForKey:@"ROLockPicture"]; // 图片名称
        NSString *unlockPhoneNum = [extras valueForKey:@"COCUnloadM"]; // 收货人电话
        NSString *unlockPassword = [extras valueForKey:@"COPassword"]; // 解封密码
        
        // 下载图片
        NSString *imageURL = [NSString stringWithFormat:@"%@file/DownLoadServlet?imageBNType=ROLockPicture&imageFileName=%@", ELHBaseURL, lockPictureName];
        NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageURL]];
        UIImage *image = [UIImage imageWithData:imageData];
//        UIImage *tempimage = [UIImage imageNamed:@"guide4Background"];
        // 创建施封图片视图
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        
        imageView.frame = CGRectMake(0, 0, ScreenW, deliverView.height - 35);
        [deliverView addSubview:imageView];
        
        // 创建关闭按钮
//        UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        [closeButton setImage:[UIImage imageNamed:@"closeButton"] forState:UIControlStateNormal];
//        closeButton.frame = CGRectMake(ScreenW - 60, 0, 60, 60);
//        [deliverView addSubview:closeButton];
//        [closeButton addTarget:self action:@selector(closeButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
        
        // 创建确定按钮
        UIButton *confirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [confirmButton setTitle:@"确认发货并发送解封密码" forState:UIControlStateNormal];
        confirmButton.titleLabel.font = [UIFont systemFontOfSize:15];
        confirmButton.titleLabel.textColor = [UIColor whiteColor];
        [confirmButton setBackgroundColor:ELHGlobalColor];
        confirmButton.frame = CGRectMake(0, CGRectGetMaxY(imageView.frame), ScreenW, 35);
        [deliverView addSubview:confirmButton];
        // 利用运行时传参
        objc_setAssociatedObject(confirmButton, "unlockPhoneNum", unlockPhoneNum, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        objc_setAssociatedObject(confirmButton, "unlockPassword", unlockPassword, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        
        [confirmButton addTarget:self action:@selector(confirmDeliverButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.window.rootViewController.view addSubview:deliverView];
        
        // 发送发货成功的通知
        [[NSNotificationCenter defaultCenter] postNotificationName:ELHDeliverSuccessNotification object:nil];
    }
    
    // 交易完成
    if ([content isEqual:@"1007"]) {
        // 确认送达
        [[NSNotificationCenter defaultCenter] postNotificationName:ELHConfirmServiceNotification object:nil];
        
        NSString *title = @"交易完成";
        NSString *message = @"您的订单已完成,赶紧去\"历史订单\"进行评价吧";
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"立即前往" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {

            // 发通知跳转到历史订单界面
            [[NSNotificationCenter defaultCenter] postNotificationName:JumpToHistoryOrderViewNotification object:nil userInfo:extras];
        }];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"暂不前往" style:UIAlertActionStyleCancel handler:nil];
        [alertController addAction:confirmAction];
        [alertController addAction:cancelAction];
        [self.window.rootViewController presentViewController:alertController animated:YES completion:nil];
    }
    
    
    // 司机取消报价
    if ([content isEqual:@"1009"]) {
        // 有新订单的通知
        [[NSNotificationCenter defaultCenter] postNotificationName:ELHDeliverSuccessNotification object:nil];
    }
}

- (void)closeButtonDidClick:(UIButton *)button {
    [button.superview removeFromSuperview];
}

- (void)confirmDeliverButtonClick:(UIButton *)button {
    id unlockPhoneNumber = objc_getAssociatedObject(button, "unlockPhoneNum");
    id unlockPassword = objc_getAssociatedObject(button, "unlockPassword");
    BSLog(@"收货人为:%@, 解封密码为:%@", unlockPhoneNumber, unlockPassword);
    
    // 发送解封密码短信
    if (unlockPhoneNumber != nil && unlockPassword != nil) {
        // 请求参数
        NSDictionary *params = @{
                                 @"userid" : @"4039",
                                 @"account" : @"易拉货",
                                 @"password" : @"elahuo123NET",
                                 @"mobile" : unlockPhoneNumber,
                                 @"content" : [NSString stringWithFormat:@"您当前的运单密码锁解封密码是(%@)。重要密码请妥善保管。【e拉货】", unlockPassword],
                                 @"sendTime" : @"", // 为空表示立即发送，定时发送格式2010-10-24 09:08:10
                                 @"action" : @"send",
                                 @"extno" : @""
                                 };
        
        NSString *URL = @"http://211.147.242.161:8888/sms.aspx";
        
        [self.manager POST:URL parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            
            BSLog(@"responseObject = %@", [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
            [SVProgressHUD showImage:nil status:@"短信发送成功"];
            
            [button.superview removeFromSuperview];
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            [SVProgressHUD showImage:nil status:@"短信发送失败"];
            [button.superview removeFromSuperview];
            BSLog(@"%@", error);
        }];
    }
    
}

/**
 *  清除所有的存储本地的数据
 */
- (void)clearAllUserDefaultsData
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    NSDictionary *dic = [userDefaults dictionaryRepresentation];
    
    for (id  key in dic) {
        if ([key isEqualToString:@"registrationID"]) {
            continue;
        }
        [userDefaults removeObjectForKey:key];
    }
    [userDefaults synchronize];
    
}

/**
 *  获取registrationID
 */
- (void)networkDidLogin:(NSNotification *)notification {
    // 将registrationID存入偏好设置
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *registrationID = [JPUSHService registrationID];
    [userDefaults setObject:registrationID forKey:@"registrationID"];
    
}

/**
 *  应用进入前台
 */
- (void)applicationWillEnterForeground:(UIApplication *)application {
    // 清空通知图标
    [application setApplicationIconBadgeNumber:0];
    // 修改服务器上badge的值
    [JPUSHService setBadge:0];
}


- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(nonnull NSData *)deviceToken {
    BSLog(@"deviceToken = %@", deviceToken);
    // 注册DeviceToken
    [JPUSHService registerDeviceToken:deviceToken];
}


/**
 *  获取APNs(通知)推送内容 iOS7以上
 *  点击 通知栏通知 和 应用处于前台 都会调用此方法,但应用处于前台时通知是不会显示的
 *  @param application
 *  @param userInfo
 */
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    // 取得 APNs 标准信息内容
    NSDictionary *aps = [userInfo valueForKey:@"aps"];
    NSString *content = [aps valueForKey:@"alert"]; //推送显示的内容
    NSInteger badge = [[aps valueForKey:@"badge"] integerValue]; //badge数量
    NSString *sound = [aps valueForKey:@"sound"]; //播放的声音
    
    // 取得Extras字段内容
    NSString *customizeField1 = [userInfo valueForKey:@"customizeExtras"]; //服务端中Extras字段，key是自己定义的
    BSLog(@"收到APNs消息通知: content =[%@], badge=[%ld], sound=[%@], customize field  =[%@]",content,(long)badge,sound,customizeField1);
    
    // IOS 7 Support Required
    [JPUSHService handleRemoteNotification:userInfo];
    completionHandler(UIBackgroundFetchResultNewData);
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"did Fail To Register For Remote Notifications With Error: %@", error);
}



- (NSString*)sha1:(NSString *)string {
    unsigned char digest[CC_SHA1_DIGEST_LENGTH];
    CC_SHA1_CTX context;
    NSString *description;
    
    CC_SHA1_Init(&context);
    
    memset(digest, 0, sizeof(digest));
    
    description = @"";
    
    
    if (string == nil)
    {
        return nil;
    }
    
    // Convert the given 'NSString *' to 'const char *'.
    const char *str = [string cStringUsingEncoding:NSUTF8StringEncoding];
    
    // Check if the conversion has succeeded.
    if (str == NULL)
    {
        return nil;
    }
    
    // Get the length of the C-string.
    int len = (int)strlen(str);
    
    if (len == 0)
    {
        return nil;
    }
    
    
    if (str == NULL)
    {
        return nil;
    }
    
    CC_SHA1_Update(&context, str, len);
    
    CC_SHA1_Final(digest, &context);
    
    description = [NSString stringWithFormat:
                   @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                   digest[ 0], digest[ 1], digest[ 2], digest[ 3],
                   digest[ 4], digest[ 5], digest[ 6], digest[ 7],
                   digest[ 8], digest[ 9], digest[10], digest[11],
                   digest[12], digest[13], digest[14], digest[15],
                   digest[16], digest[17], digest[18], digest[19]];
    
    return description;
}

- (NSString *) readPublicKey:(NSString *) keyName
{
    if (keyName == nil || [keyName isEqualToString:@""]) return nil;
    
    NSMutableArray *filenameChunks = [[keyName componentsSeparatedByString:@"."] mutableCopy];
    NSString *extension = filenameChunks[[filenameChunks count] - 1];
    [filenameChunks removeLastObject]; // remove the extension
    NSString *filename = [filenameChunks componentsJoinedByString:@"."]; // reconstruct the filename with no extension
    
    NSString *keyPath = [[NSBundle mainBundle] pathForResource:filename ofType:extension];
    
    NSString *keyStr = [NSString stringWithContentsOfFile:keyPath encoding:NSUTF8StringEncoding error:nil];
    
    return keyStr;
}

-(BOOL) verify:(NSString *) resultStr {
    
    //验签证书同后台验签证书
    //此处的verify，商户需送去商户后台做验签
    return NO;
}

-(BOOL) verifyLocal:(NSString *) resultStr {

    //从NSString转化为NSDictionary
    NSData *resultData = [resultStr dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *data = [NSJSONSerialization JSONObjectWithData:resultData options:0 error:nil];

    //获取生成签名的数据
    NSString *sign = data[@"sign"];
    NSString *signElements = data[@"data"];
    //NSString *pay_result = signElements[@"pay_result"];
    //NSString *tn = signElements[@"tn"];
    //转换服务器签名数据
    NSData *nsdataFromBase64String = [[NSData alloc]
                                      initWithBase64EncodedString:sign options:0];
    //生成本地签名数据，并生成摘要
//    NSString *mySignBlock = [NSString stringWithFormat:@"pay_result=%@tn=%@",pay_result,tn];
    NSData *dataOriginal = [[self sha1:signElements] dataUsingEncoding:NSUTF8StringEncoding];
    //验证签名
    //TODO：此处如果是正式环境需要换成public_product.key
    NSString *pubkey =[self readPublicKey:@"public_test.key"];
    OSStatus result=[RSA verifyData:dataOriginal sig:nsdataFromBase64String publicKey:pubkey];



    //签名验证成功，商户app做后续处理
    if(result == 0) {
        //支付成功且验签成功，展示支付成功提示
        return YES;
    }
    else {
        //验签失败，交易结果数据被篡改，商户app后台查询交易结果
        return NO;
    }

    return NO;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    /**
     *  银联支付的回调
     */
    [[UPPaymentControl defaultControl] handlePaymentResult:url completeBlock:^(NSString *code, NSDictionary *data) {
        //结果code为成功时，先校验签名，校验成功后做后续处理
        if ([code isEqualToString:@"success"]) {
            //数据从NSDictionary转换为NSString
            //            NSDictionary *data;
            NSData *signData = [NSJSONSerialization dataWithJSONObject:data
                                                               options:0
                                                                 error:nil];
            NSString *sign = [[NSString alloc] initWithData:signData encoding:NSUTF8StringEncoding];
            
            //判断签名数据是否存在
            if(data == nil){
                //如果没有签名数据，建议商户app后台查询交易结果
                return;
            }
            
            //验签证书同后台验签证书
            //此处的verify，商户需送去商户后台做验签
            if([self verify:sign]) {
                //支付成功且验签成功，展示支付成功提示
            }
            else {
                //验签失败，交易结果数据被篡改，商户app后台查询交易结果
                BSLog(@"付款成功");
                // 发送支付完成的通知
                [[NSNotificationCenter defaultCenter] postNotificationName:ELHcomplePayNotification object:nil];
                
            }
        } else if([code isEqualToString:@"fail"]) {
            //交易失败
            BSLog(@"交易失败");
            
            [self unlockDirver];
            
        } else if([code isEqualToString:@"cancel"]) {
            //交易取消
            BSLog(@"交易取消");
            
            [self unlockDirver];
        }
    }];
    
    
    
    // 友盟分享
    [UMSocialSnsService handleOpenURL:url];
    
    
    return YES;
    
    
    
}


- (void)unlockDirver {
    [SVProgressHUD showImage:nil status:@"您已取消了本次订单的支付!"];
    
    NSString *OPId = [[NSUserDefaults standardUserDefaults] stringForKey:@"OPId"];
    BSLog(@"%@", OPId);
    
    if (OPId != nil) {
        // 更新订单状态,取消司机锁定
        NSDictionary *dict = @{
                               @"OPId" : OPId,
                               @"CPLockCOTime" : @"0",
                               };
        
        NSDictionary *params = [ELHOCToJson ocToJson:dict];
        NSString *URL = [NSString stringWithFormat:@"%@OrderPrice_updateOP.action", ELHBaseURL];
        [self.manager POST:URL parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
            
            NSString *resultStr =[[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
            NSData *reslutData = [resultStr dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *resultDict = [NSJSONSerialization JSONObjectWithData:reslutData options:NSJSONReadingMutableContainers error:nil];
            if ([resultDict[@"resultSign"] intValue] == 1) {
                BSLog(@"取消司机锁定成功");
            }
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            BSLog(@"erroe = %@", error);
        }];
    }
}


//获取当前屏幕显示的viewcontroller
- (UIViewController *)getCurrentVC
{
    UIViewController *result = nil;
    
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    if (window.windowLevel != UIWindowLevelNormal)
    {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for(UIWindow * tmpWin in windows)
        {
            if (tmpWin.windowLevel == UIWindowLevelNormal)
            {
                window = tmpWin;
                break;
            }
        }
    }
    
    UIView *frontView = [[window subviews] objectAtIndex:0];
    id nextResponder = [frontView nextResponder];
    
    if ([nextResponder isKindOfClass:[UIViewController class]]) {
        result = nextResponder;
    } else {
        result = window.rootViewController;
    }
    
    return result;
}


- (void)onGetNetworkState:(int)iError
{
    if (0 == iError) {
        BSLog(@"联网成功");
    }
    else{
        BSLog(@"onGetNetworkState %d",iError);
    }
    
}

- (void)onGetPermissionState:(int)iError
{
    if (0 == iError) {
        BSLog(@"授权成功");
    }
    else {
        BSLog(@"onGetPermissionState %d",iError);
    }
}

@end
