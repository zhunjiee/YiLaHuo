//
//  CameraLockView.swift
//  eLahuoForCar
//
//  Created by IceHan on 16/4/11.
//  Copyright © 2016年 elahuo.net. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import CocoaAsyncSocket

class CameraLockView: BaseAutTableViewController, GCDAsyncSocketDelegate {
    
    @IBOutlet weak var mIvCameraLock: UIImageView!
    @IBOutlet weak var mBtnCameraLock: UIButton!
    
    var mImageNameCameraLock:String!
    
    private var mFormModel:FormModel?
    private var mElockPassword:String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mElockPassword = String(MathUtils.sharedInstance.random(100000, max: 999999))
        mImageNameCameraLock = "ROLockPicture\(UserBean.sharedInstance.userId)_\(mElockPassword).jpg"
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if self.mIvCameraLock.image != nil {
            self.mBtnCameraLock.setTitle(nil, forState: .Normal)
        } else {
            self.mBtnCameraLock.setTitle("点击拍照", forState: .Normal)
        }
    }
    
    func setFormModel(formModel: FormModel) {
        self.mFormModel = formModel
    }
    
    // 施封照片
    @IBAction func actionCameraLock(sender: UIButton) {
        // 启动相机
        openImageController(mIvCameraLock, imageName: mImageNameCameraLock)
        
    }
    
    // 提交施封数据
    @IBAction func submitCameraLock(sender: UIBarButtonItem) {
        if self.mIvCameraLock.image == nil {
            ToastHub.sharedInstance.showHubWithText(self.view, text: "施封照片不能为空")
        }else{
            self.lockElockWithCommand()
        }
    }
    
    // 订阅施封
    private var mSocket:GCDAsyncSocket!
    func lockElockWithCommand() -> Bool {
        ToastHub.sharedInstance.showHubWithLoad(self.view, text: "电子锁施封中...")
        mSocket = GCDAsyncSocket(delegate: self, delegateQueue: dispatch_get_global_queue(0, 0))
        do {
            try mSocket.connectToHost(ApiContants.BASE_ELOCK_HOST, onPort: 9981)
        }catch{
            DevUtils.prints("连接异常", cls: self, content: "Socket连接异常")
        }
        
        // 施封登录
        self.lockRssWithLogin()
        
        return false
    }
    
    func socket(sock: GCDAsyncSocket!, didConnectToHost host: String!, port: UInt16){
        DevUtils.prints("连接成功", cls: self, content: host)
        sock.readDataWithTimeout(-1, tag: 1)
        sock.readDataWithTimeout(-1, tag: 2)
    }
    
    private func lockRssWithLogin() {
        // 登录
        let lockLogin:NSString = "(Mobile)"
            + "Cmd:1,"
            + "ConnectionType:Socket,"
            + "GisCommVersionType:TCP_WebGIS,"
            + "GisID:Android_GIS,"
            + "SubcribeCommunicateIdArr:\(UserBean.sharedInstance.elockNum!),"
            + "SubcribleFlag:true,"
            + "UserName:dev,"
            + "loginId:\(UserBean.sharedInstance.phoneNum!),"
            + "loginPass:dev"
        DevUtils.prints("施封-登录-参数", cls: self, content: lockLogin)
        mSocket.writeData(lockLogin.dataUsingEncoding(NSUTF8StringEncoding), withTimeout: 5000, tag: 1)
    }
    private func lockRssWithLock(){
        // 订阅
        let lockRss:NSString = "(Mobile)"
            + "Cmd:4,"
            + "ConnectionType:Socket,"
            + "GisCommVersionType:TCP_WebGIS,"
            + "GisID:Android_GIS,"
            + "SubcribeCommunicateIdArr:\(UserBean.sharedInstance.elockNum!),"
            + "SubcribleFlag:true,"
            + "UserName:dev,"
            + "loginId:\(UserBean.sharedInstance.phoneNum!),"
            + "loginPass:dev"
        DevUtils.prints("施封-订阅-参数", cls: self, content: lockRss)
        mSocket.writeData(lockRss.dataUsingEncoding(NSUTF8StringEncoding), withTimeout: 5000, tag: 2)
        
        // 施封
        let lockeLock:NSString = "(Mobile)"
            + "Cmd:3,"
            + "ConnectionType:Socket,"
            + "GisCommVersionType:TCP_WebGIS,"
            + "GisID:Android_GIS,"
            + "SubcribeCommunicateIdArr:\(UserBean.sharedInstance.elockNum!),"
            + "SubcribleFlag:true,"
            + "UserName:dev,"
            + "actionType:施封,"
            + "keyPass:\(self.mElockPassword),"
            + "loginId:\(UserBean.sharedInstance.phoneNum!)"
        DevUtils.prints("施封-施封-参数", cls: self, content: lockeLock)
        mSocket.writeData(lockeLock.dataUsingEncoding(NSUTF8StringEncoding), withTimeout: 5000, tag: 3)
    }
    
    func submitLockData() {
        dispatch_async(dispatch_get_main_queue()) { 
            ToastHub.sharedInstance.hideHub()
        }

        let jsonDict:JSON = [
            "ROId": (mFormModel?.mainId!)!, // 订单主键
            "GOId": (mFormModel?.goodsId)!, // 货主ID
            "ROLockPicture": self.mImageNameCameraLock, // 施封照片
            "COPassword": self.mElockPassword // 施封密码
        ]
        DevUtils.prints("拍照施封-参数", cls: self, content: jsonDict.description)
        let params = ["jo":jsonDict.description]
        Alamofire.request(.POST, ApiContants.URL_POST_FORM_CAMERA_LOCK, parameters: params).responseJSON { (result) in
            DevUtils.prints("拍照施封-返回值", cls: self, content: result.description)
            if result.result.isFailure{
                ToastHub.sharedInstance.showHubWithText(self.view, text: "网络异常,请重试")
                return
            }
            
            if let resultValue = result.result.value{
                let resultCode:Int = JSON(resultValue)["resultSign"].int!
                if (resultCode == 1) { // 施封成功
                    ToastHub.sharedInstance.showHubWithText(self.view, text: "施封成功")
                    self.navigationController?.popViewControllerAnimated(true)
                }else{ // 未知状态
                    ToastHub.sharedInstance.showHubWithText(self.view, text: "未知状态")
                }
            }
        }
    }
    
    func socket(sock: GCDAsyncSocket!, didReadData data: NSData!, withTag tag: Int){
        if (tag == 1) {
            DevUtils.prints("施封-登录-返回值", cls: self, content: NSString(data: data, encoding: NSUTF8StringEncoding)!)
            self.lockRssWithLock()
        }else if (tag == 2){
            DevUtils.prints("施封-订阅-返回值", cls: self, content: NSString(data: data, encoding: NSUTF8StringEncoding)!)
            if let socketResult = NSString(data: data, encoding: NSUTF8StringEncoding) {
                if socketResult.containsString("resultByteStr\":\"80") { // 施封成功
                    sock.disconnect()
                    self.submitLockData()
                }else if socketResult.containsString("resultByteStr\":\"81") { // 重复施封
                    sock.disconnect()
                    dispatch_async(dispatch_get_main_queue()) {
                        ToastHub.sharedInstance.hideHub()
                        ToastHub.sharedInstance.showHubWithText(self.view, text: "重复施封")
                    }
                }else if socketResult.containsString("resultByteStr\":\"82") { // 锁未插好，施封失败
                    sock.disconnect()
                    dispatch_async(dispatch_get_main_queue()) {
                        ToastHub.sharedInstance.hideHub()
                        ToastHub.sharedInstance.showHubWithText(self.view, text: "锁未插好，施封失败")
                    }
                }else if socketResult.containsString("resultByteStr\":\"83") { // 电压过低，不能施封
                    sock.disconnect()
                    dispatch_async(dispatch_get_main_queue()) {
                        ToastHub.sharedInstance.hideHub()
                        ToastHub.sharedInstance.showHubWithText(self.view, text: "电压过低，不能施封")
                    }
                }else if socketResult.containsString("resultByteStr\":\"84") { // 锁异常：非法拆壳，不予施封
                    sock.disconnect()
                    dispatch_async(dispatch_get_main_queue()) {
                        ToastHub.sharedInstance.hideHub()
                        ToastHub.sharedInstance.showHubWithText(self.view, text: "锁异常：非法拆壳，不予施封")
                    }
                }else if socketResult.containsString("resultByteStr\":\"85") { // 锁异常：应急开锁，不予施封
                    sock.disconnect()
                    dispatch_async(dispatch_get_main_queue()) {
                        ToastHub.sharedInstance.hideHub()
                        ToastHub.sharedInstance.showHubWithText(self.view, text: "锁异常：应急开锁，不予施封")
                    }
                }else if socketResult.containsString("resultByteStr\":\"86") { // 锁杆剪断报警，不予施封
                    sock.disconnect()
                    dispatch_async(dispatch_get_main_queue()) {
                        ToastHub.sharedInstance.hideHub()
                        ToastHub.sharedInstance.showHubWithText(self.view, text: "锁杆剪断报警，不予施封")
                    }
                }else if socketResult.containsString("resultByteStr\":\"87") { // 锁杆打开报警，不予施封
                    sock.disconnect()
                    dispatch_async(dispatch_get_main_queue()) {
                        ToastHub.sharedInstance.hideHub()
                        ToastHub.sharedInstance.showHubWithText(self.view, text: "锁杆打开报警，不予施封")
                    }
                }else if socketResult.containsString("resultByteStr\":\"89") { // 施封超时
                    sock.disconnect()
                    dispatch_async(dispatch_get_main_queue()) {
                        ToastHub.sharedInstance.hideHub()
                        ToastHub.sharedInstance.showHubWithText(self.view, text: "施封超时")
                    }
                }else{ // 施封失败，继续接收数据
                    sock.readDataWithTimeout(-1, tag: 2)
                }
            }
        }else{
            DevUtils.prints("施封-未知-返回值", cls: self, content: "<\(tag)>\(NSString(data: data, encoding: NSUTF8StringEncoding)!)")
        }
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.00001
    }
}
