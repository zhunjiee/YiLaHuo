//
//  titleButton.swift
//  eLahuoForCar
//
//  Created by elahuo on 16/6/7.
//  Copyright © 2016年 elahuo.net. All rights reserved.
//

import UIKit

class titleButton: UIButton {

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // 高亮状态不改变图片颜色
        adjustsImageWhenHighlighted = false
        setImage(UIImage(named: "indicator_off"), forState: .Normal)
        setImage(UIImage(named: "indicator_on"), forState: .Selected)
        
        sizeToFit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
