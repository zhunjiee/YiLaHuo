//
//  ELHCarLevel.m
//  ELaHuo
//
//  Created by elahuo on 16/3/24.
//  Copyright © 2016年 elahuo. All rights reserved.
//

#import "ELHCarLevel.h"

@implementation ELHCarLevel
/**
 *  获取车辆的级别
 */
+ (NSString *)setUpCarLevel:(NSString *)level {

    if (level.intValue == 10) {
        return @"面包车";
    } else if (level.intValue == 11) {
        return @"小型厢货";
    } else if (level.intValue == 12) {
        return @"2.8米-0.5吨";
    } else if (level.intValue == 13) {
        return @"3.8米-1吨";
    } else if (level.intValue == 14) {
        return @"4.2米-1.5吨";
    } else if (level.intValue == 15) {
        return @"5.1米-3吨";
    } else if (level.intValue == 16) {
        return @"6.1米-5吨";
    } else if (level.intValue == 17) {
        return @"7.2米-8吨";
    } else if (level.intValue == 18) {
        return @"8.1米-10吨";
    } else if (level.intValue == 19) {
        return @"9.6米-15吨";
    } else if (level.intValue == 20) {
        return @"12.5米-20吨";
    } else if (level.intValue == 21) {
        return @"14.5米-30吨";
    } else {
        return @"未知";
    }

}

// 转换车辆级别为数字类型
+ (NSString *)exchangeCarLevel:(NSString *)level {
    if ([level  isEqualToString: @"面包车"]) {
        return @"10";
    } else if ([level  isEqualToString: @"小型厢货"]) {
        return @"11";
    } else if ([level isEqualToString:@"2.8米-0.5吨"]) {
        return @"12";
    } else if ([level isEqualToString:@"3.8米-1吨"]) {
        return @"13";
    } else if ([level isEqualToString:@"4.2米-1.5吨"]) {
        return @"14";
    } else if ([level isEqualToString:@"5.1米-3吨"]) {
        return @"15";
    } else if ([level isEqualToString:@"6.1米-5吨"]) {
        return @"16";
    } else if ([level isEqualToString:@"7.2米-8吨"]) {
        return @"17";
    } else if ([level isEqualToString:@"8.1米-10吨"]) {
        return @"18";
    } else if ([level isEqualToString:@"9.6米-15吨"]) {
        return @"19";
    } else if ([level isEqualToString:@"12.5米-20吨"]) {
        return @"20";
    } else if ([level isEqualToString:@"14.5米-30吨"]) {
        return @"21";
    }
    else {
        return @"";
    }
}
@end
