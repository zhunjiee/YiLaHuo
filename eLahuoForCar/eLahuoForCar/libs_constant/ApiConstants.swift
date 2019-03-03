//
//  ApiContants.swift
//  eLahuoForCar
//
//  Created by IcenHan on 16/3/27.
//  Copyright © 2016年 elahuo.net. All rights reserved.
//

import Foundation

class ApiContants {
    // 电子锁施封
    static let BASE_ELOCK_HOST = "120.76.24.17"
    
    // 服务器地址
    private static let BASE_URL_PROJECT = "http://120.76.24.17:8080/elahuoms/"
    // 本地测试地址
//    private static let BASE_URL_PROJECT = "http://192.168.10.107:8080/elahuoms/"
    
    // 注册
    static let URL_POST_REGISTER = ApiContants.BASE_URL_PROJECT + "CarOwner_registerCO.action"
    
    // 登录
    static let URL_POST_LOGIN = ApiContants.BASE_URL_PROJECT + "CarOwner_loginCO.action"
    
    // 实名认证
    static let URL_POST_AUT_REAL_NAME = ApiContants.BASE_URL_PROJECT + "CarOwner_updateCO.action"
    // 获取实名认证信息
    static let URL_GET_AUT_REAL_NAME = ApiContants.BASE_URL_PROJECT + "CarOwner_getCOInfoById.action"
    
    // 车辆认证
    static let URL_POST_AUT_CAR = ApiContants.BASE_URL_PROJECT + "COCars_registerCOC.action"
    // 获取车辆认证信息
    static let URL_GET_AUT_CAR = ApiContants.BASE_URL_PROJECT + "COCars_getCOCByCOId.action"
    
    // 图片上传
    static let URL_POST_IMAGE = ApiContants.BASE_URL_PROJECT + "file/UploadServlet"
    // 获取图片
    static let URL_GET_IMAGE = ApiContants.BASE_URL_PROJECT + "file/DownLoadServlet"
    
    // 查询钱包余额
    static let URL_GET_WALLET_BALANCE = ApiContants.BASE_URL_PROJECT + "Purse_queryPurse.action"
    // 查询钱包历史
    static let URL_GET_WALLET_HISTORY = ApiContants.BASE_URL_PROJECT + "Purse_getHistoryPurse.action"
    // 申请提现
    static let URL_GET_WALLET_FETCH = ApiContants.BASE_URL_PROJECT + "Purse_withoutPurse.action"
    
    // 获取未接订单
    static let URL_GET_FORM_NOT = ApiContants.BASE_URL_PROJECT + "RealtimeOrder_getROListCon123CO.action"
    // 获取已报价订单
    static let URL_GET_FORM_ING = ApiContants.BASE_URL_PROJECT + "RealtimeOrder_getROListConOnPrice.action"
    // 获取已接订单
    static let URL_GET_FORM_END = ApiContants.BASE_URL_PROJECT + "RealtimeOrder_getROListCon45.action"
    // 获取历史订单
    static let URL_GET_FORM_HISTORY = ApiContants.BASE_URL_PROJECT + "HistoryOrder_getOrderByCOId.action"
    
    // 订单报价
    static let URL_POST_FORM_SUBMIT_PRICE = ApiContants.BASE_URL_PROJECT + "OrderPrice_addOP.action"
    // 取消报价
    static let URL_POST_FORM_CANCEL_PRICE = ApiContants.BASE_URL_PROJECT + "OrderPrice_updateOP.action"
    
    // 拍照施封
    static let URL_POST_FORM_CAMERA_LOCK = ApiContants.BASE_URL_PROJECT + "RealtimeOrder_updateROLockPictre.action"
    
    // 确认送达
    static let URL_POST_FORM_SUBMIT_FINISH = ApiContants.BASE_URL_PROJECT + "Purse_finishPurse.action"
}