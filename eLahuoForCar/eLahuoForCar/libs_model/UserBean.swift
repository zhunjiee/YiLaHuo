//
//  UserBean.swift
//  eLahuoForCar
//
//  Created by IceHan on 16/4/1.
//  Copyright © 2016年 elahuo.net. All rights reserved.
//

import Foundation

struct UserBeanField {
    static let userId = "userId"
    static let phoneNum = "phoneNum"
    static let loginPsd = "loginPsd"
    static let isFinishAutRealName = "isFinishAutRealName"
    static let isFinishAutCar = "isFinishAutCar"
    static let elockNum = "elockNum"
    static let soleTag = "soleTag"
    static let starLevel = "starLevel"
    static let carLevel = "COCLevel"
}

class UserBean: NSObject {
    static let sharedInstance = UserBean()
    
    var userId: String!
    var phoneNum: String!
    var loginPsd: String!
    var isFinishAutRealName: Bool!
    var isFinishAutCar: Bool!
    var elockNum: String!
    var soleTag: String!
    var starLevel: String!
    var carLevel: String!
    

    private override init() {
        super.init()
        
        let mUserDefaults = NSUserDefaults.standardUserDefaults()
        self.userId = mUserDefaults.stringForKey(UserBeanField.userId)
        self.phoneNum = mUserDefaults.stringForKey(UserBeanField.phoneNum)
        self.loginPsd = mUserDefaults.stringForKey(UserBeanField.loginPsd)
        self.isFinishAutRealName = mUserDefaults.boolForKey(UserBeanField.isFinishAutRealName)
        self.isFinishAutCar = mUserDefaults.boolForKey(UserBeanField.isFinishAutCar)
        self.elockNum = mUserDefaults.stringForKey(UserBeanField.elockNum)
        self.soleTag = mUserDefaults.stringForKey(UserBeanField.soleTag)
        self.starLevel = mUserDefaults.stringForKey(UserBeanField.starLevel)
        self.carLevel = mUserDefaults.stringForKey(UserBeanField.carLevel)
    }
    
    func isLoging() -> Bool {
        if (self.userId != nil) && !(self.userId.isEmpty) {
            return true
        }
        return false
    }
    
    func save() {
        let mUserDefaults = NSUserDefaults.standardUserDefaults();
        mUserDefaults.setObject(self.userId, forKey: UserBeanField.userId)
        mUserDefaults.setObject(self.phoneNum, forKey: UserBeanField.phoneNum)
        mUserDefaults.setObject(self.loginPsd, forKey: UserBeanField.loginPsd)
        mUserDefaults.setBool(self.isFinishAutRealName, forKey: UserBeanField.isFinishAutRealName)
        mUserDefaults.setBool(self.isFinishAutCar, forKey: UserBeanField.isFinishAutCar)
        mUserDefaults.setObject(self.elockNum, forKey: UserBeanField.elockNum)
        mUserDefaults.setObject(self.soleTag, forKey: UserBeanField.soleTag)
        mUserDefaults.setObject(self.starLevel, forKey: UserBeanField.starLevel)
        mUserDefaults.setObject(self.carLevel, forKey: UserBeanField.carLevel)
    }
}