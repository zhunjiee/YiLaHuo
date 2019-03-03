//
//  MyCenterView.swift
//  eLahuoForCar
//
//  Created by elahuo on 16/6/6.
//  Copyright © 2016年 elahuo.net. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class MyCenterView: UITableViewController {
    
    @IBOutlet weak var phoneNumLabel: UILabel! // 手机号
    @IBOutlet weak var onlyCodeLabel: UILabel! // 邀请码
    @IBOutlet weak var nameTextField: UITextField! // 姓名
    @IBOutlet weak var star1: UIImageView!
    @IBOutlet weak var star2: UIImageView!
    @IBOutlet weak var star3: UIImageView!
    @IBOutlet weak var star4: UIImageView!
    @IBOutlet weak var star5: UIImageView!
    
    
    // 关闭当前界面
    @IBAction func closeCurrentView(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setUpInfo()
        
        self.tableView.allowsSelection = false
    }
    
    
    func setUpInfo() {
        phoneNumLabel.text = UserBean.sharedInstance.phoneNum // 手机号
        onlyCodeLabel.text = UserBean.sharedInstance.soleTag // 邀请码
        // 姓名
        let userDefaults = NSUserDefaults.standardUserDefaults()
        if let userName = userDefaults.stringForKey("COName") { // 本地有数据
            nameTextField.text = userName
        } else { // 本地没有,去网络请求
            let jsonDict:JSON = [
                "COId": UserBean.sharedInstance.userId
            ]
            
            let params = ["jo": jsonDict.description]
            Alamofire.request(.GET, ApiContants.URL_GET_AUT_REAL_NAME, parameters: params).responseJSON { (result) in
                DevUtils.prints("加载实名认证", cls: self, content: result.description)
                ToastHub.sharedInstance.hideHub()
                if let resultValue = result.result.value{
                    if let realName = JSON(resultValue)["COName"].string { // 车主姓名
                        self.nameTextField.text = realName
                        // 保存数据到本地
                        userDefaults.setObject(realName, forKey: "COName")
                    } else {
                        self.nameTextField.text = nil
                    }
                }
            }
        }
        
        // 星级
        if let starlevel = Float(UserBean.sharedInstance.starLevel) {
            if starlevel >= 0 && starlevel < 1 {
                self.star1.image = UIImage(named: "Star_deselected")
                self.star2.image = UIImage(named: "Star_deselected")
                self.star3.image = UIImage(named: "Star_deselected")
                self.star4.image = UIImage(named: "Star_deselected")
                self.star5.image = UIImage(named: "Star_deselected")
            } else if starlevel >= 1 && starlevel < 2 {
                self.star1.image = UIImage(named: "Star_selected")
                self.star2.image = UIImage(named: "Star_deselected")
                self.star3.image = UIImage(named: "Star_deselected")
                self.star4.image = UIImage(named: "Star_deselected")
                self.star5.image = UIImage(named: "Star_deselected")
            } else if starlevel >= 2 && starlevel < 3 {
                self.star1.image = UIImage(named: "Star_selected")
                self.star2.image = UIImage(named: "Star_selected")
                self.star3.image = UIImage(named: "Star_deselected")
                self.star4.image = UIImage(named: "Star_deselected")
                self.star5.image = UIImage(named: "Star_deselected")
            } else if starlevel >= 3 && starlevel < 4 {
                self.star1.image = UIImage(named: "Star_selected")
                self.star2.image = UIImage(named: "Star_selected")
                self.star3.image = UIImage(named: "Star_selected")
                self.star4.image = UIImage(named: "Star_deselected")
                self.star5.image = UIImage(named: "Star_deselected")
            } else if starlevel >= 4 && starlevel < 5 {
                self.star1.image = UIImage(named: "Star_selected")
                self.star2.image = UIImage(named: "Star_selected")
                self.star3.image = UIImage(named: "Star_selected")
                self.star4.image = UIImage(named: "Star_selected")
                self.star5.image = UIImage(named: "Star_deselected")
            } else if starlevel == 5 {
                self.star1.image = UIImage(named: "Star_selected")
                self.star2.image = UIImage(named: "Star_selected")
                self.star3.image = UIImage(named: "Star_selected")
                self.star4.image = UIImage(named: "Star_selected")
                self.star5.image = UIImage(named: "Star_selected")
            }
        }
    }
    

    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.00001
    }
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 20
    }
}
