//
//  FormModel.swift
//  eLahuoForCar
//
//  Created by IceHan on 16/4/6.
//  Copyright © 2016年 elahuo.net. All rights reserved.
//

import Foundation

class FormModel: NSObject {
    var mainId: String? // 主键
    var userId: String? // 用户ID
    var goodsId: String? // 货主ID
    var statusCode: Int? // 状态码
    var formId: String? // 订单编号
    var priceId: String? // 报价ID
    
    var loadAddress: String? // 装货地点
    var loadLongitude: Double? // 装货经度
    var loadLatitude: Double? // 装货纬度
    var loadTime: String? { // 装货时间
        didSet {
            let fmt = NSDateFormatter()
            fmt.dateFormat = "yyyy-MM-dd HH:mm:ss"
            // 服务器返回时间
            let createAtTime = fmt.dateFromString(loadTime!)
            // 系统当前时间
            let nowDate = NSDate()
            // 日历对象
            let calendar = NSCalendar.currentCalendar()
            
            let nowYear = calendar.component(.Year, fromDate: nowDate)
            let createAtYear = calendar.component(.Year, fromDate: createAtTime!)
            
            if nowYear == createAtYear { // 今年
                if calendar.isDateInToday(createAtTime!) {
                    fmt.dateFormat = "今天 HH:mm"
                    loadTime = fmt.stringFromDate(createAtTime!)
                } else if calendar.isDateInTomorrow(createAtTime!) {
                    fmt.dateFormat = "明天 HH:mm"
                    loadTime = fmt.stringFromDate(createAtTime!)
                } else {
                    fmt.dateFormat = "MM月dd日 HH:mm"
                    loadTime = fmt.stringFromDate(createAtTime!)
                }
            } else {
                fmt.dateFormat = "yyyy年MM月dd日 HH:mm"
                loadTime = fmt.stringFromDate(createAtTime!)
            }
        }
    }
    var loadLinkmanPhone: String? // 装货联系人电话
    var tailBoard: Bool? // 尾板
    var slideDoor: Bool? // 侧门
    
    var unloadAddress: String? // 卸货地点
    var unloadLongitude: Double? // 卸货经度
    var unloadLatitiude: Double? // 卸货纬度
    var unloadLinkmanPhone: String? // 卸货联系人电话
    
    var routeMiles: Double? // 里程
    var vehicleLevel: Int? // 车辆等级
    
    var publishTime: String? // 发布日期
    
    var freePrice: Double? // 报价价格
    var dealPrice: Double? // 成交价格
    var freePriceMax: String? // 最高报价
    var freePriceMin: String? // 最低报价
    var freePriceAverage: String? // 平均报价
    var freePriceManNum: Int? // 报价人数
    
    var unlockPassword: String? // 解封密码
}
