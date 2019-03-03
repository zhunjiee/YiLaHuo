//
//  BaseNavigationController.swift
//  eLahuoForCar
//
//  Created by elahuo on 16/5/18.
//  Copyright © 2016年 elahuo.net. All rights reserved.
//

import UIKit


let globalColor = UIColor(red: 29.0 / 255.0, green: 154.0 / 255.0, blue: 115.0 / 255.0, alpha: 0.9)

class BaseNavigationController: UINavigationController {
    
    
    
    // 同意设置导航栏的属性
    override class func initialize() {
        let bar: UINavigationBar = UINavigationBar.appearance()
        var titleAttrs: [NSObject : AnyObject] = NSMutableDictionary() as [NSObject : AnyObject]
        titleAttrs[NSFontAttributeName] = UIFont.systemFontOfSize(20)
        titleAttrs[NSForegroundColorAttributeName] = globalColor
        bar.titleTextAttributes = titleAttrs as? [String : AnyObject]
        // 设置导航栏文字颜色
        bar.tintColor = globalColor
        
        let item: UIBarButtonItem = UIBarButtonItem.appearance()
        // 正常状态
        var normalAttrs: [NSObject : AnyObject] = NSMutableDictionary() as [NSObject : AnyObject]
        normalAttrs[NSFontAttributeName] = UIFont.systemFontOfSize(17)
        normalAttrs[NSForegroundColorAttributeName] = globalColor
        item.setTitleTextAttributes(normalAttrs as? [String : AnyObject], forState: .Normal)
        // 高亮状态
        var hightlightAttrs: [NSObject : AnyObject] = NSMutableDictionary() as [NSObject : AnyObject]
        hightlightAttrs[NSForegroundColorAttributeName] = globalColor
        item.setTitleTextAttributes(hightlightAttrs as? [String : AnyObject], forState: .Highlighted)
        // 隐藏返回按钮文字
        item.setBackButtonTitlePositionAdjustment(UIOffsetMake(0, -60), forBarMetrics: .Default)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
