//
//  SmsUtils.swift
//  eLahuoForCar
//
//  Created by IceHan on 16/3/28.
//  Copyright © 2016年 elahuo.net. All rights reserved.
//

import Foundation
import Alamofire

class SmsUtils: NSObject {
    
    static let sharedInstance = SmsUtils()
    private override init() { }
    
    private let API_URL_SMS = "http://211.147.242.161:8888/sms.aspx"
    func sendSms(content:String, toPhone:String) {
        let params = [
            "userid" : "4039",
            "account" : "易拉货",
            "password" : "elahuo123NET",
            "mobile" : toPhone,
            "content" : content + "【e拉货】", // 短信内容
            "sendTime" : "", // 为空表示立即发送，定时发送格式2010-10-24 09:08:10
            "action" : "send",
            "extno" : ""
        ]
        Alamofire.request(.POST, NSURL(string: API_URL_SMS)!, parameters: params).responseString { (response) in
            DevUtils.prints(self, content: response.result.value!)
        }
    }
    
}
