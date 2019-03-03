//
//  AutRealNameView.swift
//  eLahuoForCar
//
//  Created by IceHan on 16/3/30.
//  Copyright © 2016年 elahuo.net. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class AutRealNameView: BaseAutTableViewController {
    
    @IBOutlet weak var mTfRealName: UITextField! // 真实姓名
    @IBOutlet weak var mIvIdCard: UIImageView! // 身份证照片
    @IBOutlet weak var mIvDriver: UIImageView! // 驾驶证照片
    @IBOutlet weak var mBtnIdCard: UIButton! // 身份证拍照
    @IBOutlet weak var mBtnDriver: UIButton! // 驾驶证拍照
    
    private var mImageNameIdCard:String!
    private var mImageNameDriver:String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 图片名称
        mImageNameIdCard = "COCardPicture\(UserBean.sharedInstance.userId).jpg"
        mImageNameDriver = "CODLPicture\(UserBean.sharedInstance.userId).jpg"
        
        if let isFinish = UserBean.sharedInstance.isFinishAutRealName {
            if isFinish == true {
                mTfRealName.enabled = false
                mBtnIdCard.enabled = false
                mBtnIdCard.hidden = true
                mBtnDriver.enabled = false
                mBtnDriver.hidden = true
                // 提交按钮不可点击,且文字颜色变为灰色
                self.navigationItem.rightBarButtonItem?.enabled = false
                var notClickAttrs: [NSObject : AnyObject] = NSMutableDictionary() as [NSObject : AnyObject]
                notClickAttrs[NSForegroundColorAttributeName] = UIColor.grayColor()
                self.navigationItem.rightBarButtonItem?.setTitleTextAttributes(notClickAttrs as? [String : AnyObject], forState: .Normal)
            } else {
                mTfRealName.enabled = true
                mBtnIdCard.enabled = true
                mBtnIdCard.hidden = false
                mBtnDriver.enabled = true
                mBtnDriver.hidden = false
                // 提交按钮可以点击
                self.navigationItem.rightBarButtonItem?.enabled = true
                var notClickAttrs: [NSObject : AnyObject] = NSMutableDictionary() as [NSObject : AnyObject]
                notClickAttrs[NSForegroundColorAttributeName] = UIColor(red: 29.0 / 255.0, green: 154.0 / 255.0, blue: 115.0 / 255.0, alpha: 1.0)
                self.navigationItem.rightBarButtonItem?.setTitleTextAttributes(notClickAttrs as? [String : AnyObject], forState: .Normal)
            }
        }
        
        // 加载数据
        self.loadAutData()
    }
    
    
    
    // 加载数据
    func loadAutData() {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        // 用户名
        let userName = userDefaults.stringForKey("COName")
        let cachesPath = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true).first
        let idCardImagePath = NSString(string: cachesPath!).stringByAppendingPathComponent("COCardPicture\(UserBean.sharedInstance.userId).jpg") // 身份证图片路径
        // 身份证照片
        let idCardImage = UIImage(contentsOfFile: idCardImagePath)
        let dirverLicensePath = NSString(string: cachesPath!).stringByAppendingPathComponent("CODLPicture\(UserBean.sharedInstance.userId).jpg") // 驾驶证图片路径
        // 驾驶证图片
        let dirverLicenseImage = UIImage(contentsOfFile: dirverLicensePath)
        
        // 本地有数据
        if userName != nil && idCardImage != nil && dirverLicenseImage != nil {
            self.mTfRealName.text = userName
            self.mIvIdCard.image = idCardImage
            self.mIvDriver.image = dirverLicenseImage
            
        } else { // 本地没有数据,去网络请求
            
            ToastHub.sharedInstance.showHubWithLoad(self.view, text: "加载数据中...")
            let jsonDict:JSON = [
                "COId": UserBean.sharedInstance.userId
            ]
            
            let params = ["jo": jsonDict.description]
            Alamofire.request(.GET, ApiContants.URL_GET_AUT_REAL_NAME, parameters: params).responseJSON { (result) in
                DevUtils.prints("加载实名认证", cls: self, content: result.description)
                ToastHub.sharedInstance.hideHub()
                if let resultValue = result.result.value{
                    if let realName = JSON(resultValue)["COName"].string { // 车主姓名
                        self.mTfRealName.text = realName
                        
                        // 保存数据到本地
                        userDefaults.setObject(realName, forKey: "COName")
                    }
                    if let idCardImg = JSON(resultValue)["COCardPicture"].string { // 身份证照片名称
                        DevUtils.prints(self, content: "idCardImg = \(idCardImg)")
                        let imgUrl = ApiContants.URL_GET_IMAGE + "?imageBNType=COCardPicture&imageFileName=" + idCardImg
                        DevUtils.prints("身份证照片URL", cls: self, content: imgUrl)
                        let idCardImageData = NSData(contentsOfURL: NSURL(string: imgUrl)!)
                        self.mIvIdCard.image = UIImage(data: idCardImageData!)
                        
                        // 保存图片到本地
                        idCardImageData?.writeToFile(idCardImagePath, atomically: true)
                        
                    }
                    if let driverImg = JSON(resultValue)["CODLPicture"].string { // 驾驶证照片名称
                        let imgUrl = ApiContants.URL_GET_IMAGE + "?imageBNType=CODLPicture&imageFileName=" + driverImg
                        DevUtils.prints("驾驶证照片URL", cls: self, content: imgUrl)
                        let driverLicenseData = NSData(contentsOfURL: NSURL(string: imgUrl)!)
                        self.mIvDriver.image = UIImage(data: driverLicenseData!)
                        
                        // 保存图片到本地
                        driverLicenseData?.writeToFile(dirverLicensePath, atomically: true)
                    }
                }
            }
        }
        
        
        
    }
    

    
    // 提交认证数据
    @IBAction func actionSubmitAutData(sender: UIBarButtonItem) {
        // 退出键盘
        self.mTfRealName.resignFirstResponder()
        
        // 提交前的逻辑判断
        if !self.mTfRealName.text!.isEmpty && self.mIvIdCard.image != nil && self.mIvDriver.image != nil {
            // 提交数据
            let jsonDict:JSON = [
                "COId": UserBean.sharedInstance.userId, // 车主ID
                "COName": self.mTfRealName.text!, // 真实姓名
                "COCardPicture": self.mImageNameIdCard, // 身份证照片名称
                "CODLPicture": self.mImageNameDriver // 驾驶证照片名称
            ]
            DevUtils.prints("实名认证-参数", cls: self, content: jsonDict.description)
            let params = ["jo":jsonDict.description]
            Alamofire.request(.POST, ApiContants.URL_POST_AUT_REAL_NAME, parameters: params).responseJSON { (result) in
                DevUtils.prints("实名认证-返回值", cls: self, content: result.description)
                if result.result.isFailure{
                    ToastHub.sharedInstance.showHubWithText(self.view, text: "网络异常,请重试")
                    return
                }
                
                if let resultValue = result.result.value{
                    let resultCode:Int = JSON(resultValue)["resultSign"].int!
                    if (resultCode == 1) { // 成功
                        ToastHub.sharedInstance.showHubWithText(self.view, text: "提交数据成功,等待审核")
                        
                        // 保存数据到本地
                        let userDefaults = NSUserDefaults.standardUserDefaults()
                        userDefaults.setObject(self.mTfRealName.text, forKey: "COName")
                        
                    }else{ // 未知状态
                        ToastHub.sharedInstance.showHubWithText(self.view, text: "未知状态")
                    }
                }
            }
        }else {
            ToastHub.sharedInstance.showHubWithText(self.view, text: "请您填写所有内容")
            return
        }
        
    }
    
    // 拍照：身份证
    @IBAction func actionIdCardCamera(sender: UIButton) {
        DevUtils.prints(self, content: "身份证拍照")
        // 启动相机
        openImageController(mIvIdCard, imageName: mImageNameIdCard)
    }
    
    // 拍照：驾驶证
    @IBAction func actionDriverCamera(sender: UIButton) {
        DevUtils.prints(self, content: "驾驶证拍照")
        // 启动相机
        openImageController(mIvDriver, imageName: mImageNameDriver)
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
