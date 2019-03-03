//
//  MathUtilsswift.swift
//  eLahuoForCar
//
//  Created by IceHan on 16/3/28.
//  Copyright © 2016年 elahuo.net. All rights reserved.
//

import Foundation

class MathUtils: NSObject {
    
    static let sharedInstance = MathUtils()
    
    private override init() { }
    
    /**
     生成随机数
     
     - parameter min: 最小值
     - parameter max: 最大值
     
     - returns: Int
     */
    func random(min:UInt32, max:UInt32) -> Int {
        let result:UInt32 = arc4random_uniform(max - min) + min
        return Int(result)
    }
    
}