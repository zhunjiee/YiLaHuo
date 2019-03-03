//
//  ELHCarLevel.h
//  ELaHuo
//
//  Created by elahuo on 16/3/24.
//  Copyright © 2016年 elahuo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ELHCarLevel : NSObject

/**
 *  获取车辆的级别
 */
+ (NSString *)setUpCarLevel:(NSString *)level;

// 转换车辆级别为数字类型
+ (NSString *)exchangeCarLevel:(NSString *)level;

@end
