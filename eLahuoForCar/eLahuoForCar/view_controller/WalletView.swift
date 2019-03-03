//
//  WalletView.swift
//  eLahuoForCar
//
//  Created by IceHan on 16/3/30.
//  Copyright © 2016年 elahuo.net. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import CoreLocation

class WalletView: BaseViewController, UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate {

    
    @IBOutlet weak var mLbBalance: UILabel! // 余额
    @IBOutlet weak var mTvWalletHistory: UITableView!
    
    private let KEY_UD_BANK_CAR_NUM = "BankCarNum"
    
    private var mWalletHistories = Array<WalletHistory>()
    
    private let mUserDefault = NSUserDefaults.standardUserDefaults()

    // 省份
    private var province = "未知"
    // 城市
    private var city = "未知"
    
    // 开户城市textfield
    private var cityTextField: UITextField?
    
    // 省市选择器
    var provincePicker: ProvincePickerView?
    // 城市模型
    var currentSelectProvinceModel: ProvinceModel?
    
    
    // 用户位置管理者对象
    private lazy var locationManager: CLLocationManager = {
        let locationM = CLLocationManager()
        locationM.delegate = self
        locationM.requestWhenInUseAuthorization()
        return locationM
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.mTvWalletHistory.delegate = self
        self.mTvWalletHistory.dataSource = self
        
        // 开启定位
        self.locationManager.startUpdatingLocation()
    }
    
    func setTextFieldTextWithProvinceModel(currentProvinceModel: ProvinceModel) {
        self.currentSelectProvinceModel = currentProvinceModel
        self.province = currentProvinceModel.provinceName
        self.city = currentProvinceModel.cityName
        
        self.cityTextField?.text = "\(province) \(city)"
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        // 读取钱包余额
        self.readWalletBalance()
        
        // 读取钱包历史
        self.readWalletHistory()
    }
 
