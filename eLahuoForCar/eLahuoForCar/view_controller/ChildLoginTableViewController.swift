//
//  ChildLoginTableViewController.swift
//  eLahuoForCar
//
//  Created by 侯宝伟 on 16/7/2.
//  Copyright © 2016年 elahuo.net. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire

class ChildLoginTableViewController: BaseTableViewController {
    
    @IBOutlet weak var mTfPhoneNum: UITextField! // 手机号
    @IBOutlet weak var mTfValidateCode: UITextField! // 验证码
    @IBOutlet weak var mBtnGetValidateCode: UIButton!

    private var mPhoneNum:String!
    private var mPassword:String!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // 弹出键盘
        mTfPhoneNum.becomeFirstResponder()
        
        // 填充数据
        mTfPhoneNum.text = UserBean.sharedInstance.phoneNum
        
        self.registerNotification()
        
    }
    
    
    private static var mValidateCode:Int = 0
    private var isCanSendSms = true
    private var mSmsTimer:NSTimer?
    private var mDefaultSmsTimeSec = 60
    //MARK: - 获取验证码
    @IBAction func actionGetValidateCode() {
        if !isCanSendSms { return }
        
        mTfValidateCode.becomeFirstResponder()
        
        if validatePhoneNum() {
            ChildLoginTableViewController.mValidateCode = MathUtils.sharedInstance.random(1000, max: 9999)
            DevUtils.prints(self, content: "验证码为:\(ChildLoginTableViewController.mValidateCode)")
            let smsContent = "您当前获取的验证码是：\(ChildLoginTableViewController.mValidateCode)。您的验证码仅在当前时间有效,请妥善保管。"
            SmsUtils.sharedInstance.sendSms(smsContent, toPhone: mPhoneNum)
            mSmsTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(ChildLoginTableViewController.sendSmsTimer), userInfo: nil, repeats: true)
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
    
    
    
    //MARK: - 提交数据
    @IBAction func actionSubmitUserData() {
        self.mTfPhoneNum.resignFirstResponder()
        self.mTfValidateCode.resignFirstResponder()
        
        // 测试账号直接登录
        if (mTfPhoneNum == "13589005315" && mTfValidateCode == "7163") {
            ToastHub.sharedInstance.showHubWithLoad(self.tableView, text: "正在登录中...")
            ChildLoginTableViewController.userLogin(self, phoneNum: mPhoneNum, isAutoLogin: false, isDismiss: true)
            return
        } else if (validatePhoneNum() == false || validateValidateCode() == false)  {
            return
        } else {
            ToastHub.sharedInstance.showHubWithLoad(self.tableView, text: "正在登录中...")
            ChildLoginTableViewController.userLogin(self, phoneNum: mPhoneNum, isAutoLogin: false, isDismiss: true)
        }
        
    }
    
    class func userLogin(this:UIViewController, phoneNum:String, isAutoLogin:Bool, isDismiss: Bool){
        let userDefaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
        var registrationID: String? = userDefaults.stringForKey("registrationID")
        if registrationID == nil {
            registrationID = "NULL"
        }
        
        DevUtils.prints(">>>>>>>>>>>>>>> registrationID <<<<<<<<<<<<<<", cls: this, content: registrationID!)
        let jsonDict:JSON = [
            "COMac": "", // IMEI（手机唯一标识码）
            "COMobile": phoneNum, // 用户手机号
            "COClientId":  registrationID!, // 推送的ClientID(个推)
            "isMandatory" : "1"
        ]
        DevUtils.prints("用户登录-参数", cls: this, content: jsonDict.description)
        let params = ["jo": jsonDict.description]
        Alamofire.request(.POST, ApiContants.URL_POST_LOGIN, parameters: params).responseJSON(completionHandler: { (result) in
            DevUtils.prints("用户登录-返回值", cls: this, content: result.description)
            if result.result.isFailure{
                ToastHub.sharedInstance.hideHub()
                ToastHub.sharedInstance.showHubWithText(this.view, text: "网络异常,请重试")
                return
            }
            
            if let resultValue = result.result.value{
                if let resultCode = JSON(resultValue)["resultSign"].int {
                    if (resultCode == -1 && !isAutoLogin) { // 用户名或密码错误
                        ToastHub.sharedInstance.hideHub()
                        ToastHub.sharedInstance.showHubWithText(this.view, text: "用户名或密码错误")
                    }else if (resultCode == 0 && !isAutoLogin) { // 此用户未注册
                        ToastHub.sharedInstance.hideHub()
                        ToastHub.sharedInstance.showHubWithText(this.view, text: "此用户未注册")
                    }else if (resultCode == 1){ // 登录成功
                        let json = JSON(resultValue)
                        
                        if let userId = json["COId"].string { // 车主ID
                            UserBean.sharedInstance.userId = userId
                        }
                        if let phoneNum = json["COMobile"].string { // 手机号
                            UserBean.sharedInstance.phoneNum = phoneNum
                        }
                        
                        if let isFinishAutRealName = json["COSMRZ"].string { // 实名认证是否通过：1表示通过，0表示未通过
                            UserBean.sharedInstance.isFinishAutRealName = (isFinishAutRealName == "1" ? true : false)
                        } else {
                            UserBean.sharedInstance.isFinishAutRealName = false
                        }
                        if let isFinishAutCar = json["COCAudit"].string { // 车辆认证是否通过：1表示通过，0表示未通过
                            UserBean.sharedInstance.isFinishAutCar = (isFinishAutCar == "1" ? true : false)
                        } else {
                            UserBean.sharedInstance.isFinishAutCar = false
                        }
                        if let elockNum = json["COMMCODE"].string { // 已绑定的电子锁锁号
                            UserBean.sharedInstance.elockNum = elockNum
                        }
                        if let soleTag = json["COOnlyCode"].string { // 邀请码
                            UserBean.sharedInstance.soleTag = soleTag
                        }
                        if let starLevel = json["COPJStar"].string { // 星级
                            UserBean.sharedInstance.starLevel = starLevel
                        }
                        if let carLevel = json["COCLevel"].string { // 车辆级别
                            UserBean.sharedInstance.carLevel = carLevel
                        }
                        
                        // 保存数据
                        UserBean.sharedInstance.save()
                        
                        // 发送登录成功的通知
                        NSNotificationCenter.defaultCenter().postNotificationName(NotificationConstants.LoginSuccessNotification, object: nil)
                        
                        if isDismiss {
                            this.navigationController?.dismissViewControllerAnimated(true, completion: nil)
                        }
                        
                    }else if (resultCode == 2 && !isAutoLogin){ // IMEI号更换(此状态暂时不做处理)
                        ToastHub.sharedInstance.hideHub()
                        ToastHub.sharedInstance.showHubWithText(this.view, text: "IMEI号更换")
                    }else if (resultCode == 3 && !isAutoLogin){ // 密码错误
                        ToastHub.sharedInstance.hideHub()
                        ToastHub.sharedInstance.showHubWithText(this.view, text: "密码错误")
                    }else{ // 未知状态
                        ToastHub.sharedInstance.hideHub()
                        ToastHub.sharedInstance.showHubWithText(this.view, text: "未知状态")
                    }
                }else{
                    ToastHub.sharedInstance.showHubWithText(this.view, text: "状态nil")
                }
            }
            
        })
    }
    
    //MARK: - 验证数据
    private func validatePhoneNum() -> Bool{
        // 检查手机号：1.是否为空 2.手机号格式
        if let phoneNum = mTfPhoneNum.text {
            if phoneNum.isEmpty {
                ToastHub.sharedInstance.showHubWithText(self.tableView, text: "请填写手机号")
                return false
            }
            
            if phoneNum.characters.count < 11 {
                ToastHub.sharedInstance.showHubWithText(self.tableView, text: "请检查手机号格式")
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
                ToastHub.sharedInstance.showHubWithText(self.tableView, text: "请填写验证码")
                return false
            }
            
            if ChildLoginTableViewController.mValidateCode != Int(validateCode) {
                let phoneNumber = self.mTfPhoneNum.text
                
                // 测试验证码
                if validateCode == "7163" && phoneNumber == "13589005315" {
                    return true
                }
                ToastHub.sharedInstance.showHubWithText(self.tableView, text: "验证码不正确")
                return false
            }
        }
        return true
    }
    
    /**
     注册通知
     */
    func registerNotification() {
        // TextField改变的通知
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(textFieldTextDidChange), name: UITextFieldTextDidChangeNotification, object: nil)
        
        // 注册成功的通知
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(registerSuccess), name: NotificationConstants.RegisterSuccessNotification, object: nil)
    }
    
    /**
     注册成功登录界面消失
     */
    func registerSuccess() {
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    /**
     输入验证码退出键盘
     */
    func textFieldTextDidChange() {
        if mTfValidateCode.text?.characters.count == 4 {
//            // 自动登录
//            self.actionSubmitUserData()
            self.mTfValidateCode.resignFirstResponder()
        }
    }
    
    
    override func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        self.view.endEditing(true)
    }
    
}
