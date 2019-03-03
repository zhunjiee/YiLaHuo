//
//  RegisterView.swift
//  eLahuoForCar
//
//  Created by IceHan on 16/3/30.
//  Copyright © 2016年 elahuo.net. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class RegisterView: BaseTableViewController {
    
    @IBOutlet weak var mTfPhoneNum: UITextField! // 手机号
    @IBOutlet weak var mTfValidateCode: UITextField! // 验证码
    @IBOutlet weak var mBtnGetValidateCode: UIButton! // 获取验证码
    @IBOutlet weak var mTfInviteCode: UITextField! // 邀请码
    
    private var mPhoneNum:String!
    private var mPassword:String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 弹出键盘
        mTfPhoneNum.becomeFirstResponder()
    }
    
    // MARK: - 获取验证码
    private static var mValidateCode:Int = 0
    private var isCanSendSms = true
    private var mSmsTimer:NSTimer?
    private var mDefaultSmsTimeSec = 60
    @IBAction func actionGetValidateCode(sender: UIButton) {
        if !isCanSendSms { return }
        
        self.mTfValidateCode.becomeFirstResponder()
        
        if validatePhoneNum() {
            RegisterView.mValidateCode = MathUtils.sharedInstance.random(1000, max: 9999)
            DevUtils.prints(self, content: RegisterView.mValidateCode)
            let smsContent = "您当前获取的验证码是：\(RegisterView.mValidateCode)。您的验证码仅在当前时间有效,请妥善保管。"
            SmsUtils.sharedInstance.sendSms(smsContent, toPhone: mPhoneNum)
            mSmsTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(RegisterView.sendSmsTimer), userInfo: nil, repeats: true)
        }
    }
    
    func sendSmsTimer() {
        if mDefaultSmsTimeSec <= 0 { // 计时完成：停止计时器，更新按钮状态，恢复时间，恢复是否可以发送信息
            mSmsTimer?.invalidate()
            mBtnGetValidateCode.setTitle("获取", forState: .Normal)
            mBtnGetValidateCode.userInteractionEnabled = true
            mDefaultSmsTimeSec = 60
            isCanSendSms = true
        }else{ // 计时中：时间自减，更新按钮状态，是否可以发送信息
            mDefaultSmsTimeSec = mDefaultSmsTimeSec - 1
            mBtnGetValidateCode.setTitle("重新获取(\(mDefaultSmsTimeSec)S)", forState: .Normal)
            mBtnGetValidateCode.userInteractionEnabled = false
            isCanSendSms = false

        }
    }
    
    // MARK: - 提交数据
    @IBAction func actionSubmitUserData(sender: UIBarButtonItem) {
        ToastHub.sharedInstance.showHubWithLoad(self.view, text: "正在注册中...")
        self.mTfPhoneNum.resignFirstResponder()
        self.mTfInviteCode.resignFirstResponder()
        self.mTfValidateCode.resignFirstResponder()

        var registrationID: String? = JPUSHService.registrationID()
        if registrationID == nil {
            registrationID = "NULL"
        }
        
        if validatePhoneNum() && validateValidateCode() {
            let jsonDict:JSON = [
                "COMac": "", // IMEI（手机唯一标识码）
                "COMobile": mPhoneNum, // 用户手机号
                "COOnlyCodeF": mTfInviteCode.text!, // 邀请码（选填）
                "COClientId":  registrationID!// 推送的ClientID(个推)
            ]
            DevUtils.prints("用户注册", cls: self, content: jsonDict.description)
            
            let params = ["jo": jsonDict.description]
            Alamofire.request(.POST, ApiContants.URL_POST_REGISTER, parameters: params).responseJSON { (result) in
                DevUtils.prints("用户注册", cls: self, content: result.description)
                if result.result.isFailure{
                    ToastHub.sharedInstance.hideHub()
                    ToastHub.sharedInstance.showHubWithText(self.view, text: "网络异常,请重试")
                    return
                }
                
                if let resultValue = result.result.value{
                    let resultCode:Int = JSON(resultValue)["resultSign_register"].int!
                    if (resultCode == -1) { // 服务器异常
                        ToastHub.sharedInstance.hideHub()
                        ToastHub.sharedInstance.showHubWithText(self.view, text: "未知异常,请联系客服查看")
                    } else if (resultCode == -2) { // 没有有效数据
                        ToastHub.sharedInstance.hideHub()
                        ToastHub.sharedInstance.showHubWithText(self.view, text: "没有有效数据,请联系客服查看")
                    }else if (resultCode == 0) { // 该手机号已被注册
                        ToastHub.sharedInstance.hideHub()
                        ToastHub.sharedInstance.showHubWithText(self.view, text: "该手机号已被注册")
                    }else if (resultCode == 1){ // 注册成功
                        ToastHub.sharedInstance.hideHub()
                        ToastHub.sharedInstance.showHubWithText(self.view, text: "注册成功")
                        
                        // 保存用户名
                        UserBean.sharedInstance.phoneNum = self.mTfPhoneNum.text
                        
                        NSNotificationCenter.defaultCenter().postNotificationName(NotificationConstants.RegisterSuccessNotification, object: nil)
                        
                        // 退出界面
                        self.navigationController?.dismissViewControllerAnimated(false, completion: nil)
                    }else{ // 未知状态
                        ToastHub.sharedInstance.showHubWithText(self.view, text: "未知状态")
                    }
                }
                
            }
        }
    }
    
    // MARK: - 验证数据
    // 验证手机号
    private func validatePhoneNum() -> Bool{
        // 检查手机号：1.是否为空 2.手机号格式
        if let phoneNum = mTfPhoneNum.text {
            if phoneNum.isEmpty {
                ToastHub.sharedInstance.showHubWithText(self.view, text: "请填写手机号")
                return false
            }
            
            if phoneNum.characters.count < 11 {
                ToastHub.sharedInstance.showHubWithText(self.view, text: "请检查手机号格式")
                return false
            }
            mPhoneNum = phoneNum
        }
        return true
    }

    // 验证验证码
    private func validateValidateCode() -> Bool{
        // 检查验证码：1.是否为空 2.是否正确
        if let validateCode = mTfValidateCode.text {
            if validateCode.isEmpty {
                ToastHub.sharedInstance.showHubWithText(self.view, text: "请填写验证码")
                return false
            }
            
            if RegisterView.mValidateCode != Int(validateCode){
                ToastHub.sharedInstance.showHubWithText(self.view, text: "验证码不正确")
                return false
            }
        }
        return true
    }

    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.00001
    }
    
    override func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        self.view.endEditing(true)
    }
}
