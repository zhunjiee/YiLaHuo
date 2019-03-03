//
//  QRCodeViewController.swift
//  eLahuoForCar
//
//  Created by elahuo on 16/5/18.
//  Copyright © 2016年 elahuo.net. All rights reserved.
//

import UIKit
import ZXingObjC

protocol QRCodeDelegate: NSObjectProtocol {
    // 返回扫描结果的代理方法
    func didScanResults(result: String)
}

class QRCodeViewController: UIViewController, ZXCaptureDelegate {
    // 冲击波
    @IBOutlet weak var scanLine: UIImageView!
    // 冲击波顶部约束
    @IBOutlet weak var scanLineTopConstraint: NSLayoutConstraint!
    // 容器视图
    @IBOutlet weak var scanRectView: UIView!
    // 容器视图的高度
    @IBOutlet weak var containerHeight: NSLayoutConstraint!
    // 容器视图的宽度
    @IBOutlet weak var containerWidth: NSLayoutConstraint!
    // 显示结果的label
    @IBOutlet weak var resultLabel: UILabel!
    
    private var capture: ZXCapture? // 扫描捕捉者对象
    
    // 创建代理对象
    var delegate: QRCodeDelegate?
    
    
    
    // MARK: - 初始化
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 设置扫描区域的frame
        let width = scanRectView.frame.size.width
        let height = scanRectView.frame.size.height
        let x = (self.view.frame.size.width - width) * 0.5
        let y = (self.view.frame.size.height - height) * 0.5
        scanRectView.frame = CGRectMake(x, y, width, height)
        
        // 初始化扫描捕捉者
        self.capture = ZXCapture()
        self.capture!.camera = self.capture!.back()
        self.capture!.focusMode = .ContinuousAutoFocus
        self.capture!.rotation = 90.0
        self.capture!.layer.frame = self.view.bounds
        
        self.view.layer.addSublayer(self.capture!.layer)
        
        self.view.bringSubviewToFront(self.scanRectView)
        self.view.bringSubviewToFront(self.resultLabel)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.capture!.delegate = self
        self.capture!.layer.frame = self.view.bounds
        // 设置扫描范围
        self.capture!.scanRect = CGRectMake(scanRectView.frame.origin.x, scanRectView.frame.origin.y, scanRectView.frame.size.width, scanRectView.frame.size.height)
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        // 开启扫描动画
        self.startScanAnimation()
  
    }
    

    
    /**
     开始扫描动画
     */
    private func startScanAnimation() {

        // 1. 让冲击波初始化到顶部
        scanLineTopConstraint.constant = -containerHeight.constant
        view.layoutIfNeeded()
        
        // 2. 重复执行扫描动画
        UIView.animateWithDuration(2.0) { () -> Void in
            UIView.setAnimationRepeatCount(MAXFLOAT)
            self.scanLineTopConstraint.constant = self.containerHeight.constant
            self.view.layoutIfNeeded()
        }
    }

    
    // MARK: - ZXCaptureDelegate
    func captureResult(capture: ZXCapture, result: ZXResult) {
        if result.text == nil {
            return
        }
        
        resultLabel.text! = String(result.text)
        
        if result.text != nil {
            DevUtils.prints(self, content: "电子锁ID的扫描结果为:\(resultLabel.text!)")
            
            if (delegate != nil) {
                delegate?.didScanResults(resultLabel.text!)
            }
            
            
            // 退出扫描界面
            self.navigationController?.popViewControllerAnimated(true)
        }
    }
}


    
