//
//  SettingView.swift
//  eLahuoForCar
//
//  Created by elahuo on 16/5/26.
//  Copyright © 2016年 elahuo.net. All rights reserved.
//

import UIKit
import MBProgressHUD

class SettingView: UITableViewController {
    
    @IBOutlet weak var versionLabel: UILabel!
    
    
    // 关闭当前窗口
    @IBAction func closeCurrentView(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let version: String = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleShortVersionString") as! String
        self.versionLabel.text = version
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if indexPath.section == 0 && indexPath.row == 2 {
            DevUtils.prints(self, content: "联系客服")
            // 咨询客服
            let callUsNum = "4000528810"
            let alertController = UIAlertController(title: "联系客服", message: callUsNum, preferredStyle: .Alert)
            alertController.addAction(UIAlertAction(title: "取消", style: .Cancel, handler: nil))
            alertController.addAction(UIAlertAction(title: "呼叫", style: .Default, handler: { (alertAction) in
                let telUrl = NSURL(string: "tel:4000528810")
                
                //            DevUtils.prints("联系客服", cls: self, content: (telUrl?.description)!)
                if UIApplication.sharedApplication().canOpenURL(telUrl!){
                    UIApplication.sharedApplication().openURL(telUrl!)
                }
            }))
            self.presentViewController(alertController, animated: true, completion: nil)
            
        } else if indexPath.section == 2 && indexPath.row == 0 {
            // 退出登录
            
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

            ToastHub.sharedInstance.showHubWithText(self.view, text: "退出登录成功")
            // 发送退出登录的通知
            NSNotificationCenter.defaultCenter().postNotificationName(NotificationConstants.LogoutSuccessNotification, object: nil)
            
            // 退回主界面
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    
    class func cleanCaches(path: String) {
        let fileManager: NSFileManager = NSFileManager.defaultManager()
        
        if fileManager.fileExistsAtPath(path) {
            let childrenFiles: Array<String>? = fileManager.subpathsAtPath(path)
            for fileName: String in childrenFiles! {
                let absolutePath: String = path.stringByAppendingString(fileName)
                _ = try? fileManager.removeItemAtPath(absolutePath)
            }
        }
        
    }

}
