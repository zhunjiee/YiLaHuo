//
//  customHeaderView.swift
//  eLahuoForCar
//
//  Created by elahuo on 16/6/7.
//  Copyright © 2016年 elahuo.net. All rights reserved.
//

import UIKit

class customHeaderView: UITableViewHeaderFooterView {

    var lable: UILabel?
    
    
    // header的文字
    var text: String? {
        didSet {
            self.lable?.text = text
        }
    }
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        let tilButton: titleButton = titleButton()
        tilButton.frame.origin.x = 10
        tilButton.frame.size.width = 30
        tilButton.frame.size.height = 30
        tilButton.frame.origin.y = (self.frame.size.height - tilButton.frame.size.height) * 0.5
        
        let label = UILabel()
        label.font = UIFont.systemFontOfSize(17)
        label.textColor = UIColor.whiteColor()
        label.frame.origin.x = CGRectGetMaxX(tilButton.frame) + 5
        label.frame.size.width = 100
        label.autoresizingMask = .FlexibleHeight // 行高跟随父控件
        self.lable = label
        
        self.addSubview(tilButton)
        self.addSubview(label)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

