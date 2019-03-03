//
//  MapConstants.swift
//  eLahuoForCar
//
//  Created by IcenHan on 16/4/4.
//  Copyright © 2016年 elahuo.net. All rights reserved.
//

import Foundation

public enum TextSelectorType {
    case VehicleLevel
}

class MapConstants: NSObject {
    static let sharedInstance = MapConstants()
    private override init() { }
    
    // 车辆级别
    let vehicleLevel = [
        (10,"面包车"),(11,"小型厢货"), (12,"2.8米-0.5吨"), (13,"3.8米-1吨"),
        (14,"4.2米-1.5吨"), (15,"5.1米-3吨"), (16,"6.1米-5吨"),
        (17,"7.2米-8吨"), (18,"8.1米-10吨"), (19,"9.6米-15吨"),
        (20, "12.5米-20吨"), (21, "14.5米-30吨")
    ]
    func valueConvertKey(value:String, converType:TextSelectorType) -> Int {
        switch converType {
        case .VehicleLevel:
            return self.valueConvKeyWithVehicleLevel(value)
        }
    }
    
    func keyConvertValue(key:Int, converType:TextSelectorType) -> String {
        switch converType {
        case .VehicleLevel:
            return self.keyConvValueWithVehicleLevel(key)
        }
    }
    
    private func valueConvKeyWithVehicleLevel(value:String) -> Int {
        for (k, v) in self.vehicleLevel {
            if v == value {
                return k
            }
        }
        return -1
    }
    
    private func keyConvValueWithVehicleLevel(key:Int) -> String {
        for (k, v) in self.vehicleLevel {
            if k == key {
                return v
            }
        }
        return "未知类型"
    }
}
