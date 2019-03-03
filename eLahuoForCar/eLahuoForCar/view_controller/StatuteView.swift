//
//  StatuteView.swift
//  eLahuoForCar
//
//  Created by IceHan on 16/3/30.
//  Copyright © 2016年 elahuo.net. All rights reserved.
//

import UIKit

class StatuteView: UIViewController {
    
    @IBOutlet weak var mWvTermsService: UIWebView!
    
    override func viewDidLoad() {
        
        let htmlURL = NSURL.fileURLWithPath(NSBundle.mainBundle().pathForResource("e拉货司机服务条款", ofType: "html")!)
        
        mWvTermsService.loadRequest(NSURLRequest(URL: htmlURL))
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
