//
//  NSString+Regular.m
//  ELaHuo
//
//  Created by elahuo on 16/3/10.
//  Copyright © 2016年 elahuo. All rights reserved.
//

#import "NSString+Regular.h"

@implementation NSString (Regular)
/**
 *  手机号码正则匹配
 */
-(BOOL)checkPhoneNumInput{
    
    
    // 移动,联通,电信
    NSString * MOBILE = @"^1(3[0-9]|5[0-35-9]|7[0-9]|8[0-9])\\d{8}$";
    
    
    // 移动
    NSString * CM = @"^1(34[0-8]|(3[5-9]|5[017-9]|8[278])\\d)\\d{7}$";
    
    
    // 联通
    NSString * CU = @"^1(3[0-2]|5[256]|8[56])\\d{8}$";
    
    
    // 电信
    NSString * CT = @"^1((33|53|8[09])[0-9]|349)\\d{7}$";
    
    
    
    // NSString * PHS = @"^0(10|2[0-5789]|\\d{3})\\d{7,8}$";
    
    
    
    NSPredicate *regextestmobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", MOBILE];
    
    NSPredicate *regextestcm = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CM];
    
    NSPredicate *regextestcu = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CU];
    
    NSPredicate *regextestct = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CT];
    
    BOOL res1 = [regextestmobile evaluateWithObject:self];
    
    BOOL res2 = [regextestcm evaluateWithObject:self];
    
    BOOL res3 = [regextestcu evaluateWithObject:self];
    
    BOOL res4 = [regextestct evaluateWithObject:self];
    
    
    
    if (res1 || res2 || res3 || res4 )
        
    {
        
        return YES;
        
    }
    
    else
        
    {
        
        return NO;
        
    }
    
}

@end
