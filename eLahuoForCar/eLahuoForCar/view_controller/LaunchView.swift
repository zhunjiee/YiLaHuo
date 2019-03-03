//
//  LaunchView.swift
//  eLahuoForCar
//
//  Created by eLahuo on 16/3/31.
//  Copyright © 2016年 elahuo.net. All rights reserved.
//

import UIKit

class LaunchView: UIViewController {

    @IBOutlet weak var mAppVersion: UILabel!
    
    //private var mBundleVersion:String = "1.0"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // 用户版本号
        if let mBundleVersion = NSBundle.mainBundle().infoDictionary?["CFBundleShortVersionString"] {
            mAppVersion.text = "司机版V\(mBundleVersion)"
        }
        
        // 自动登录
        if let phoneNum = UserBean.sharedInstance.phoneNum {
            ChildLoginTableViewController.userLogin(self, phoneNum: phoneNum, isAutoLogin: true, isDismiss: false )
        }
        
        NSTimer.scheduledTimerWithTimeInterval(3, target: self, selector: #selector(LaunchView.enterMainView), userInfo: nil, repeats: false)
    }
    
    func enterMainView() {
        self.performSegueWithIdentifier(IdentityConstants.SugueToMainView, sender: self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
