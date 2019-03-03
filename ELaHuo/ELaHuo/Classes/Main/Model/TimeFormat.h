//
//  TimeFormat.h
//  ELaHuo
//
//  Created by elahuo on 16/6/28.
//  Copyright © 2016年 elahuo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TimeFormat : NSObject

// 处理装货时间的格式
+ (NSString *)ROLoadTimeDateFormat:(NSString *)ROLoadTime;

@end
