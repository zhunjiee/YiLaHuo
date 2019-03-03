//
//  ELHDateTextField.m
//  ELaHuo
//
//  Created by elahuo on 16/3/10.
//  Copyright © 2016年 elahuo. All rights reserved.
//

#import "ELHDateTextField.h"

@implementation ELHDateTextField

- (void)setUp {
    // 创建日期选择控件
    UIDatePicker *datePicker = [[UIDatePicker alloc] init];
    // 设置日期格式
    datePicker.datePickerMode = UIDatePickerModeDate;
    // 设置日期地区
    datePicker.locale = [NSLocale localeWithLocaleIdentifier:@"zh"];
#pragma mark - 格式化输出日期
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    fmt.dateFormat = @"yyyy-MM-dd mm:ss";
    NSDate *date = [fmt dateFromString:@"1990-1-1 01:01"];
    
    // 设置开始日期
    datePicker.date = date;
    
    // 监听用户输入
    [datePicker addTarget:self action:@selector(dateChange:) forControlEvents:UIControlEventValueChanged];
    
    // 自定义文本框键盘
    self.inputView = datePicker;
}

// xib
- (void)awakeFromNib {
    [self setUp];
}
// 代码
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setUp];
    }
    return self;
}

// 时间改变事件
- (void)dateChange:(UIDatePicker *)datePicker {
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    fmt.dateFormat = @"yyyy-MM-dd mm:ss";
    NSString *dateString = [fmt stringFromDate:datePicker.date];
    self.text = dateString;
}

// 初始化文本框文字
- (void)setUpDate {
    [self dateChange:(UIDatePicker *)self.inputView];
}

@end
