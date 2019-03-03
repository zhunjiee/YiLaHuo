//
//  MainView.swift
//  eLahuoForCar
//
//  Created by IceHan on 16/3/30.
//  Copyright © 2016年 elahuo.net. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import MJRefresh
import CocoaAsyncSocket

class MainView: BaseTableViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    private var mTableGroups:Array<TableGroup> = Array<TableGroup>()
    private var mTableGroupNot = TableGroup(tag: 0, name: "可接订单", isExpand: true)
    private var mTableGroupIng = TableGroup(tag: 1, name: "已报价订单", isExpand: false)
    private var mTableGroupEnd = TableGroup(tag: 2, name: "已接订单", isExpand: false)
    
    private var mImagePicker:UIImagePickerController? // 照片选择器
    private var cameraLock:CameraLock? // 施封界面
    private var linkLoadBtnTag: Int? // 联系装货人tag
    private var linkUnloadBtnTag: Int? // 联系收货人tag
    private var redPointImageView: UIImageView? // 小红点视图
    
    
    
    //MARK: - 初始化
    override func viewDidLoad() {
        super.viewDidLoad()
        // 自动登录
        if let phoneNum = UserBean.sharedInstance.phoneNum {
            ChildLoginTableViewController.userLogin(self, phoneNum: phoneNum, isAutoLogin: true, isDismiss: false )
        }
        
        // 初始化导航栏
        self.setUpNav()
        // 注册通知
        self.registerNotification()
        
        // 组
        mTableGroups = [self.mTableGroupNot, self.mTableGroupIng, self.mTableGroupEnd]
        
        // 自动更新
        NSTimer.scheduledTimerWithTimeInterval(60 * 5, target: self, selector: #selector(MainView.loadFormWithAll), userInfo: nil, repeats: true)
        
    }
    

    
    /**
     设置导航栏内容
     */
    func setUpNav() {
        self.navigationItem.titleView = UIImageView(image: UIImage(named: "logo_title"))
        // 设置菜单按钮图片
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "icon_nav_head"), style: .Plain, target: self, action: #selector(actionNavLeftBtn))
        if UserBean.sharedInstance.isLoging() == false {
            self.navigationItem.leftBarButtonItem?.tintColor = UIColor.lightGrayColor()
        } else {
            self.navigationItem.leftBarButtonItem?.tintColor = UIColor(red: 29.0 / 255.0, green: 154.0 / 255.0, blue: 115.0 / 255.0, alpha: 0.9)
        }
    }
    
    //MARK: - 通知相关
    /**
     注册通知
     */
    func registerNotification() {
        // 注册成功
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(registerSuccess), name: NotificationConstants.RegisterSuccessNotification, object: nil)
        // 登录成功
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(loginSuccess), name: NotificationConstants.LoginSuccessNotification, object: nil)
        // 退出登录
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(logoutSuccess), name: NotificationConstants.LogoutSuccessNotification, object: nil)
        // 有新订单
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(haveNewOrder), name: NotificationConstants.HaveNewOrderNotification, object: nil)
        // 货主取消订单
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(cancelOrder), name: NotificationConstants.CancelOrderNotification, object: nil)
        // 强制登出
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(jumpToLoginView), name: NotificationConstants.ForceLogoutNotification, object: nil)
        
    }
    
    
    
    /**
     跳转到登录界面
     */
    func jumpToLoginView() {
        let loginView = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("LoginView")
        let navigationVC = BaseNavigationController(rootViewController: loginView)
        
        self.navigationController?.presentViewController(navigationVC, animated: true, completion: nil)
    }
    /**
     有新订单
     */
    func haveNewOrder() {
        // 显示小红点
        redPointImageView?.hidden = false
    }
    /**
     货主取消订单
     */
    func cancelOrder() {
        // 刷新数据
        self.loadFormWithAll()
    }
    /**
     注册成功
     */
    func registerSuccess() {
        if let phoneNum = UserBean.sharedInstance.phoneNum {
            ChildLoginTableViewController.userLogin(self, phoneNum: phoneNum, isAutoLogin: true, isDismiss: false)
        }
    }
    /**
     点击左侧菜单
     */
    func actionNavLeftBtn() {
        self.slideMenuController()?.openLeft()
    }
    /**
     登录成功
     */
    func loginSuccess() {
        self.navigationItem.leftBarButtonItem?.tintColor = UIColor(red: 29.0 / 255.0, green: 154.0 / 255.0, blue: 115.0 / 255.0, alpha: 0.9)
        // 刷新数据
        self.setUpRefresh()
    }
    /**
     退出登录
     */
    func logoutSuccess() {
        self.navigationItem.leftBarButtonItem?.tintColor = UIColor.lightGrayColor()
        // 重新加载数据
        self.loadFormWithAll()
    }

    
    
    
    //MARK: - 加载数据
    func setUpRefresh() {
        // 下拉刷新
        self.tableView.mj_header = MJRefreshNormalHeader.init(refreshingTarget: self, refreshingAction: #selector(MainView.loadFormWithAll))
        self.tableView.mj_header.beginRefreshing()
        self.tableView.mj_header.automaticallyChangeAlpha = true
    }
    
    /**
     加载数据
     */
    func loadFormWithAll() {
        loadFormModelWithNot()
        loadFormModelWithIng()
        loadFormModelWithEnd()
        
        if UserBean.sharedInstance.isLoging() == false {
            self.tableView.mj_header = nil
        }
    }
    
    private func loadFormModelWithNot() { // 可接订单
        if UserBean.sharedInstance.isLoging() { // 已登录
            let jsonDict:JSON = ["COId": UserBean.sharedInstance.userId]
//            DevUtils.prints("可接订单-参数", cls: self, content: jsonDict.description)
            let params = ["jo": jsonDict.description]
            Alamofire.request(.GET, ApiContants.URL_GET_FORM_NOT, parameters: params).responseJSON { (result) in
                DevUtils.prints("可接订单-返回值", cls: self, content: result.description)
                if let resultValue = result.result.value {
                    self.mTableGroupNot.formModels = self.formJsonArrToForms(resultValue)
                    self.tableView.reloadData()
                    self.tableView.mj_header.endRefreshing()
                    if self.redPointImageView?.hidden == false {
                        self.redPointImageView?.hidden = true
                    }
                }
            }
        } else { //未登录
            self.mTableGroupNot.formModels = nil
//            self.mTableGroupNot = TableGroup(tag: 0, name: "可接订单", isExpand: false)
            self.tableView.reloadData()
        }
        
    }
    private func loadFormModelWithIng() { // 已报价订单
        if UserBean.sharedInstance.isLoging() {
            let jsonDict:JSON = ["COId": UserBean.sharedInstance.userId]
//            DevUtils.prints("已报价订单-参数", cls: self, content: jsonDict.description)
            let params = ["jo": jsonDict.description]
            Alamofire.request(.GET, ApiContants.URL_GET_FORM_ING, parameters: params).responseJSON { (result) in
                DevUtils.prints("已报价订单-返回值", cls: self, content: result.description)
                if let resultValue = result.result.value {
                    self.mTableGroupIng.formModels = self.formJsonArrToForms(resultValue)
                    self.tableView.reloadData()
                    self.tableView.mj_header.endRefreshing()
                }
            }
        } else {
            self.mTableGroupIng.formModels = nil
//            self.mTableGroupIng = TableGroup(tag: 1, name: "已报价订单", isExpand: false)
            self.tableView.reloadData()
        }
        
    }
    private func loadFormModelWithEnd() { // 已接订单
        if UserBean.sharedInstance.isLoging() {
            let jsonDict:JSON = ["COId": UserBean.sharedInstance.userId]
//            DevUtils.prints("已接订单-参数", cls: self, content: jsonDict.description)
            let params = ["jo": jsonDict.description]
            Alamofire.request(.GET, ApiContants.URL_GET_FORM_END, parameters: params).responseJSON { (result) in
                DevUtils.prints("已接订单-返回值", cls: self, content: result.description)
                if let resultValue = result.result.value {
                    self.mTableGroupEnd.formModels = self.formJsonArrToForms(resultValue)
                    self.tableView.reloadData()
                    self.tableView.mj_header.endRefreshing()
                }
            }
        } else {
            self.mTableGroupEnd.formModels = nil
//            self.mTableGroupEnd = TableGroup(tag: 2, name: "已接订单", isExpand: false)
            self.tableView.reloadData()
        }
        
    }
    
    //MARK: - Table Data Source
    // 组数
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return mTableGroups.count
    }
    
    // 行数
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let tableGroup:TableGroup = mTableGroups[section]
        
        if tableGroup.isExpand! {
            if let formModels = tableGroup.formModels{
                return formModels.count
            }
        }
        return 0
    }
    // 行高度
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat{
        let tableGroup:TableGroup = mTableGroups[indexPath.section]
        if tableGroup.tag == mTableGroupNot.tag {
            return 122
        }
        return 145
    }
    
    // 行内容
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("TableContentAll", forIndexPath: indexPath)
        
        let lbTime:UILabel = cell.viewWithTag(1001) as! UILabel // 订单时间
        let lbPrice:UILabel = cell.viewWithTag(1002) as! UILabel // 订单报价
        let vBtnSubmitOrCancelPrice:UIView = cell.viewWithTag(1003)! // 取消报价
        let lbLoadAddress:UILabel = cell.viewWithTag(1004) as! UILabel // 装货地点
        let lbUnloadAddress:UILabel = cell.viewWithTag(1005) as! UILabel // 卸货地点
        let vVehicleInfoTop:UIView = cell.viewWithTag(1006)! // 里程view
        let vVehicleInfoBottom:UIView = cell.viewWithTag(1007)! // 车辆信息view
        let lbMiles:UILabel = cell.viewWithTag(1008) as! UILabel // 里程
        let lbTailBoardAndSlideDoor:UILabel = cell.viewWithTag(1009) as! UILabel // 尾板/侧门
        let lbVehicleLevel:UILabel = cell.viewWithTag(1010) as! UILabel // 车辆级别
        let orderNumLabel:UILabel = cell.viewWithTag(1011) as! UILabel // 订单编号
        let vBtnLoadLinkman:UIView = cell.viewWithTag(1012)! // 联系装货人view
        let linkLoadPhoneBtn: UIButton = cell.viewWithTag(1019) as! UIButton // 联系装货人btn
        let vBtnUnloadLinkman:UIView = cell.viewWithTag(1013)! // 联系卸货人view
        let linkUnLoadPhoneBtn: UIButton = cell.viewWithTag(1020) as! UIButton // 联系卸货人btn
        let vPriceInfo:UIView = cell.viewWithTag(1014)! // 平均报价等的view
        let lbPriceMax:UILabel = cell.viewWithTag(1015) as! UILabel // 最高报价
        let lbPriceMin:UILabel = cell.viewWithTag(1016) as! UILabel // 最低报价
        let lbPriceAverage:UILabel = cell.viewWithTag(1017) as! UILabel // 平均报价
        let lbPriceManNum:UILabel = cell.viewWithTag(1018) as! UILabel // 报价人数
        
        let tableGroup:TableGroup = self.mTableGroups[indexPath.section]
        
        if let formModels = tableGroup.formModels {
            let formModel:FormModel = formModels[indexPath.row]
            if let formID = formModel.formId {
                orderNumLabel.text = "订单编号:\(formID)"
            } else {
                orderNumLabel.text = "订单编号:---"
            }
            if let formTime = formModel.loadTime {
                lbTime.text = formTime
            }else{
                lbTime.text = "_-_ _:_"
            }

            if let price = formModel.freePrice {
                lbPrice.text = String(format:"%.0f元", price)
            }else {
                if let price = formModel.dealPrice {
                    lbPrice.text = String(format:"%.0f元", price)
                }
            }
            
            lbLoadAddress.text = formModel.loadAddress
            lbUnloadAddress.text = formModel.unloadAddress
            // 公里
            lbMiles.text = String(format: "%.0f公里", formModel.routeMiles!)
            // 尾板/侧门
            if formModel.tailBoard == true && formModel.slideDoor == true {
                lbTailBoardAndSlideDoor.text = "尾板/侧门"
            } else if formModel.tailBoard == true && formModel.slideDoor == false {
                lbTailBoardAndSlideDoor.text = "侧门"
            } else if formModel.tailBoard == false && formModel.slideDoor == true {
                lbTailBoardAndSlideDoor.text = "尾板"
            } else {
                lbTailBoardAndSlideDoor.text = ""
            }
            
            if let level = formModel.vehicleLevel{
                lbVehicleLevel.text = MapConstants.sharedInstance.keyConvertValue(Int(level), converType: TextSelectorType.VehicleLevel)
            }
            
            if let priceMax = formModel.freePriceMax {
                lbPriceMax.text = String(format:"最高价:%.0f元", Float(priceMax)!)
            }else{
                lbPriceMax.text = "最高价:-"
            }
            if let priceMin = formModel.freePriceMin {
                lbPriceMin.text = String(format:"最低价:%.0f元", Float(priceMin)!)
            }else{
                lbPriceMin.text = "最低价:-"
            }
            if let priceAverage = formModel.freePriceAverage {
                lbPriceAverage.text = String(format:"平均价:%.0f元", Float(priceAverage)!)
            }else{
                lbPriceAverage.text = "平均价:-"
            }
            if let priceManNum = formModel.freePriceManNum {
                lbPriceManNum.text = "人数:\(priceManNum)"
            }else{
                lbPriceManNum.text = "人数:-"
            }
            
        }
        
        let btnSubmit = UIButton(frame: CGRect(x: 0, y: 0, width: 80, height: 30))
        btnSubmit.setTitleColor(UIColor().hexStringToColor(ColorConstants.ThemeColorDarkGreen), forState: .Normal)
        btnSubmit.setBackgroundImage(UIImage(named: "icon_confirmButton"), forState: .Normal)
        btnSubmit.titleLabel?.font = UIFont.systemFontOfSize(15)
        btnSubmit.tag = indexPath.row
        
        // 可接订单
        if tableGroup.tag == self.mTableGroupNot.tag {
            self.viewsHidden([vBtnSubmitOrCancelPrice, vVehicleInfoTop, vVehicleInfoBottom], hidden: false) // 显示立即报价按钮
            self.viewsHidden([lbPrice, vBtnLoadLinkman, vBtnUnloadLinkman, vPriceInfo], hidden: true) // 隐藏其他按钮
            
            // 添加立即报价按钮
            btnSubmit.setTitle("立即报价", forState: .Normal)
            btnSubmit.addTarget(self, action: #selector(MainView.submitFreePrice(_:)), forControlEvents: .TouchUpInside)
            self.removeAllChildViews(vBtnSubmitOrCancelPrice)
            vBtnSubmitOrCancelPrice.addSubview(btnSubmit)
        }
        // 已报价订单
        if tableGroup.tag == self.mTableGroupIng.tag {
            self.viewsHidden([lbPrice, vBtnSubmitOrCancelPrice, vVehicleInfoTop, vVehicleInfoBottom, vPriceInfo], hidden: false)
            self.viewsHidden([vBtnLoadLinkman, vBtnUnloadLinkman], hidden: true)
            
            btnSubmit.setTitle("取消报价", forState: .Normal)
            btnSubmit.addTarget(self, action: #selector(MainView.submitCancelPrice(_:)), forControlEvents: .TouchUpInside)
            self.removeAllChildViews(vBtnSubmitOrCancelPrice)
            vBtnSubmitOrCancelPrice.addSubview(btnSubmit)
        }
        // 已接订单
        if tableGroup.tag == self.mTableGroupEnd.tag {

            self.viewsHidden([lbPrice, vBtnSubmitOrCancelPrice, vVehicleInfoTop, vBtnLoadLinkman, vBtnUnloadLinkman], hidden: false)
            self.viewsHidden([vVehicleInfoBottom, vPriceInfo], hidden: true)
            
            if let formModels = tableGroup.formModels {
                let formModel:FormModel = formModels[indexPath.row]
                
                if (formModel.statusCode == 5) {
                    // 确认送达在货主端
                    btnSubmit.setTitle("确认送达", forState: .Normal)
                    btnSubmit.addTarget(self, action: #selector(MainView.submitFormFinish(_:)), forControlEvents: .TouchUpInside)
                    self.removeAllChildViews(vBtnSubmitOrCancelPrice)
                    vBtnSubmitOrCancelPrice.addSubview(btnSubmit)
                    
                }else if(formModel.statusCode == 4){
                    if let COCLevel = NSUserDefaults.standardUserDefaults().stringForKey("COCLevel") {
                        if COCLevel == "10" {
                            btnSubmit.setTitle("拍照发货", forState: .Normal)
                        } else {
                            btnSubmit.setTitle("拍照施封", forState: .Normal)
                        }
                    }
                    
                    
                    
                    btnSubmit.addTarget(self, action: #selector(MainView.submitPhotoElock(_:)), forControlEvents: .TouchUpInside)
                    self.removeAllChildViews(vBtnSubmitOrCancelPrice)
                    vBtnSubmitOrCancelPrice.addSubview(btnSubmit)
                }
                
                // 联系发货人
                linkLoadBtnTag = indexPath.row
                linkLoadPhoneBtn.setTitle("联系发货人:\(formModel.loadLinkmanPhone!)", forState: .Normal)
                linkLoadPhoneBtn.addTarget(self, action: #selector(MainView.actionLoadLinkman(_:)), forControlEvents: .TouchUpInside)
                // 联系卸货人
                linkUnloadBtnTag = indexPath.row
                linkUnLoadPhoneBtn.setTitle("联系卸货人:\(formModel.unloadLinkmanPhone!)", forState: .Normal)
                linkUnLoadPhoneBtn.addTarget(self, action: #selector(MainView.actionUnloadLinkman(_:)), forControlEvents: .TouchUpInside)
            }
            
            
        }
        
        return cell
    }
    
    // 立即报价
    func submitFreePrice(sender:UIButton) {
        if (!UserBean.sharedInstance.isFinishAutRealName) || (!UserBean.sharedInstance.isFinishAutCar) {
            ToastHub.sharedInstance.showHubWithText(self.view, text: "请您先完成车主认证和车辆认证")
            return
        }
        
        let index:Int = sender.tag
        if let fModels = mTableGroupNot.formModels {
            let formModel:FormModel? = fModels[index]
            
            let alertController = UIAlertController(title: "请输入报价", message: "", preferredStyle: .Alert)
            alertController.addTextFieldWithConfigurationHandler({ (textField) in
                textField.text = ""
                textField.keyboardType = .NumberPad
                textField.placeholder = "请输入报价"
                textField.addTarget(self, action: #selector(MainView.formFreePriceChange(_:)), forControlEvents: .EditingChanged)
            })
            alertController.addAction(UIAlertAction(title: "取消", style: .Cancel, handler: nil))
            alertController.addAction(UIAlertAction(title: "确认", style: .Default, handler: { (alertAction) in
                if (self.mFormFreePrice.isEmpty || self.mFormFreePrice == "0") {
                    ToastHub.sharedInstance.showHubWithText(self.view, text: "请输入一个有效的价格")
                    return
                } else if Int(self.mFormFreePrice) < 1 {
                    ToastHub.sharedInstance.showHubWithText(self.view, text: "金额必须大于1元")
                    return
                }
                
                let jsonDict:JSON = [
                    "COId": UserBean.sharedInstance.userId,
                    "GOId" : (formModel?.goodsId)!,
                    "ROBM": (formModel?.formId)!,
                    "Price": self.mFormFreePrice
                ]
//                DevUtils.prints("订单报价-参数", cls: self, content: jsonDict.description)
                let params = ["jo": jsonDict.description]
                Alamofire.request(.POST, ApiContants.URL_POST_FORM_SUBMIT_PRICE, parameters: params).responseJSON(completionHandler: { (result) in
//                    DevUtils.prints("订单报价-返回值", cls: self, content: result.description)
                    if let resultValue = result.result.value{
                        let resultCode:Int = JSON(resultValue)["resultSign"].int!
                        self.loadFormWithAll() // 重新加载所有订单
                        if (resultCode == -1) { // 服务器异常
                            ToastHub.sharedInstance.showHubWithText(self.view, text: "服务器异常")
                        }else if (resultCode == 1){ // 报价成功
                            ToastHub.sharedInstance.showHubWithText(self.view, text: "报价成功")
                        }else{ // 未知状态
                            ToastHub.sharedInstance.showHubWithText(self.view, text: "未知状态")
                        }
                    }
                })
                
            }))
            
            self.presentViewController(alertController, animated: true, completion: nil)
        }
    }
    private var mFormFreePrice = "0"
    func formFreePriceChange(sender:UITextField) {
        self.mFormFreePrice = sender.text!
    }
    
    // 取消报价
    func submitCancelPrice(sender:UIButton) {
        let index:Int = sender.tag
        if let fModels = mTableGroupIng.formModels {
            let formModel = fModels[index]
            
            let alertController = UIAlertController(title: "取消报价", message: "请确认是否取消报价", preferredStyle: .Alert)
            alertController.addAction(UIAlertAction(title: "取消", style: .Cancel, handler: nil))
            alertController.addAction(UIAlertAction(title: "确认", style: .Default, handler: { (alertAction) in
                let jsonDict:JSON = [
                    "OPId": formModel.priceId!,
                    "OPState": "0",
                    "GOId" : formModel.goodsId!,
                ]
//                DevUtils.prints("取消报价-参数", cls: self, content: jsonDict.description)
                let params = ["jo": jsonDict.description]
                Alamofire.request(.POST, ApiContants.URL_POST_FORM_CANCEL_PRICE, parameters: params).responseJSON(completionHandler: { (result) in
//                    DevUtils.prints("取消报价-返回值", cls: self, content: result.description)
                    
                    if let resultValue = result.result.value{
                        let resultCode:Int = JSON(resultValue)["resultSign"].int!
                        self.loadFormWithAll() // 重新加载所有订单
                        if (resultCode == -1) { // 服务器异常
                            ToastHub.sharedInstance.showHubWithText(self.view, text: "服务器异常")
                        }else if (resultCode == 1){ // 取消报价成功
                            ToastHub.sharedInstance.showHubWithText(self.view, text: "取消报价成功")
                        }else{ // 未知状态
                            ToastHub.sharedInstance.showHubWithText(self.view, text: "未知状态")
                        }
                    }
                })
                
            }))
            
            self.presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    // 联系发货人
    func actionLoadLinkman(sender:UIButton) {
        let index:Int = linkLoadBtnTag!
        if let fModels = mTableGroupEnd.formModels {
            let formModel = fModels[index]
            
            let telUrl = NSURL(string: "tel:\(formModel.loadLinkmanPhone!)")
            
//            DevUtils.prints("联系发货人", cls: self, content: (telUrl?.description)!)
            if UIApplication.sharedApplication().canOpenURL(telUrl!){
                UIApplication.sharedApplication().openURL(telUrl!)
            }
        }
    }
    
    // 联系卸货人
    func actionUnloadLinkman(sender:UIButton) {
        let index:Int = linkUnloadBtnTag!
        if let fModels = mTableGroupEnd.formModels {
            let formModel = fModels[index]
            
            let telUrl = NSURL(string: "tel:\(formModel.unloadLinkmanPhone!)")
            
//            DevUtils.prints("联系卸货人", cls: self, content: (telUrl?.description)!)
            if UIApplication.sharedApplication().canOpenURL(telUrl!){
                UIApplication.sharedApplication().openURL(telUrl!)
            }
        }
    }
    
    // 拍照施封
    private var mFormModel:FormModel? // 订单模型
    func submitPhotoElock(sender:UIButton) {
        // 创建照片选择器
        mImagePicker = UIImagePickerController()
        if UIImagePickerController.isSourceTypeAvailable(.Camera) {
            mImagePicker?.sourceType = .Camera
            //            mImagePicker?.allowsEditing = true
        }
        mImagePicker?.delegate = self
        
        // 启动相机
        self.presentViewController(mImagePicker!, animated: true, completion: nil)
        
        let index:Int = sender.tag
        if let fModels = mTableGroupEnd.formModels {
            mFormModel = fModels[index]
        }
    }
    
    var mImageNameCameraLock:String! // 施封照片名称
    private var mElockPassword:String! // 施封密码
    // 拍照完成的回调
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        let cameraLock: CameraLock = NSBundle.mainBundle().loadNibNamed("CameraLock", owner: nil, options: nil).first as! CameraLock
        cameraLock.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)
        
        if let COCLevel = NSUserDefaults.standardUserDefaults().stringForKey("COCLevel") {
            if COCLevel == "10" {
                cameraLock.commitButton.setTitle("确认发货", forState: .Normal)
            } else {
                cameraLock.commitButton.setTitle("确认施封", forState: .Normal)
            }
        }
        
        self.view.addSubview(cameraLock)
        self.cameraLock = cameraLock
        
        // 关闭施封界面
        cameraLock.closeButton.addTarget(self, action: #selector(closeCameraLockView), forControlEvents: .TouchUpInside)
        
        // 提交施封
        cameraLock.commitButton.addTarget(self, action: #selector(submitCameraLock), forControlEvents: .TouchUpInside)
        
        ToastHub.sharedInstance.showHubWithLoad(self.view, text: "照片处理中...")
        let originalImage:UIImage = info["UIImagePickerControllerOriginalImage"] as! UIImage
        
        mElockPassword = String(MathUtils.sharedInstance.random(100000, max: 999999))
        mImageNameCameraLock = "ROLockPicture\(UserBean.sharedInstance.userId)_\(mElockPassword).jpg"
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            
            // 图片保存到caches目录
            let cachesPath = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true).first
            let scaleImagePath = NSString(string: cachesPath!).stringByAppendingPathComponent("\(self.mImageNameCameraLock)")
            let scaleImageData = UIImageJPEGRepresentation(originalImage, 0.3)
            scaleImageData?.writeToFile(scaleImagePath, atomically: true)
            
            // 设置显示的图片
            dispatch_async(dispatch_get_main_queue(), {
                cameraLock.cameraLockImageView.image = originalImage
                ToastHub.sharedInstance.hideHub()
            })
        }
        picker.dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    // 关闭施封视图
    func closeCameraLockView() {
        self.cameraLock?.removeFromSuperview()
    }
    
    func submitCameraLock() {
        
        
        if self.cameraLock?.cameraLockImageView.image == nil {
            ToastHub.sharedInstance.showHubWithText(self.cameraLock!, text: "施封照片不能为空")
        } else {
            if let COCLevel = NSUserDefaults.standardUserDefaults().stringForKey("COCLevel") {
                if COCLevel == "10" {
                    // 上传图片
                    let originalImage = self.cameraLock!.cameraLockImageView.image!
                    let scaleImageData = UIImageJPEGRepresentation(originalImage, 0.3)
                    DevUtils.prints(self, content: "上传图片大小为:\((scaleImageData?.length)! / 1024)")
                    let imageDic = ["\(self.mImageNameCameraLock!)": scaleImageData!]
                    let pramDic = ["title": self.mImageNameCameraLock! , "imageBNType" : "ROLockPicture"]
                    
                    ELHUploadFile().uploadFileWithURL(NSURL(string: ApiContants.URL_POST_IMAGE), imageDic: imageDic, pramDic: pramDic, finishBlock: { (responseDict) in
                        if let resultSign: String = responseDict["resultSign"] as? String {
                            if resultSign == "1" {
                                // 提交订单相关数据
                                self.submitLockData()
                                
                            } else if resultSign == "2" {
                                dispatch_async(dispatch_get_main_queue(), {
                                    ToastHub.sharedInstance.hideHub()
                                    ToastHub.sharedInstance.showHubWithText(self.cameraLock!, text: "图片超过最大值(10M)")
                                })
                                
                            } else if resultSign == "-1" {
                                dispatch_async(dispatch_get_main_queue(), {
                                    ToastHub.sharedInstance.hideHub()
                                    ToastHub.sharedInstance.showHubWithText(self.cameraLock!, text: "异常失败")
                                })
                                
                            }
                        } else {
                            dispatch_async(dispatch_get_main_queue(), {
                                ToastHub.sharedInstance.hideHub()
                                ToastHub.sharedInstance.showHubWithText(self.cameraLock!, text: "上传图片失败,请重试")
                            })
                        }
                        
                    })
                    
                } else {
                    self.lockElockWithCommand()
                }
            }
            
        }
    }
    
    
    
    //MARK: - 订阅施封
    private var mSocket:GCDAsyncSocket!
    func lockElockWithCommand() -> Bool {
        ToastHub.sharedInstance.showHubWithLoad(self.cameraLock!, text: "电子锁施封中,大约需要1分钟")
        
        // 上传图片
        let originalImage = self.cameraLock!.cameraLockImageView.image!
        let scaleImageData = UIImageJPEGRepresentation(originalImage, 0.3)
        DevUtils.prints(self, content: "上传图片大小为:\((scaleImageData?.length)! / 1024)")
        let imageDic = ["\(self.mImageNameCameraLock!)": scaleImageData!]
        let pramDic = ["title": self.mImageNameCameraLock! , "imageBNType" : "ROLockPicture"]
        
        ELHUploadFile().uploadFileWithURL(NSURL(string: ApiContants.URL_POST_IMAGE), imageDic: imageDic, pramDic: pramDic, finishBlock: { (responseDict) in
            if let resultSign: String = responseDict["resultSign"] as? String {
                if resultSign == "1" {
                    DevUtils.prints(self, content: "resultSign = \(resultSign)")
                    dispatch_async(dispatch_get_main_queue(), {
                        ToastHub.sharedInstance.hideHub()
                        ToastHub.sharedInstance.showHubWithLoad(self.cameraLock!, text: "图片上传成功,电子锁施封中")
                        
                    })
                    // 登录施封
                    self.lockRssWithLogin()
                    
                } else if resultSign == "2" {
                    dispatch_async(dispatch_get_main_queue(), {
                        ToastHub.sharedInstance.hideHub()
                        ToastHub.sharedInstance.showHubWithText(self.cameraLock!, text: "图片超过最大值(10M)")
                    })
                    
                } else if resultSign == "-1" {
                    dispatch_async(dispatch_get_main_queue(), {
                        ToastHub.sharedInstance.hideHub()
                        ToastHub.sharedInstance.showHubWithText(self.cameraLock!, text: "异常失败")
                    })
                    
                }
            } else {
                dispatch_async(dispatch_get_main_queue(), {
                    ToastHub.sharedInstance.hideHub()
                    ToastHub.sharedInstance.showHubWithText(self.cameraLock!, text: "上传图片失败,请重试")
                })
            }
            
        })
        
        
        mSocket = GCDAsyncSocket(delegate: self, delegateQueue: dispatch_get_global_queue(0, 0))
        do {
            try mSocket.connectToHost(ApiContants.BASE_ELOCK_HOST, onPort: 9981)
        }catch{
            DevUtils.prints("连接异常", cls: self, content: "Socket连接异常")
        }
        
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
            "COCUnloadM" : (mFormModel?.unloadLinkmanPhone!)!, // 收货人电话
            "ROLockPicture" : self.mImageNameCameraLock, // 施封照片
            "COPassword" : self.mElockPassword, // 施封密码
        ]
        DevUtils.prints("拍照施封-参数", cls: self, content: jsonDict.description)
        let params = ["jo":jsonDict.description]
        Alamofire.request(.POST, ApiContants.URL_POST_FORM_CAMERA_LOCK, parameters: params).responseJSON { (result) in
            DevUtils.prints("拍照施封-返回值", cls: self, content: result.description)
            if result.result.isFailure{
                ToastHub.sharedInstance.showHubWithText(self.cameraLock!, text: "网络异常,请重试")
                return
            }
            
            if let resultValue = result.result.value{
                let resultCode:Int = JSON(resultValue)["resultSign"].int!
                if (resultCode == 1) { // 施封成功
                    if let COCLevel = NSUserDefaults.standardUserDefaults().stringForKey("COCLevel") {
                        if COCLevel == "10" {
                            ToastHub.sharedInstance.showHubWithText(self.cameraLock!, text: "图片上传成功，准备发货")
                        } else {
                            ToastHub.sharedInstance.showHubWithText(self.cameraLock!, text: "施封成功")
                        }
                    }
                    
                    
                    self.cameraLock?.removeFromSuperview()
                    
                    // 刷新数据
                    self.loadFormModelWithEnd()
                    
                }else{ // 未知状态
                    ToastHub.sharedInstance.showHubWithText(self.cameraLock!, text: "未知状态")
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
                if socketResult.containsString("failReason") && socketResult.containsString("终端不在线") {
                    sock.disconnect()
                    dispatch_async(dispatch_get_main_queue()) {
                        ToastHub.sharedInstance.hideHub()
                        ToastHub.sharedInstance.showHubWithText(self.cameraLock!, text: "终端不在线")
                    }
                    return
                } else if socketResult.containsString("resultByteStr\":\"80") { // 施封成功
                    sock.disconnect()
                    self.submitLockData()
                }else if socketResult.containsString("resultByteStr\":\"81") { // 重复施封
                    sock.disconnect()
                    dispatch_async(dispatch_get_main_queue()) {
                        ToastHub.sharedInstance.hideHub()
                        ToastHub.sharedInstance.showHubWithText(self.cameraLock!, text: "重复施封")
                    }
                }else if socketResult.containsString("resultByteStr\":\"82") { // 锁未插好，施封失败
                    sock.disconnect()
                    dispatch_async(dispatch_get_main_queue()) {
                        ToastHub.sharedInstance.hideHub()
                        ToastHub.sharedInstance.showHubWithText(self.cameraLock!, text: "锁未插好，施封失败")
                    }
                }else if socketResult.containsString("resultByteStr\":\"83") { // 电压过低，不能施封
                    sock.disconnect()
                    dispatch_async(dispatch_get_main_queue()) {
                        ToastHub.sharedInstance.hideHub()
                        ToastHub.sharedInstance.showHubWithText(self.cameraLock!, text: "电压过低，不能施封")
                    }
                }else if socketResult.containsString("resultByteStr\":\"84") { // 锁异常：非法拆壳，不予施封
                    sock.disconnect()
                    dispatch_async(dispatch_get_main_queue()) {
                        ToastHub.sharedInstance.hideHub()
                        ToastHub.sharedInstance.showHubWithText(self.cameraLock!, text: "锁异常：非法拆壳，不予施封")
                    }
                }else if socketResult.containsString("resultByteStr\":\"85") { // 锁异常：应急开锁，不予施封
                    sock.disconnect()
                    dispatch_async(dispatch_get_main_queue()) {
                        ToastHub.sharedInstance.hideHub()
                        ToastHub.sharedInstance.showHubWithText(self.cameraLock!, text: "锁异常：应急开锁，不予施封")
                    }
                }else if socketResult.containsString("resultByteStr\":\"86") { // 锁杆剪断报警，不予施封
                    sock.disconnect()
                    dispatch_async(dispatch_get_main_queue()) {
                        ToastHub.sharedInstance.hideHub()
                        ToastHub.sharedInstance.showHubWithText(self.cameraLock!, text: "锁杆剪断报警，不予施封")
                    }
                }else if socketResult.containsString("resultByteStr\":\"87") { // 锁杆打开报警，不予施封
                    sock.disconnect()
                    dispatch_async(dispatch_get_main_queue()) {
                        ToastHub.sharedInstance.hideHub()
                        ToastHub.sharedInstance.showHubWithText(self.cameraLock!, text: "锁杆打开报警，不予施封")
                    }
                }else if socketResult.containsString("resultByteStr\":\"89") { // 施封超时
                    sock.disconnect()
                    dispatch_async(dispatch_get_main_queue()) {
                        ToastHub.sharedInstance.hideHub()
                        ToastHub.sharedInstance.showHubWithText(self.cameraLock!, text: "施封超时")
                    }
                }else{ // 施封失败，继续接收数据
                    sock.readDataWithTimeout(-1, tag: 2)
                }
            }
        }else{
            DevUtils.prints("施封-未知-返回值", cls: self, content: "<\(tag)>\(NSString(data: data, encoding: NSUTF8StringEncoding)!)")
        }
    }
    
    
    // 确认送达
    func submitFormFinish(sender:UIButton) {
        let index:Int = sender.tag
        if let fModels = mTableGroupEnd.formModels {
            let formModel = fModels[index]
            
            let jsonDict:JSON = [
                "COId": UserBean.sharedInstance.userId, // 车主ID
                "GOId" : formModel.goodsId!, // 货主ID
                "ROId": formModel.mainId!, // 订单主键
                "ROBM" : formModel.formId!, // 订单编号
            ]
            DevUtils.prints("确认送达-参数", cls: self, content: jsonDict.description)
            let params = ["jo":jsonDict.description]
            Alamofire.request(.POST, ApiContants.URL_POST_FORM_SUBMIT_FINISH, parameters: params).responseJSON { (result) in
                DevUtils.prints("确认送达-返回值", cls: self, content: result.description)
                if result.result.isFailure{
                    ToastHub.sharedInstance.showHubWithText(self.view, text: "网络异常,请重试")
                    return
                }
                
                if let resultValue = result.result.value{
                    let resultCode = JSON(resultValue)["resultSign"].string!
                    if (resultCode == "-1") { // 异常失败
                        ToastHub.sharedInstance.showHubWithText(self.view, text: "异常失败")
                    }else if (resultCode == "1") { // 成功
                        ToastHub.sharedInstance.showHubWithText(self.view, text: "成功")
                        // 重新加载数据
                        self.setUpRefresh()
                    }else if(resultCode == "2"){ // 没有此单
                        ToastHub.sharedInstance.showHubWithText(self.view, text: "没有此单")
                    }else if(resultCode == "3"){ // 锁状态不正确
                        ToastHub.sharedInstance.showHubWithText(self.view, text: "电子锁未解封")
                    }else{ // 未知状态
                        ToastHub.sharedInstance.showHubWithText(self.view, text: "未知状态")
                    }
                }
            }
        }
    }
    
    //MARK: - Table Delegate
    // 标题高度
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat{
        return 40
    }
    
    

    
    // 自定义组标题
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?{
        let tableGroup:TableGroup = mTableGroups[section]
        let cell = tableView.dequeueReusableCellWithIdentifier("TableGroupCell")
        
        let btnGroupName:UIButton = cell?.viewWithTag(10) as! UIButton // 标题
        let btnGroupNumber: UIButton = cell?.viewWithTag(11) as! UIButton // 个数提示
//        let redPoint: UIImageView = cell?.viewWithTag(12) as! UIImageView // 小红点

        if section == 0 {
            // 创建小红点
            let redPoint: UIImageView = UIImageView(image: UIImage(named: "redPoint"))
            redPoint.frame = CGRectMake(90, 8, 8, 8)
            cell?.addSubview(redPoint)
            redPoint.hidden = true
            redPointImageView = redPoint
        }
        
//        redPointImageView = redPoint
        
        btnGroupName.tag = tableGroup.tag!
        btnGroupName.setTitle(tableGroup.name, forState: .Normal)
        
        btnGroupName.addTarget(self, action: #selector(self.actionGroupClick(_:)), forControlEvents: .TouchDown)
        
        if tableGroup.isExpand == true {
            btnGroupName.selected = true
        } else {
            btnGroupName.selected = false
        }
        

        if tableGroup.formModels?.count == 0 {
            btnGroupNumber.setTitle("0", forState: .Normal)
        } else {
            let str = String(tableGroup.formModels?.count)
            let fromStr = (str as NSString).stringByReplacingOccurrencesOfString("Optional(", withString: "")
            var toStr = fromStr.stringByReplacingOccurrencesOfString(")", withString: "")
            if toStr == "nil" {
                toStr = "0"
            }
            btnGroupNumber.setTitle(toStr, forState: .Normal)
        }
       
        
        
        return cell
    }
    
    // 点击了HeaderView
    func actionGroupClick(button:UIButton) {
        if button.tag == self.mTableGroupNot.tag {
            if self.mTableGroupNot.isExpand == false {
                self.mTableGroupNot.isExpand = true
                self.mTableGroupIng.isExpand = false
                self.mTableGroupEnd.isExpand = false
                if self.redPointImageView?.hidden == false {
                    // 重新加载数据
                    self.loadFormModelWithNot()
                }
            } else {
                if self.redPointImageView?.hidden == false {
                    // 重新加载数据
                    self.loadFormModelWithNot()
                }
                return
            }
        }
        
        if button.tag == self.mTableGroupIng.tag {
            if self.mTableGroupIng.isExpand == false {
                self.mTableGroupNot.isExpand = false
                self.mTableGroupIng.isExpand = true
                self.mTableGroupEnd.isExpand = false
            } else {
                return
            }
        }
        
        if button.tag == self.mTableGroupEnd.tag {
            if self.mTableGroupEnd.isExpand == false {
                self.mTableGroupNot.isExpand = false
                self.mTableGroupIng.isExpand = false
                self.mTableGroupEnd.isExpand = true
            } else {
                return
            }
        }
        
        self.tableView.reloadData()
    }
    
    // 监听：点击行
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        //print("[点击]=\(indexPath)")
    }

    // JSON Array -> Array<FormModel>
    private func formJsonArrToForms(jsonValue:AnyObject) -> Array<FormModel> {
        var formModels = Array<FormModel>()
        let formJsonArr = JSON(jsonValue).array
        for formJson in formJsonArr! {
            let formModel = FormModel()
            if let formMain = formJson["ROId"].string { // 主键
                formModel.mainId = formMain
            }
            if let goodsId = formJson["GOId"].string { // 货主ID
                formModel.goodsId = goodsId
            }
            if let priceId = formJson["OPId"].string { // 报价ID
                formModel.priceId = priceId
            }
            if let statusCode = formJson["ROState"].string { // 状态码
                formModel.statusCode = Int(statusCode)
            }
            if let formId = formJson["ROBM"].string { // 订单编号
                formModel.formId = formId
            }
            
            if let loadAddress = formJson["ROLoadSite"].string { // 装货地点
                formModel.loadAddress = loadAddress
            }
            if let loadLongitude = formJson["ROLLon"].string { // 装货经度
                formModel.loadLongitude = Double(loadLongitude)
            }
            if let loadLatitude = formJson["ROLLat"].string { // 装货纬度
                formModel.loadLatitude = Double(loadLatitude)
            }
            if let loadTime = formJson["ROLoadTime"].string { // 装货时间
                formModel.loadTime = loadTime.stringByReplacingOccurrencesOfString(".0", withString: "")
            }
            if let loadLinkmanPhone = formJson["COCLoadM"].string { // 装货联系人电话
                formModel.loadLinkmanPhone = loadLinkmanPhone
            }
            if let tailBoard = formJson["ROIsWB"].string { // 尾板
                formModel.tailBoard = (tailBoard == "1" ? true : false)
            }
            if let slideDoor = formJson["ROCMNum"].string { // 侧门
                formModel.slideDoor = (slideDoor == "1" ? true : false)
            }
            
            if let unloadAddress = formJson["ROUnloadSite"].string { // 卸货地点
                formModel.unloadAddress = unloadAddress
            }
            if let unloadLongitude = formJson["ROULlon"].string { // 卸货经度
                formModel.unloadLongitude = Double(unloadLongitude)
            }
            if let unloadLatitiude = formJson["ROULLat"].string { // 卸货纬度
                formModel.unloadLatitiude = Double(unloadLatitiude)
            }
            if let unloadLinkmanPhone = formJson["COCUnloadM"].string { // 卸货联系人电话
                formModel.unloadLinkmanPhone = unloadLinkmanPhone
            }
            
            if let routeMiles = formJson["ROKM"].string { // 里程
                formModel.routeMiles = Double(routeMiles)
            }
            if let vehicleLevel = formJson["COCLevel"].string { // 车辆等级
                formModel.vehicleLevel = Int(vehicleLevel)
            }
            
            if let publishTime = formJson["COPublishTime"].string { // 发布日期
                formModel.publishTime = publishTime.stringByReplacingOccurrencesOfString(".0", withString: "")
            }
            
            if let freePrice = formJson["Price"].string { // 报价价格
                formModel.freePrice = Double(freePrice)
            }
            if let dealPrice = formJson["ROPrice"].string { // 成交价格
                formModel.dealPrice = Double(dealPrice)
            }
            if let freePriceMax = formJson["pMAX"].string { // 最高报价
                formModel.freePriceMax = String(format: "%.2f", Double(freePriceMax)!)
            }
            if let freePriceMin = formJson["pMIN"].string { // 最低报价
                formModel.freePriceMin = String(format: "%.2f", Double(freePriceMin)!)
            }
            if let freePriceAverage = formJson["pAVG"].string { // 平均报价
                formModel.freePriceAverage = String(format: "%.2f", Double(freePriceAverage)!)
            }
            if let freePriceManNum = formJson["pCOUNT"].string { // 报价人数
                formModel.freePriceManNum = Int(freePriceManNum)
            }
            
            if let unlockPassword = formJson["COPassword"].string { // 解封密码
                formModel.unlockPassword = unlockPassword
            }
            
            formModels.append(formModel)
        }
        return formModels
    }
}


class TableGroup: NSObject {
    var tag:Int?
    var name:String?
    var isExpand:Bool?
    var formModels:Array<FormModel>?
    
    init(tag:Int, name:String, isExpand:Bool) {
        self.tag = tag
        self.name = name
        self.isExpand = isExpand
    }
}

