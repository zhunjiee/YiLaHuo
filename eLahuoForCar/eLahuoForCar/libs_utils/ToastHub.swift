//
//  ToastHub.swift
//  eLahuoForCar
//
//  Created by eLahuo on 16/3/31.
//  Copyright © 2016年 elahuo.net. All rights reserved.
//

import Foundation
import MBProgressHUD

class ToastHub: NSObject {
    
    static let sharedInstance = ToastHub()
    
    private override init() { }
    
    private let DEFAULT_HIDE_TIME_SEC = 1.5
    
    private var mProgressHub:MBProgressHUD?
    
    private func showHub(toView:UIView) -> MBProgressHUD {
        return MBProgressHUD.showHUDAddedTo(toView, animated: true)
    }
    
    func showHubWithText(toView:UIView, text:String) -> MBProgressHUD {
        return self.showHubWithText(toView, text: text, isAutoHide: true)
    }
    
    func showHubWithText(toView:UIView, text:String, isAutoHide:Bool) -> MBProgressHUD {
        mProgressHub = showHub(toView)
        mProgressHub?.mode = .Text
        mProgressHub?.labelText = text
        self.autoHideHub(isAutoHide)
        return mProgressHub!
    }
    
    func showHubWithLoad(toView:UIView, text:String) -> MBProgressHUD {
        mProgressHub = showHub(toView)
        mProgressHub?.mode = .Indeterminate
        mProgressHub?.labelText = text
        return mProgressHub!
    }
    
    func hideHub(){
        mProgressHub?.hide(true)
    }
    
    func removeHub() {
        mProgressHub?.removeFromSuperViewOnHide
    }
    
    private func autoHideHub(isAutoHide:Bool){
        if !isAutoHide { return }
        hideHubWithTime(DEFAULT_HIDE_TIME_SEC)
    }

    private func hideHubWithTime(timeSec:Double) {
        let hideTime = dispatch_time(DISPATCH_TIME_NOW, Int64(Double(NSEC_PER_SEC) * timeSec));
        dispatch_after(hideTime, dispatch_get_main_queue()) {
            self.hideHub()
        }
    }

}