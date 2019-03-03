//
//  SlideMenuView.swift
//  eLahuoForCar
//
//  Created by IceHan on 16/3/30.
//  Copyright © 2016年 elahuo.net. All rights reserved.
//

import UIKit

class SlideMenuView: BaseTableViewController {
    
    @IBOutlet weak var mBtnHead: UIButton!
    @IBOutlet weak var mLbInfo: UILabel!
    @IBOutlet weak var mBtnAutRealName: UIButton!
    @IBOutlet weak var mBtnAutCar: UIButton!
    
    private var mColorDrakGreen:UIColor = UIColor().hexStringToColor(ColorConstants.ThemeColorDarkGreen)
    private var mColorGrey:UIColor = UIColor().hexStringToColor(ColorConstants.Grey500)
    
    private var mIconHead:UIImage = UIImage(named: "icon_head_login")!
    private var mIconHeadGery:UIImage = UIImage(named: "icon_head_login_grey")!
    private var mIconAut:UIImage = UIImage(named: "icon_certificate")!
    private var mIconAutGrey:UIImage = UIImage(named: "icon_certificate_grey")!
    
    private var mHeadImg:UIImage!
    private var mInfoText:String!
    private var mInfoColor:UIColor!
    private var mAutRealNameImg:UIImage!
    private var mAutRealNameColor:UIColor!
    private var mAutCarImg:UIImage!
    private var mAutCarColor:UIColor!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.scrollEnabled = false

    }

    
    // 点击了头像按钮: 登录 / 进入个人中心
    @IBAction func headButtonClick(sender: UIButton) {
        if UserBean.sharedInstance.isLoging() {
            self.performSegueWithIdentifier("toMyCenterView", sender: nil)
        } else {
            self.performSegueWithIdentifier("toLoginView", sender: nil)
        }
    }
    
    
    override func viewWillAppear(animated: Bool) {
        if UserBean.sharedInstance.isLoging(){
            mBtnHead.setImage(mIconHead, forState: .Normal)
            mLbInfo.text = UserBean.sharedInstance.phoneNum
            mLbInfo.textColor = mColorDrakGreen
            
            if let isFinish = UserBean.sharedInstance.isFinishAutRealName {
                if isFinish {
                    mBtnAutRealName.setImage(mIconAut, forState: .Normal)
                    mBtnAutRealName.setTitleColor(mColorDrakGreen, forState: .Normal)
                } else {
                    mBtnAutRealName.setImage(mIconAutGrey, forState: .Normal)
                    mBtnAutRealName.setTitleColor(mColorGrey, forState: .Normal)
                }
            }
            
            if let isFinish = UserBean.sharedInstance.isFinishAutCar {
                if isFinish {
                    mBtnAutCar.setImage(mIconAut, forState: .Normal)
                    mBtnAutCar.setTitleColor(mColorDrakGreen, forState: .Normal)
                } else {
                    mBtnAutCar.setImage(mIconAutGrey, forState: .Normal)
                    mBtnAutCar.setTitleColor(mColorGrey, forState: .Normal)
                }
            }
            
            
        } else {
            mBtnHead.setImage(mIconHeadGery, forState: .Normal)
            mLbInfo.text = "登录/注册"
            mLbInfo.textColor = mColorGrey
            mBtnAutRealName.setImage(mIconAutGrey, forState: .Normal)
            mBtnAutRealName.setTitleColor(mColorGrey, forState: .Normal)
            mBtnAutCar.setImage(mIconAutGrey, forState: .Normal)
            mBtnAutCar.setTitleColor(mColorGrey, forState: .Normal)
        }
        
    }
    
    func logoutSuccess() {
        mHeadImg = mIconHeadGery
        mInfoText = "登录/注册"
        mInfoColor = mColorGrey
        mAutRealNameImg = mIconAutGrey
        mAutRealNameColor = mColorGrey
        mAutCarImg = mIconAutGrey
        mAutCarColor = mColorGrey
        
        mBtnHead.setImage(mHeadImg, forState: .Normal)
        
        mLbInfo.text = mInfoText
        mLbInfo.textColor = mInfoColor
        
        mBtnAutRealName.setImage(mAutRealNameImg, forState: .Normal)
        mBtnAutRealName.setTitleColor(mAutRealNameColor, forState: .Normal)
        
        mBtnAutCar.setImage(mAutCarImg, forState: .Normal)
        mBtnAutCar.setTitleColor(mAutCarColor, forState: .Normal)
    }
    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        self.slideMenuController()?.closeLeft()
    }
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        // 没登录的情况下，一下界面不准跳转
        if !UserBean.sharedInstance.isLoging() {
            if (identifier == IdentityConstants.SugueToHistoryView
                || identifier == IdentityConstants.SugueToRealNameView
                || identifier == IdentityConstants.SugueToAutCarView
                || identifier == IdentityConstants.SugueToWalletView || identifier == IdentityConstants.SugueToSettingView) {
                
                ToastHub.sharedInstance.showHubWithText(self.view, text: "请您先登录")
                return false
            }
        }
        return true
    }

}
