//
//  AutCarView.swift
//  eLahuoForCar
//
//  Created by IceHan on 16/3/30.
//  Copyright © 2016年 elahuo.net. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class AutCarView: BaseAutTableViewController, QRCodeDelegate {
    
    @IBOutlet weak var mTfVehicleNum: UITextField! // 车牌号
    @IBOutlet weak var mTfVehicleLevel: UITextField! // 车辆级别
    @IBOutlet weak var mSwTailBoard: UIButton! // 尾板
    @IBOutlet weak var mSwSlideDoor: UIButton! // 侧门
    @IBOutlet weak var mIvVehicleHead: UIImageView! // 车头照
    @IBOutlet weak var mIvVehicleTail: UIImageView! // 车尾照
    @IBOutlet weak var mIvTravel: UIImageView! // 行驶证
    @IBOutlet weak var mTfElockNum: UITextField! // 电子锁编号
    @IBOutlet weak var mTfElockNumBtn: UIButton! // 电子锁编号按钮
    
    @IBOutlet weak var mBtnVehicleLevel: UIButton! // 选择车辆级别
    @IBOutlet weak var mBtnVehicleHead: UIButton! // 车头拍照
    @IBOutlet weak var mBtnVehicleTail: UIButton! // 车尾拍照
    @IBOutlet weak var mBtnTravel: UIButton! // 行驶证拍照
    
    private var mImageNameHead:String!
    private var mImageNameTail:String!
    private var mImageNameTravel:String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 加载数据
        self.loadAutData()
        
        // 图片名称
        mImageNameHead = "COCHeadPicture\(UserBean.sharedInstance.userId).jpg"
        mImageNameTail = "COCTailPicture\(UserBean.sharedInstance.userId).jpg"
        mImageNameTravel = "COCXSZPicture\(UserBean.sharedInstance.userId).jpg"
        
        // 审核通过，不可修改
        if let isFinishAutCar = UserBean.sharedInstance.isFinishAutCar {
            if isFinishAutCar == true {
                mTfVehicleNum.enabled = false
                mTfVehicleLevel.enabled = false
                mBtnVehicleLevel.enabled = false
                mSwTailBoard.userInteractionEnabled = false
                mSwSlideDoor.userInteractionEnabled = false
                mBtnVehicleHead.enabled = false
                mBtnVehicleHead.hidden = true
                mBtnVehicleTail.enabled = false
                mBtnVehicleTail.hidden = true
                mBtnTravel.enabled = false
                mBtnTravel.hidden = true
                mTfElockNum.enabled = false
                mTfElockNumBtn.enabled = false
                // 提交按钮不可点击,且文字颜色变为灰色
                self.navigationItem.rightBarButtonItem?.enabled = false
                var notClickAttrs: [NSObject : AnyObject] = NSMutableDictionary() as [NSObject : AnyObject]
                notClickAttrs[NSForegroundColorAttributeName] = UIColor.grayColor()
                self.navigationItem.rightBarButtonItem?.setTitleTextAttributes(notClickAttrs as? [String : AnyObject], forState: .Normal)
            } else {
                mTfVehicleNum.enabled = true
                mTfVehicleLevel.enabled = true
                mBtnVehicleLevel.enabled = true
                mSwTailBoard.userInteractionEnabled = true
                mSwSlideDoor.userInteractionEnabled = true
                mBtnVehicleHead.enabled = true
                mBtnVehicleHead.hidden = false
                mBtnVehicleTail.enabled = true
                mBtnVehicleTail.hidden = false
                mBtnTravel.enabled = true
                mBtnTravel.hidden = false
                mTfElockNum.enabled = true
                mTfElockNumBtn.enabled = true
                // 提交按钮可点击
                self.navigationItem.rightBarButtonItem?.enabled = true
                var notClickAttrs: [NSObject : AnyObject] = NSMutableDictionary() as [NSObject : AnyObject]
                notClickAttrs[NSForegroundColorAttributeName] = UIColor(red: 29.0 / 255.0, green: 154.0 / 255.0, blue: 115.0 / 255.0, alpha: 1.0)
                self.navigationItem.rightBarButtonItem?.setTitleTextAttributes(notClickAttrs as? [String : AnyObject], forState: .Normal)
            }
        }
        
        
    }

    

    
    // 加载数据
    func loadAutData() {
        // 获取本地数据
        let userDefaults = NSUserDefaults.standardUserDefaults()
        let carNumber = userDefaults.stringForKey("COCPlateNumber") // 车牌号
        let carLevel = userDefaults.stringForKey("COCLevel") // 车辆级别
        let tailBoard = userDefaults.stringForKey("COCIsWB") // 尾板
        let slideDoor = userDefaults.stringForKey("COCCMNum") // 侧门
        let elockNumber = userDefaults.stringForKey("carGIS") // 电子锁ID
        
        let cachesPath = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true).first
        
        let carHeadImagePath = NSString(string: cachesPath!).stringByAppendingPathComponent("COCHeadPicture\(UserBean.sharedInstance.userId).jpg") // 车头图片路径
        let carHeadImage = UIImage(contentsOfFile: carHeadImagePath) // 车头照片
        
        let carTailImagePath = NSString(string: cachesPath!).stringByAppendingPathComponent("COCTailPicture\(UserBean.sharedInstance.userId).jpg") // 车尾图片路径
        let carTailImage = UIImage(contentsOfFile: carTailImagePath) // 车尾照片
        
        let travelLicenseImagePath = NSString(string: cachesPath!).stringByAppendingPathComponent("COCXSZPicture\(UserBean.sharedInstance.userId).jpg") // 行驶证图片路径
        let travelLicenseImage = UIImage(contentsOfFile: travelLicenseImagePath) // 行驶证照片
        
        
        if carNumber != nil && carLevel != nil && tailBoard != nil && slideDoor != nil && elockNumber != nil && carHeadImage != nil && carTailImage != nil && travelLicenseImage != nil {
            // 本地有数据,从本地加载数据
            self.mTfVehicleNum.text = carNumber
            self.mTfVehicleLevel.text = MapConstants.sharedInstance.keyConvertValue(Int(carLevel!)!, converType: TextSelectorType.VehicleLevel)
            self.mSwTailBoard.selected = (tailBoard == "1" ? true : false)
            self.mSwSlideDoor.selected = (slideDoor == "1" ? true : false)
            self.mTfElockNum.text = elockNumber
            self.mIvVehicleHead.image = carHeadImage
            self.mIvVehicleTail.image = carTailImage
            self.mIvTravel.image = travelLicenseImage
            
        } else {
            ToastHub.sharedInstance.showHubWithLoad(self.view, text: "加载数据中...")
            let jsonDict:JSON = [
                "COId": UserBean.sharedInstance.userId
            ]
            
            let params = ["jo": jsonDict.description]
            Alamofire.request(.GET, ApiContants.URL_GET_AUT_CAR, parameters: params).responseJSON { (result) in
                DevUtils.prints("加载车辆认证", cls: self, content: result.description)
                ToastHub.sharedInstance.hideHub()
                if let resultValue = result.result.value{
                    //                if let vehicleId = JSON(resultValue)["p_COCID"].string { // 车辆ID
                    //                }
                    if let vehileNum = JSON(resultValue)["COCPlateNumber"].string { // 车牌号
                        self.mTfVehicleNum.text = vehileNum
                        
                        userDefaults.setObject(vehileNum, forKey: "COCPlateNumber")
                    }
                    if let vehileLevel = JSON(resultValue)["COCLevel"].string { // 车辆级别
                        self.mTfVehicleLevel.text = MapConstants.sharedInstance.keyConvertValue(Int(vehileLevel)!, converType: TextSelectorType.VehicleLevel)
                        self.tableView.reloadData()
                        userDefaults.setObject(vehileLevel, forKey: "COCLevel")
                    }
                    if let tailBoard = JSON(resultValue)["COCIsWB"].string { // 尾板
                        self.mSwTailBoard.selected = (tailBoard == "1" ? true : false)
                        
                        userDefaults.setObject(tailBoard, forKey: "COCIsWB")
                    }
                    if let slideDoor = JSON(resultValue)["COCCMNum"].string{ // 侧门
                        self.mSwSlideDoor.selected = (slideDoor == "1" ? true : false)
                        
                        userDefaults.setObject(slideDoor, forKey: "COCCMNum")
                    }
                    if let vehicleHeadImg = JSON(resultValue)["COCHeadPicture"].string { // 车头照
                        let imgUrl = ApiContants.URL_GET_IMAGE + "?imageBNType=COCHeadPicture&imageFileName=" + vehicleHeadImg
                        DevUtils.prints("车头照URL", cls: self, content: imgUrl)
                        let carHeadImageData = NSData(contentsOfURL: NSURL(string: imgUrl)!)
                        self.mIvVehicleHead.image = UIImage(data: carHeadImageData!)
                        
                        carHeadImageData?.writeToFile(carHeadImagePath, atomically: true)
                        
                    }
                    if let vehileTailImg = JSON(resultValue)["COCTailPicture"].string { // 车尾照
                        let imgUrl = ApiContants.URL_GET_IMAGE + "?imageBNType=COCTailPicture&imageFileName=" + vehileTailImg
                        DevUtils.prints("车尾照URL", cls: self, content: imgUrl)
                        let cartailImageData = NSData(contentsOfURL: NSURL(string: imgUrl)!)
                        self.mIvVehicleTail.image = UIImage(data: cartailImageData!)
                        
                        cartailImageData?.writeToFile(carTailImagePath, atomically: true)
                        
                    }
                    if let travelImg = JSON(resultValue)["COCXSZPicture"].string { // 行驶证照片
                        let imgUrl = ApiContants.URL_GET_IMAGE + "?imageBNType=COCXSZPicture&imageFileName=" + travelImg
                        DevUtils.prints("行驶证照片URL", cls: self, content: imgUrl)
                        let travelData = NSData(contentsOfURL: NSURL(string: imgUrl)!)
                        self.mIvTravel.image = UIImage(data: travelData!)
                        
                        travelData?.writeToFile(travelLicenseImagePath, atomically: true)
                        
                    }
                    if let elockNumArr = JSON(resultValue)["carGIS"].array { // 电子锁编码
                        if let elockNum = elockNumArr[0]["COMMCODE"].string{
                            self.mTfElockNum.text = elockNum
                            
                            userDefaults.setObject(elockNum, forKey: "carGIS")
                        }
                    }
                    
                }
            }
        }
        
        
    }
    
    // 尾板是否选中
    @IBAction func tailBoard(sender: UIButton) {
       sender.selected = !sender.selected
    }
    
    // 侧门是否选中
    @IBAction func slideDoor(sender: UIButton) {
        sender.selected = !sender.selected
    }
    
    // 选中车辆级别
    @IBAction func actionVehicleLevel(sender: UIButton) {
        openTextSelector(mTfVehicleLevel, selectorType: TextSelectorType.VehicleLevel)
    }
    
    // 拍照：车头
    @IBAction func actionVehicleHeadCamera(sender: UIButton) {
        // 启动相机
        openImageController(mIvVehicleHead, imageName: "COCHeadPicture\(UserBean.sharedInstance.userId).jpg")
    }
    
    // 拍照：车尾
    @IBAction func actionVehicleTailCamera(sender: UIButton) {
        // 启动相机
        openImageController(mIvVehicleTail, imageName: "COCTailPicture\(UserBean.sharedInstance.userId).jpg")
    }
    
    // 拍照：行驶证
    @IBAction func actionTravelCamera(sender: UIButton) {
        // 启动相机
        openImageController(mIvTravel, imageName: "COCXSZPicture\(UserBean.sharedInstance.userId).jpg")
    }
    
    // 扫描条形码
    @IBAction func scanBarCode(sender: UIButton) {
        // 跳转到扫码界面
        let QRCodeVC: QRCodeViewController = UIStoryboard(name: "QRCodeViewController", bundle: nil).instantiateInitialViewController()! as! QRCodeViewController
        
        QRCodeVC.delegate = self
        
        navigationController?.pushViewController(QRCodeVC, animated: true)
    }
    
    /**
     扫描条形码返回扫描结果
     */
    func didScanResults(result: String) {
        DevUtils.prints(self, content: "mTfElockNum\(result)")
        if !result.isEmpty {
            mTfElockNum.text = result
        } else {
            mTfElockNum.text = nil
        }
    }
    
    // 提交认证信息
    @IBAction func actionSubmitActData(sender: UIBarButtonItem) {
        // 退出键盘
        mTfVehicleNum.resignFirstResponder()
        
        // 提交前的逻辑判断
        if mTfVehicleLevel.text == "面包车" {
            if !(mTfVehicleNum.text!.isEmpty) && !(mTfVehicleLevel.text!.isEmpty) && mIvVehicleHead.image != nil && mIvVehicleTail.image != nil && mIvTravel.image != nil {
                // 提交数据
                let jsonDict:JSON = [
                    "p_COID": UserBean.sharedInstance.userId, // 车主Id
                    "p_COCPLATENUMBER": mTfVehicleNum.text!, // 车牌号
                    "p_COCXSZPICTURE": mImageNameTravel, // 行驶证照片
                    "p_COCHEADPICTURE": mImageNameHead, // 车头照
                    "p_COCTAILPICTURE": mImageNameTail, // 车尾照
                    "p_COCLEVEL": MapConstants.sharedInstance.valueConvertKey(mTfVehicleLevel.text!, converType: TextSelectorType.VehicleLevel), // 车辆级别
                    "p_COCISWB": (mSwTailBoard.selected == true ? 1 : 0), // 尾板
                    "p_COCCMNUM": (mSwSlideDoor.selected == true ? 1 : 0), // 侧门
                    "p_COMMCODE": "", // 电子锁编码
                    "p_CGZF": 0 // 主副锁
                ]
                DevUtils.prints("车辆认证-参数", cls: self, content: jsonDict.description)
                let params = ["jo": jsonDict.description]
                Alamofire.request(.POST, ApiContants.URL_POST_AUT_CAR, parameters: params).responseJSON { (result) in
                    DevUtils.prints("车辆认证-返回值", cls: self, content: result.description)
                    if result.result.isFailure{
                        ToastHub.sharedInstance.showHubWithText(self.view, text: "网络异常,请重试")
                        return
                    }
                    
                    if let resultValue = result.result.value{
                        let resultCode:String = JSON(resultValue)["resultSign"].string!
                        if (resultCode == "-1") { // 数据接收失败
                            ToastHub.sharedInstance.showHubWithText(self.view, text: "数据接收失败")
                        }else if(resultCode == "1"){ // 数据提交成功，待审核
                            ToastHub.sharedInstance.showHubWithText(self.view, text: "提交数据成功,等待审核")
                            
                            
                            // 保存数据到本地
                            let userDefaults = NSUserDefaults.standardUserDefaults()
                            userDefaults.setObject(self.mTfVehicleNum.text, forKey: "COCPlateNumber") // 车牌号
                            userDefaults.setObject(MapConstants.sharedInstance.valueConvertKey(self.mTfVehicleLevel.text!, converType: TextSelectorType.VehicleLevel), forKey: "COCLevel") // 车辆级别
                            userDefaults.setObject((self.mSwTailBoard.selected == true ? 1 : 0), forKey: "COCIsWB") // 尾板
                            userDefaults.setObject((self.mSwSlideDoor.selected == true ? 1 : 0), forKey: "COCCMNum") // 侧门
                            
                            
                        }else if(resultCode == "2"){ // 数据提交成功，待审核
                            ToastHub.sharedInstance.showHubWithText(self.view, text: "车牌号已被注册,请联系客服")
                        }else if(resultCode == "8"){ // 中心未注册该终端，请联系客服
                            ToastHub.sharedInstance.showHubWithText(self.view, text: "中心未注册该终端，请联系客服")
                        }else if(resultCode == "9"){ // 电子锁已经被绑定车辆
                            ToastHub.sharedInstance.showHubWithText(self.view, text: "电子锁已经被绑定车辆")
                        }else{ // 未知状态
                            ToastHub.sharedInstance.showHubWithText(self.view, text: "未知状态")
                        }
                    }
                }
            } else {
                ToastHub.sharedInstance.showHubWithText(self.view, text: "请您填写所有内容")
                return
            }
        } else {
            if !(mTfVehicleNum.text!.isEmpty) && !(mTfVehicleLevel.text!.isEmpty) && mIvVehicleHead.image != nil && mIvVehicleTail.image != nil && mIvTravel.image != nil && !(mTfElockNum.text!.isEmpty) {
                // 提交数据
                let jsonDict:JSON = [
                    "p_COID": UserBean.sharedInstance.userId, // 车主Id
                    "p_COCPLATENUMBER": mTfVehicleNum.text!, // 车牌号
                    "p_COCXSZPICTURE": mImageNameTravel, // 行驶证照片
                    "p_COCHEADPICTURE": mImageNameHead, // 车头照
                    "p_COCTAILPICTURE": mImageNameTail, // 车尾照
                    "p_COCLEVEL": MapConstants.sharedInstance.valueConvertKey(mTfVehicleLevel.text!, converType: TextSelectorType.VehicleLevel), // 车辆级别
                    "p_COCISWB": (mSwTailBoard.selected == true ? 1 : 0), // 尾板
                    "p_COCCMNUM": (mSwSlideDoor.selected == true ? 1 : 0), // 侧门
                    "p_COMMCODE": mTfElockNum.text!, // 电子锁编码
                    "p_CGZF": 0 // 主副锁
                ]
                DevUtils.prints("车辆认证-参数", cls: self, content: jsonDict.description)
                let params = ["jo": jsonDict.description]
                Alamofire.request(.POST, ApiContants.URL_POST_AUT_CAR, parameters: params).responseJSON { (result) in
                    DevUtils.prints("车辆认证-返回值", cls: self, content: result.description)
                    if result.result.isFailure{
                        ToastHub.sharedInstance.showHubWithText(self.view, text: "网络异常,请重试")
                        return
                    }
                    
                    if let resultValue = result.result.value{
                        let resultCode:String = JSON(resultValue)["resultSign"].string!
                        if (resultCode == "-1") { // 数据接收失败
                            ToastHub.sharedInstance.showHubWithText(self.view, text: "数据接收失败")
                        }else if(resultCode == "1"){ // 数据提交成功，待审核
                            ToastHub.sharedInstance.showHubWithText(self.view, text: "提交数据成功,等待审核")
                            
                            
                            // 保存数据到本地
                            let userDefaults = NSUserDefaults.standardUserDefaults()
                            userDefaults.setObject(self.mTfVehicleNum.text, forKey: "COCPlateNumber") // 车牌号
                            userDefaults.setObject(MapConstants.sharedInstance.valueConvertKey(self.mTfVehicleLevel.text!, converType: TextSelectorType.VehicleLevel), forKey: "COCLevel") // 车辆级别
                            userDefaults.setObject((self.mSwTailBoard.selected == true ? 1 : 0), forKey: "COCIsWB") // 尾板
                            userDefaults.setObject((self.mSwSlideDoor.selected == true ? 1 : 0), forKey: "COCCMNum") // 侧门
                            userDefaults.setObject(self.mTfElockNum.text!, forKey: "carGIS") // 电子锁ID
                            
                        }else if(resultCode == "2"){ // 数据提交成功，待审核
                            ToastHub.sharedInstance.showHubWithText(self.view, text: "车牌号已被注册,请联系客服")
                        }else if(resultCode == "8"){ // 中心未注册该终端，请联系客服
                            ToastHub.sharedInstance.showHubWithText(self.view, text: "中心未注册该终端，请联系客服")
                        }else if(resultCode == "9"){ // 电子锁已经被绑定车辆
                            ToastHub.sharedInstance.showHubWithText(self.view, text: "电子锁已经被绑定车辆")
                        }else{ // 未知状态
                            ToastHub.sharedInstance.showHubWithText(self.view, text: "未知状态")
                        }
                    }
                }
            } else {
                ToastHub.sharedInstance.showHubWithText(self.view, text: "请您填写所有内容")
                return
            }
        }
        
        
        
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if let carLevel = NSUserDefaults.standardUserDefaults().stringForKey("COCLevel") {
            if carLevel == "10" {
                return 2
            } else {
                return 3
            }
        } else {
            return 3
        }
        
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 10
    }
    
    override func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        self.view.endEditing(true)
    }
}
