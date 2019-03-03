//
//  HistoryView.swift
//  eLahuoForCar
//
//  Created by IceHan on 16/3/30.
//  Copyright © 2016年 elahuo.net. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class HistoryView: BaseTableViewController {
    
    private var mFormModels = Array<FormModel>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 加载历史订单
        self.loadFormModelWithHistory()
    }
    
    private func loadFormModelWithHistory() { // 历史订单
        let jsonDict:JSON = [
            "COId": UserBean.sharedInstance.userId, // 车主ID
            "sPageNum": 1, // 起始页
            "aPageNum": 15 // 每页显示条数
        ]
        DevUtils.prints("历史订单-参数", cls: self, content: jsonDict.description)
        let params = ["jo": jsonDict.description]
        Alamofire.request(.GET, ApiContants.URL_GET_FORM_HISTORY, parameters: params).responseJSON { (result) in
            DevUtils.prints("历史订单-返回值", cls: self, content: result.description)
            if let resultValue = result.result.value {
                self.mFormModels = self.formJsonArrToForms(resultValue)
                self.tableView.reloadData()
            }
        }
    }
    
    //MARK: - Data Source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.mFormModels.count
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat{
        return 95
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("FormHistoryCell", forIndexPath: indexPath)
        
        let lbTime:UILabel = cell.viewWithTag(1001) as! UILabel
        let lbMoney:UILabel = cell.viewWithTag(1002) as! UILabel
        let lbLoadAddress:UILabel = cell.viewWithTag(1003) as! UILabel
        let lbUnloadAddress:UILabel = cell.viewWithTag(1004) as! UILabel
        let lbMiles:UILabel = cell.viewWithTag(1005) as! UILabel
        
        let formModel = self.mFormModels[indexPath.row]
        lbTime.text = formModel.loadTime!
        lbMoney.text = "￥\(formModel.dealPrice!)"
        lbLoadAddress.text = formModel.loadAddress!
        lbUnloadAddress.text = formModel.unloadAddress!
        lbMiles.text = "\(formModel.routeMiles!)km"
        
        // 设置评价界面数据
        
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        let fModel = self.mFormModels[indexPath.row]
        
        let hisDetailView:HistoryDetailView = self.storyboard?.instantiateViewControllerWithIdentifier(IdentityConstants.HistoryDetailView) as! HistoryDetailView
        hisDetailView.setFormModel(fModel)
        
        self.navigationController?.showViewController(hisDetailView, sender: self)
    }
    
    /**
     立即评价
     
     - parameter sender: 评价按钮
     */
    @IBAction func assessButtonDidClick(sender: UIButton) {
        
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
            if let statusCode = formJson["ROSTATE"].string { // 状态码
                formModel.statusCode = Int(statusCode)
            }
            if let formId = formJson["ROBM"].string { // 订单编号
                formModel.formId = formId
            }
            
            if let loadAddress = formJson["ROLOADSITE"].string { // 装货地点
                formModel.loadAddress = loadAddress
            }
            if let loadLongitude = formJson["ROLLON"].string { // 装货经度
                formModel.loadLongitude = Double(loadLongitude)
            }
            if let loadLatitude = formJson["ROLLAT"].string { // 装货纬度
                formModel.loadLatitude = Double(loadLatitude)
            }
            if let loadTime = formJson["ROLOADTIME"].string { // 装货时间
                formModel.loadTime = loadTime.stringByReplacingOccurrencesOfString(".0", withString: "")
            }
            if let loadLinkmanPhone = formJson["COCLOADM"].string { // 装货联系人电话
                formModel.loadLinkmanPhone = loadLinkmanPhone
            }
            if let tailBoard = formJson["ROIsWB"].string { // 尾板
                formModel.tailBoard = (tailBoard == "1" ? true : false)
            }
            if let slideDoor = formJson["ROCMNum"].string { // 侧门
                formModel.slideDoor = (slideDoor == "1" ? true : false)
            }
            
            if let unloadAddress = formJson["ROUNLOADSITE"].string { // 卸货地点
                formModel.unloadAddress = unloadAddress
            }
            if let unloadLongitude = formJson["ROULLON"].string { // 卸货经度
                formModel.unloadLongitude = Double(unloadLongitude)
            }
            if let unloadLatitiude = formJson["ROULLAT"].string { // 卸货纬度
                formModel.unloadLatitiude = Double(unloadLatitiude)
            }
            if let unloadLinkmanPhone = formJson["COCUNLOADM"].string { // 卸货联系人电话
                formModel.unloadLinkmanPhone = unloadLinkmanPhone
            }
            
            if let routeMiles = formJson["ROKM"].string { // 里程
                formModel.routeMiles = Double(routeMiles)
            }
            if let vehicleLevel = formJson["COCLEVEL"].string { // 车辆等级
                formModel.vehicleLevel = Int(vehicleLevel)
            }
            
            if let publishTime = formJson["COPUBLISHTIME"].string { // 发布日期
                formModel.publishTime = publishTime.stringByReplacingOccurrencesOfString(".0", withString: "")
            }
            
            if let freePrice = formJson["Price"].string { // 报价价格
                formModel.freePrice = Double(freePrice)
            }
            if let dealPrice = formJson["ROPRICE"].string { // 成交价格
                formModel.dealPrice = Double(dealPrice)
            }
            
            if let unlockPassword = formJson["COPassword"].string { // 解封密码
                formModel.unlockPassword = unlockPassword
            }
            
            formModels.append(formModel)
        }
        return formModels
    }
}
