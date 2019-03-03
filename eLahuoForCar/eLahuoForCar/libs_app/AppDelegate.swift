//
//  AppDelegate.swift
//  eLahuoForCar
//
//  Created by IcenHan on 16/3/21.
//  Copyright © 2016年 elahuo.net. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    private let appKey = "7cb275d9dbc3bec13163bb35"
    private let channel = "App Store"
    private let isProduction = true
    
    private let UmengAppkey = "577474b667e58ede68000946"
    
	var window: UIWindow?


	func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        /**
         极光推送
         */
        JPUSHService.registerForRemoteNotificationTypes(OCUtils.UserNotificationType(), categories: nil)
        JPUSHService.setupWithOption(launchOptions, appKey: appKey, channel: channel, apsForProduction: isProduction, advertisingIdentifier: nil)
        let defaultCenter: NSNotificationCenter = NSNotificationCenter.defaultCenter()
        // 获取自定义消息推送内容
        defaultCenter.addObserver(self, selector: #selector(AppDelegate.networkDidReceiveMessage(_:)), name: kJPFNetworkDidReceiveMessageNotification, object: nil)
        // 获取registrationID
        defaultCenter.addObserver(self, selector: #selector(AppDelegate.networkDidLogin(_:)), name: kJPFNetworkDidLoginNotification, object: nil)
        

        /**
         友盟分享
         */
        UMSocialData.setAppKey(UmengAppkey)
        UMSocialWechatHandler.setWXAppId("wx0599229109d35b19", appSecret: "de73a972087997d35961d3c9664de74b", url: "http://www.umeng.com/social")
//        UMSocialQQHandler.setQQWithAppId("", appKey: "", url: "")
//        UMSocialSinaSSOHandler.openNewSinaSSOWithAppKey("", secret: "", redirectURL: "")
        
        
        
        /**
         启用键盘管理工具框架
         */
        let keyboardManager = IQKeyboardManager.sharedManager()
        keyboardManager.enable = true // 开启框架
        keyboardManager.shouldResignOnTouchOutside = true // 点击背景是否收起键盘
        //keyboardManager.shouldToolbarUsesTextFieldTintColor = true // 控制键盘上的工具条文字颜色是否用户自定义
        keyboardManager.enableAutoToolbar = false // 是否显示键盘上的工具条
        
		return true
	}
    
    
    /**
     接收到自定义消息的处理
     */
    func networkDidReceiveMessage(notification: NSNotification) {

        if notification.userInfo != nil {
            let userInfo: [NSObject : AnyObject]? = notification.userInfo
            let content: String! = userInfo!["content"] as! String
            var extras: [NSObject : AnyObject]?
            var customizeFiled1: String?
            
            if userInfo!["extras"] != nil {
                extras = userInfo!["extras"] as? [String : AnyObject]
            }
            if extras != nil {
                customizeFiled1 = extras!["customizeField1"] as? String
            }
            DevUtils.prints(self, content: "收到自定义消息通知:content=[\(content)], extras=[\(extras)], customizeField1=[\(customizeFiled1)]")
            
            
            
            // 强制登出
            if content == "1000" {
                DevUtils.prints(self, content: "强制登出")
                // 清除用户数据,强制登出
                self.clearCachesAndLogout()
                
                // 发送登出警告
                let callUsNum = "您的账号已在其他地方登录,如继续使用请重新登录"
                let alertController = UIAlertController(title: "警告", message: callUsNum, preferredStyle: .Alert)
                let confirmAction = UIAlertAction(title: "重新登录", style: .Default, handler: { (alertAction) in
                    // 发送强制登出的通知
                    NSNotificationCenter .defaultCenter().postNotificationName(NotificationConstants.ForceLogoutNotification, object: nil)
                    
                })
                let cancelAction = UIAlertAction(title: "退出", style: .Cancel, handler: nil)
                alertController.addAction(confirmAction)
                alertController.addAction(cancelAction)
                self.window!.rootViewController!.presentViewController(alertController, animated: true, completion: nil)
                
            }
            
            // 有新订单
            if content == "1003" {
                // 发送有新订单的通知
                NSNotificationCenter.defaultCenter().postNotificationName(NotificationConstants.HaveNewOrderNotification, object: nil)
            }
            
            // 货主付款成功
            if content == "1006" {
                
                // 弹出界面提示
                let callUsNum = "您已成功接到订单,请到\"已接订单\"中查看装货时间"
                let alertController = UIAlertController(title: "成功接单", message: callUsNum, preferredStyle: .Alert)
                let confirmAction = UIAlertAction(title: "确定", style: .Default, handler: { (alertAction) in
                })
                alertController.addAction(confirmAction)
                self.window!.rootViewController!.presentViewController(alertController, animated: true, completion: nil)
            }
            
            
            // 货主取消订单
            if content == "1008" {
                // 发送货主取消订单的通知
                NSNotificationCenter.defaultCenter().postNotificationName(NotificationConstants.CancelOrderNotification, object: nil)
            }
        }

    }
    
    func clearCachesAndLogout() {
        // 清除缓存
        let userDefaults = NSUserDefaults.standardUserDefaults()
        
        let dict: NSDictionary = userDefaults.dictionaryRepresentation()
        let keys = dict.allKeys
        
        for key: AnyObject in keys {
            if key as! String == "registrationID" {
                continue
            }
            userDefaults.removeObjectForKey(key as! String)
        }
        userDefaults.synchronize()
        
        // 清空caches目录
        let cachesPath = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true).first
        SettingView.cleanCaches(cachesPath!)
        
        UserBean.sharedInstance.userId = nil
        UserBean.sharedInstance.phoneNum = nil
        UserBean.sharedInstance.loginPsd = nil
        UserBean.sharedInstance.isFinishAutRealName = false
        UserBean.sharedInstance.isFinishAutCar = false
        UserBean.sharedInstance.elockNum = nil
        UserBean.sharedInstance.soleTag = nil
        
        let userId = userDefaults.stringForKey("userId")
        DevUtils.prints(self, content: "userID = \(userId)")
        
        // 发送退出登录的通知
        NSNotificationCenter.defaultCenter().postNotificationName(NotificationConstants.LogoutSuccessNotification, object: nil)
    }
    
    
    func networkDidLogin(notification: NSNotification) {
        DevUtils.prints(self, content: "*******************************kJPFNetworkDidLoginNotification*******************************")
        
        let userDefaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
        let registrationID: String = JPUSHService.registrationID()
        userDefaults.setObject(registrationID, forKey: "registrationID")
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        // 清空通知图标
        application.applicationIconBadgeNumber = 0
        // 修改服务器上badge的值
        JPUSHService.setBadge(0)
    }

    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        // 注册DeviceToken
        JPUSHService.registerDeviceToken(deviceToken)
        DevUtils.prints(self, content: "Device Token: \(deviceToken)")
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
         DevUtils.prints(self, content: "收到APNs消息通知")
        // 取得 APNs 标准信息内容
        if let aps: [NSObject : AnyObject] = userInfo["aps"]! as? [NSObject : AnyObject] {
            let content: String! = aps["alert"] as! String  //推送显示的内容
            let badge: Int? = aps["badge"] as? Int    //badge数量
            let sound: String? = aps["sound"] as? String    //播放的声音
            var customizeField1: String?    // 自定义内容
            if aps["customizeExtras"] != nil {
                customizeField1 = aps["customizeExtras"] as? String
            }
            
            DevUtils.prints(self, content: "收到APNs消息通知: content =[\(content)], badge=[\(badge)], sound=[\(sound)], customize field  =[\(customizeField1)]")
            
        }
        
        
        // IOS 7 Support Required
        JPUSHService.handleRemoteNotification(userInfo)
        completionHandler(.NewData)
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        DevUtils.prints(self, content: "did Fail To Register For Remote Notifications With Error: \(error)")
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        UMSocialSnsService.handleOpenURL(url)
        
        return true
    }
}

