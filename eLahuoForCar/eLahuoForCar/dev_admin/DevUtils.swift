//
//  DevUtils.swift
//  eLahuoForCar
//
//  Created by eLahuo on 16/3/28.
//  Copyright © 2016年 elahuo.net. All rights reserved.
//

import Foundation

class DevUtils: NSObject {
    
    /**
     打印日志
     
     - parameter cls:     当前类
     - parameter content: 日志内容
     */
    class func prints(cls:NSObject, content:NSObject){
        prints(nil, cls: cls, content: content)
    }
    
    /**
     打印日志
     
     - parameter remark:  标签
     - parameter cls:     当前类
     - parameter content: 日志内容
     */
    class func prints(remark:NSObject?, cls:NSObject, content:NSObject) {
        if !DevConstants.isPrint { return }
        
        let printTitle = "---------- \(cls.description) ----------\n"
        
        let lineCount = (printTitle.characters.count - 5) / 2
        var line = ""
        for _ in 1...lineCount {
            line += "-"
        }
        let printEnd = "\n\(line) END \(line)"
        
        var printContent = ""
        if let remarkContent = remark?.description {
            printContent += "[\(remarkContent)]>>>"
        }
        printContent += content.description
        
        print(printTitle + printContent + printEnd)
    }
}