//
//  BaseViewController.swift
//  eLahuoForCar
//
//  Created by IceHan on 16/3/30.
//  Copyright © 2016年 elahuo.net. All rights reserved.
//

import UIKit
import MBProgressHUD

class BaseViewController: UIViewController {
    
    /** 关闭当前界面 */
    @IBAction func closeCurrentView(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    
}
