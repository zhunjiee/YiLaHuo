//
//  AssessView.swift
//  eLahuoForCar
//
//  Created by elahuo on 16/5/30.
//  Copyright © 2016年 elahuo.net. All rights reserved.
//

import UIKit

class AssessView: UIViewController, UITextViewDelegate, RatingBarDelegate {
    // 评价等级文字
    @IBOutlet weak var assessLevelLabel: UILabel!
    // 占位文字
    @IBOutlet weak var placeholderLabel: UILabel!
    // 文本框
    @IBOutlet weak var textView: UITextView!
    // 评价星星
    private var ratingBar: RatingBar?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setUpRatingStar()
    }

    /**
     初始化评价星星
     */
    func setUpRatingStar() {
        let width: CGFloat = self.view.frame.size.width * 0.7
        let x: CGFloat = (self.view.frame.size.width - width) * 0.5
        
        self.ratingBar = RatingBar.init(frame: CGRectMake(x, 30, width, 30))
        self.view.addSubview(self.ratingBar!)
        self.ratingBar?.setImageDeselected("iconfont-xingunselected", halfSelected: nil, fullSelected: "iconfont-xing_yellow", andDelegate: self)
        
        
    }
    
    
    /**
     确认评价
     */
    @IBAction func confirmAssess(sender: UIButton) {
        if self.assessLevelLabel.text!.isEmpty {
            ToastHub.sharedInstance.showHubWithLoad(self.view, text: "请选择一个星级再确认评级吧!")
        } else {
            ToastHub.sharedInstance.showHubWithLoad(self.view, text: "评价成功")
            sender.setTitle("评价成功", forState: .Normal)
            self.textView.userInteractionEnabled = false
            self.ratingBar?.userInteractionEnabled = false
            self.navigationController?.popViewControllerAnimated(true)
        }
        
    }
    
    
    // MARK: - RatingBar delegate
    func ratingBar(ratingBar: RatingBar!, ratingChanged newRating: Float) {
        switch newRating {
        case 0:
            self.assessLevelLabel.text = nil
        case 1:
            self.assessLevelLabel.text = "差评"
        case 2:
            self.assessLevelLabel.text = "很一般"
        case 3:
            self.assessLevelLabel.text = "中评"
        case 4:
            self.assessLevelLabel.text = "好评"
        case 5:
            self.assessLevelLabel.text = "非常满意"
        default:
            self.assessLevelLabel.text = nil
        }
    }
    
    
    //MARK: - UITextViewDelegate
    func textViewDidBeginEditing(textView: UITextView) {
        if self.textView.text.isEmpty {
            self.placeholderLabel.hidden = false
        } else {
            self.placeholderLabel.hidden = true
        }
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        if self.textView.text.isEmpty {
            self.placeholderLabel.hidden = false
        } else {
            self.placeholderLabel.hidden = true
        }
    }
    
    func textViewDidChange(textView: UITextView) {
        if self.textView.text.isEmpty {
            self.placeholderLabel.hidden = false
        } else {
            self.placeholderLabel.hidden = true
        }
    }
}
