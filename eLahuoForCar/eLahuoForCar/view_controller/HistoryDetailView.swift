//
//  HistoryDetailView.swift
//  eLahuoForCar
//
//  Created by IceHan on 16/4/12.
//  Copyright © 2016年 elahuo.net. All rights reserved.
//

import UIKit

class HistoryDetailView: BaseTableViewController, UMSocialUIDelegate {
    
    @IBOutlet weak var mLbLoadAddress: UILabel!
    @IBOutlet weak var mLbLoadTime: UILabel!
    @IBOutlet weak var mLbLoadLinkmanPhone: UILabel!
    
    @IBOutlet weak var mLbUnloadAddress: UILabel!
    @IBOutlet weak var mLbUnloadLinkmanPhone: UILabel!

    @IBOutlet weak var mLbMiles: UILabel!
    @IBOutlet weak var mLbVehicleLevel: UILabel!
    
    private var mFormModel:FormModel?
    
    func setFormModel(formModel:FormModel) {
        self.mFormModel = formModel
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let fModel = self.mFormModel {
            self.mLbLoadAddress.text = fModel.loadAddress!
            self.mLbLoadTime.text = fModel.loadTime!
            self.mLbLoadLinkmanPhone.text = fModel.loadLinkmanPhone!
            
            self.mLbUnloadAddress.text = fModel.unloadAddress!
            self.mLbUnloadLinkmanPhone.text = fModel.unloadLinkmanPhone!
            
            self.mLbMiles.text = "\(fModel.routeMiles!)km"
            self.mLbVehicleLevel.text = MapConstants.sharedInstance.keyConvertValue(fModel.vehicleLevel!, converType: TextSelectorType.VehicleLevel)
        }
        
    }
    
    // 订单分享
    @IBAction func orderShare(sender: UIBarButtonItem) {
        let UmengAppkey = "577474b667e58ede68000946"
        
        let shareText = "e拉货司机-最安全的互联网货运平台 http://www.elahuo.net \n各大APP平台搜索下载,注册输入我的邀请码(\(UserBean.sharedInstance.soleTag)),赢取100元红包大礼!"
        UMSocialSnsService.presentSnsIconSheetView(self, appKey: UmengAppkey, shareText: shareText, shareImage: nil, shareToSnsNames: [UMShareToWechatSession,UMShareToWechatTimeline,UMShareToSina,UMShareToQQ], delegate: self)
    }
    
    func didCloseUIViewController(fromViewControllerType: UMSViewControllerType) {
        DevUtils.prints(self, content: "didClose is \(fromViewControllerType)")
    }
    
    func didFinishGetUMSocialDataInViewController(response: UMSocialResponseEntity!) {
        DevUtils.prints(self, content: "didFinishGetUMSocialDataInViewController with response is \(response)")
        
        if response.responseCode == UMSResponseCodeSuccess {
            DevUtils.prints(self, content: "share to sns name is \(response.data[0])")
        }
    }
    
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.00001
    }
}
