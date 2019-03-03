//
//  BaseTableViewController.swift
//  eLahuoForCar
//
//  Created by eLahuo on 16/3/30.
//  Copyright © 2016年 elahuo.net. All rights reserved.
//

import UIKit
import Alamofire

class BaseTableViewController: UITableViewController {
    
    // 关闭当前界面
    @IBAction func closeCurrentView(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 去除空白的CELL
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
    }
    
    // 移除所有的子类
    func removeAllChildViews(view:UIView) {
        for v in view.subviews {
            v.removeFromSuperview()
        }
    }
    
    // 隐藏或显示指定的视图
    func viewsHidden(views:Array<UIView>, hidden:Bool) {
        for view in views {
            view.hidden = hidden
        }
    }

}