    // 提现
    @IBAction func actionFetchBalance(sender: UIBarButtonItem) {
        // 初始化省市选择器
        self.provincePicker = ProvincePickerView()
        self.view.addSubview(self.provincePicker!)
        
        weak var weakSelf = self
        self.provincePicker?.setSelectProvinceInfoBlock({ (currentProvinceModel) in
            if (currentProvinceModel != nil) {
                weakSelf?.setTextFieldTextWithProvinceModel(currentProvinceModel)
            }
        })
        
//        if !isCanFecthBalance { // 不是提现日的情况
//            let alertController = UIAlertController(title: "提现提醒", message: "非提现日不可提现\n\n每周周二为提现日", preferredStyle: .Alert)
//            alertController.addAction(UIAlertAction(title: "确认", style: .Cancel, handler: nil))
//            self.presentViewController(alertController, animated: true, completion: nil)
//            return
//        }
        
        let alertController = UIAlertController(title: "提现申请", message: "本次提款将在第二个工作日到账\n\n\n\n\n\n", preferredStyle: .Alert)
        
        // 自定义alertView视图
        let margin:CGFloat = 16.0
        let width = (270.0 - margin * 2)
        let rect = CGRectMake(margin, 80.0, width, 90.0)
        let customAlertView = UIView(frame: rect)
        
        
        // 银行卡号
        let textFieldHieght: CGFloat = 26.0
        let textField1 = UITextField(frame: CGRectMake(0, 0, width, textFieldHieght))
        textField1.font = UIFont.systemFontOfSize(14)
        textField1.placeholder = "银行卡号(本人)"
        textField1.keyboardType = .NumberPad
        textField1.borderStyle = .RoundedRect
        customAlertView.addSubview(textField1)
        textField1.addTarget(self, action: #selector(WalletView.textFieldChangeWithBankCarNum(_:)), forControlEvents: .EditingChanged)
        self.bankCardNum = self.mUserDefault.stringForKey(self.KEY_UD_BANK_CAR_NUM)
        textField1.text = self.bankCardNum
        
        // 开户城市
        let textField2 = UITextField(frame: CGRectMake(0, textFieldHieght + 2, width, textFieldHieght))
        textField2.font = UIFont.systemFontOfSize(14)
        textField2.placeholder = "开户城市"
        textField2.borderStyle = .RoundedRect
        textField2.userInteractionEnabled = false
        cityTextField = textField2
        textField2.text = "\(province) \(city)"
        customAlertView.addSubview(textField2)
        // 选择城市按钮
        let selButton = UIButton(type: .System)
        selButton.frame = CGRectMake(0, textFieldHieght + 2, width, textFieldHieght)
        customAlertView.addSubview(selButton)
        selButton.addTarget(self, action: #selector(selButtonDidClick), forControlEvents: .TouchUpInside)
        
        // 提取金额
        let textField3 = UITextField(frame: CGRectMake(0, textFieldHieght * 2 + 4, width, textFieldHieght))
        textField3.font = UIFont.boldSystemFontOfSize(16)
        textField3.textColor = UIColor().hexStringToColor(ColorConstants.ThemeColorDarkGreen)
        textField3.placeholder = "提取金额(元)"
        textField3.keyboardType = .NumberPad
        textField3.borderStyle = .RoundedRect
        customAlertView.addSubview(textField3)
        textField3.addTarget(self, action: #selector(WalletView.textFieldChangeWithFetchMoney(_:)), forControlEvents: .EditingChanged)
        self.fetchMoney = ""
        textField3.text = self.fetchMoney
        
        alertController.view.addSubview(customAlertView)
        
        
        
        alertController.addAction(UIAlertAction(title: "取消", style: .Cancel, handler: nil))
        alertController.addAction(UIAlertAction(title: "确认", style: .Default, handler: { (alertAction) in
            // 提交前的逻辑判断
            if (self.bankCardNum?.isEmpty == true) || (self.fetchMoney?.isEmpty == true || (self.province.isEmpty == true) || (self.city.isEmpty == true)) {
                ToastHub.sharedInstance.showHubWithText(self.view, text: "提现失败,请填写所有内容")
                return
            } else if self.province == "未知" || self.city == "未知" {
                ToastHub.sharedInstance.showHubWithText(self.view, text: "开户城市不正确")
                return
            }
            
            DevUtils.prints(self, content: "province = \(self.province) city = \(self.city)")
            
            // 提交提现申请
            let jsonDict:JSON = [
                "COId": UserBean.sharedInstance.userId, // 车主ID
                "COSKZHCount": self.bankCardNum!, // 银行卡号
                "COSKZHProvince" : self.province, // 省份
                "COSKZHCity" : self.city, // 城市
                "HPOperAmount": self.fetchMoney! // 提现金额
            ]
            
            DevUtils.prints(self, content: "\(UserBean.sharedInstance.userId), \(self.bankCardNum!), \(self.province), \(self.city), \(self.fetchMoney!)")
            
            DevUtils.prints("提现申请-参数", cls: self, content: jsonDict.description)
            let params = ["jo":jsonDict.description]
            Alamofire.request(.POST, ApiContants.URL_GET_WALLET_FETCH, parameters: params).responseJSON { (result) in
                DevUtils.prints("提现申请-返回值", cls: self, content: result.description)

                if result.result.isFailure{
                    ToastHub.sharedInstance.showHubWithText(self.view, text: "网络异常,请重试")
                    return
                }
                
                if let resultValue = result.result.value{
                    let resultCode:String = JSON(resultValue)["resultSign"].string!
                    if (resultCode == "-1") { // 申请失败
                        ToastHub.sharedInstance.showHubWithText(self.view, text: "申请失败,请联系客服")
                    } else if (resultCode == "0") { // 提现金额大于余额
                        ToastHub.sharedInstance.showHubWithText(self.view, text: "提现金额大于余额")
                    } else if (resultCode == "1") { // 申请成功
                        ToastHub.sharedInstance.showHubWithText(self.view, text: "申请成功,等待处理")
                        // 成功后刷新钱包余额和历史
                        self.readWalletBalance()
                        self.readWalletHistory()
                    } else if (resultCode == "2") { // 钱包异常,联系客服
                        ToastHub.sharedInstance.showHubWithText(self.view, text: "钱包异常,请联系客服")
                    }else{ // 未知状态
                        ToastHub.sharedInstance.showHubWithText(self.view, text: "未知状态")
                    }
                }
            }
        }))
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    // 选择城市
    func selButtonDidClick() {
        self.provincePicker?.showPickerView()
    }
    
    // 银行卡号
    private var bankCardNum:String?
    func textFieldChangeWithBankCarNum(textField:UITextField) {
        print(textField.text)
        bankCardNum = textField.text!
        mUserDefault.setObject(bankCardNum, forKey: self.KEY_UD_BANK_CAR_NUM)
    }
    // 提取金额
    private var fetchMoney:String?
    func textFieldChangeWithFetchMoney(textField:UITextField) {
        fetchMoney = textField.text!
    }
    
    func changeUserLocation(textField: UITextField) {
        self.provincePicker?.showPickerView()
    }
    
    //MARK: - Data Source
    func numberOfSectionsInTableView(tableView: UITableView) -> Int{
        return 1
    }
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String?{
        return "钱包历史"
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return self.mWalletHistories.count
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCellWithIdentifier("WalletHistoryCell", forIndexPath: indexPath)
        
        let lbType:UILabel = cell.viewWithTag(1001) as! UILabel
        let lbTime:UILabel = cell.viewWithTag(1002) as! UILabel
        let lbMoney:UILabel = cell.viewWithTag(1003) as! UILabel
        
        let walletHis = self.mWalletHistories[indexPath.row]
        
        lbTime.text = walletHis.time
        if (walletHis.type == 0) { // 完成单入账
            lbType.text = "订单收入"
            lbMoney.text = "+ \(walletHis.money!)"
        }else if(walletHis.type == 1){  // 提现
            lbType.text = "提现"
            lbMoney.text = "- \(walletHis.money!)"
        }else if(walletHis.type == 2){  // 平台奖励
            lbType.text = "平台奖励"
            lbMoney.text = "+ \(walletHis.money!)"
        }else if(walletHis.type == 3){ // 新用户奖励
            lbType.text = "新用户奖励"
            lbMoney.text = "+ \(walletHis.money!)"
        }else if(walletHis.type == 4){ // 推荐用户奖励
            lbType.text = "推荐用户奖励"
            lbMoney.text = "+ \(walletHis.money!)"
        }else{ // 未知类型
            lbType.text = "未知类型"
            lbMoney.text = "\(walletHis.money!)"
        }
        
        return cell
    }
    
    //MARK: - Delegate
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat{
        return 30
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat{
        return 60
    }
    
    // 钱包历史
    private func readWalletHistory() {
        let jsonDict:JSON = [
            "COId": UserBean.sharedInstance.userId, // 车主ID
            "sPageNum": 1, // 起始页
            "aPageNum": 30 // 每页条数
        ]
        DevUtils.prints("钱包历史-参数", cls: self, content: jsonDict.description)
        let params = ["jo":jsonDict.description]
        Alamofire.request(.GET, ApiContants.URL_GET_WALLET_HISTORY, parameters: params).responseJSON { (result) in
            DevUtils.prints("钱包历史-返回值", cls: self, content: result.description)
            if result.result.isFailure{
                ToastHub.sharedInstance.showHubWithText(self.view, text: "网络异常,请重试")
                return
            }
            
            if let resultValue = result.result.value{
                if let jsonArr = JSON(resultValue).array {
                    for json in jsonArr {
                        let walletHis = WalletHistory()
                        if let formId = json["ROId"].string { // 订单ID
                            walletHis.formId = formId
                        }
                        if let time = json["HPOPTIME"].string { // 时间
                            walletHis.time = time
                        }
                        if let type = json["HPOPERATIONTYPE"].string { // 类型：0:完成单入账; 1:提现; 2:平台奖励; 3:新用户奖励; 4:推荐用户奖励
                            walletHis.type = Int(type)
                        }
                        if let money = json["HPOPERAMOUNT"].string { // 金额
                            walletHis.money = money
                        }
                        self.mWalletHistories.append(walletHis)
                    }
                    
                    self.mTvWalletHistory.reloadData()
                }
            }
        }
    }
    
    // 钱包余额
    private var isCanFecthBalance = false // 是否可提现
    private func readWalletBalance() {
        let jsonDict:JSON = [
            "COId": UserBean.sharedInstance.userId, // 车主ID
        ]
        DevUtils.prints("钱包余额-参数", cls: self, content: jsonDict.description)
        let params = ["jo":jsonDict.description]
        Alamofire.request(.GET, ApiContants.URL_GET_WALLET_BALANCE, parameters: params).responseJSON { (result) in
            DevUtils.prints("钱包余额-返回值", cls: self, content: result.description)
            if result.result.isFailure{
                ToastHub.sharedInstance.showHubWithText(self.view, text: "网络异常,请重试")
                return
            }
            
            if let resultValue = result.result.value{
                
                let resultCode:String = JSON(resultValue)["resultSign"].string!
                if (resultCode == "-1") { // 查询失败
                    ToastHub.sharedInstance.showHubWithText(self.view, text: "钱包余额,查询失败")
                }else if (resultCode == "1") { // 成功
                    self.isCanFecthBalance = true
                    var balanceAll = 0.0
                    var balanceUse = 0.0
                    if let balance = JSON(resultValue)["p_HPAmount"].string {
                        balanceAll = Double(balance)!
                    }
                    if let balance = JSON(resultValue)["p_HPAmountNo"].string {
                        balanceUse = Double(balance)!
                    }
//                    self.mLbBalance.text = String(balanceAll - balanceUse)
                    self.mLbBalance.text = String(balanceAll)
                } else if (resultCode == "2") { // 非提现日
                    self.isCanFecthBalance = false
                    var balanceAll = 0.0
                    var balanceUse = 0.0
                    if let balance = JSON(resultValue)["p_HPAmount"].string {
                        balanceAll = Double(balance)!
                    }
                    if let balance = JSON(resultValue)["p_HPAmountNo"].string {
                        balanceUse = Double(balance)!
                    }
                    self.mLbBalance.text = String(balanceAll - balanceUse)
                } else { // 未知状态
                    ToastHub.sharedInstance.showHubWithText(self.view, text: "钱包余额,未知状态")
                }
            }
        }
    }
    
    //MARK: - CLLocationManagerDelegate
    /**
     定位成功
     */
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let newLocation = locations.last {
            // 反地理编码
            CLGeocoder().reverseGeocodeLocation(newLocation, completionHandler: { (pms, error) in
                // 结束定位
                self.locationManager.stopUpdatingLocation()
                
                let placemark: CLPlacemark = (pms?.last)!
                let locality = placemark.locality! // 城市
                self.city = locality
                let administrativeArea = placemark.administrativeArea! //省
                self.province = administrativeArea
                DevUtils.prints(self, content: "用户当前位置为: \(administrativeArea)\(locality)" )
            })
        }
    }
}

class WalletHistory: NSObject {
    var formId:String? // 订单ID
    var time:String? // 时间
    var type:Int? // 类型：0:完成单入账; 1:提现; 2:平台奖励; 3:新用户奖励; 4:推荐用户奖励
    var money:String? // 金额
}
