//
//  ELHHistoryOrderModel.m
//  ELaHuo
//
//  Created by elahuo on 16/4/6.
//  Copyright © 2016年 elahuo. All rights reserved.
//

#import "ELHHistoryOrderModel.h"
#import "ELHCarLevel.h"
#import "NSDate+Extension.h"

@implementation ELHHistoryOrderModel
// 时间
- (NSString *)ROLOADTIME {
    if (_ROLOADTIME != nil) {
        _ROLOADTIME = [_ROLOADTIME substringWithRange:NSMakeRange(0, 16)];
    }
    
    // 服务器返回时间
    // NSString 转 NSDate
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    fmt.dateFormat = @"yyyy-MM-dd HH:mm";
    NSDate *createAtDate = [fmt dateFromString:_ROLOADTIME];
    
    // 获取当前是系统时间
    NSDate *nowDate = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSInteger nowYear = [calendar component:NSCalendarUnitYear fromDate:nowDate];
    NSInteger createAtYear = [calendar component:NSCalendarUnitYear fromDate:createAtDate];
    
    if (nowYear == createAtYear) { // 今年
        if ([calendar isDateInToday:createAtDate]) { // 今天
            fmt.dateFormat = @"今天 HH:mm";
            return [fmt stringFromDate:createAtDate];
        } else if ([calendar isDateInYesterday:createAtDate]) { // 昨天
            fmt.dateFormat = @"昨天 HH:mm";
            return [fmt stringFromDate:createAtDate];
        } else if ([calendar isDateInTomorrow:createAtDate]) { // 明天
            fmt.dateFormat = @"明天 HH:mm";
            return [fmt stringFromDate:createAtDate];
        } else if (createAtDate.isTheDayAfterTomorrow) { // 后天
            fmt.dateFormat = @"后天 HH:mm";
            return [fmt stringFromDate:createAtDate];
        } else {
            fmt.dateFormat = @"MM月dd日 HH:mm";
            return [fmt stringFromDate:createAtDate];
        }
        
    }
    
    NSDateFormatter *fmt1 = [[NSDateFormatter alloc] init];
    fmt1.dateFormat = @"yyyy年MM月dd日 HH:mm";
    NSString *otherDateStr = [fmt1 stringFromDate:createAtDate];
    return otherDateStr;

}

// 车辆要求
- (NSString *)COCLEVEL {
    _COCLEVEL = [ELHCarLevel setUpCarLevel:_COCLEVEL];
    return _COCLEVEL;
}
@end
