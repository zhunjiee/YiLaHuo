//
//  FAQViewController.swift
//  eLahuoForCar
//
//  Created by elahuo on 16/7/28.
//  Copyright © 2016年 elahuo.net. All rights reserved.
//

import UIKit

class FAQViewController: UIViewController {

    @IBOutlet weak var webView: UIWebView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let path = NSBundle.mainBundle().pathForResource("常见问题", ofType: "html")
        let url = NSURL(fileURLWithPath: path!)
        let request = NSURLRequest(URL: url)
        webView.loadRequest(request)
    }

    
}
