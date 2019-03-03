//
//  ELHCarLevelTextField.m
//  ELaHuoSiJi
//
//  Created by elahuo on 16/3/15.
//  Copyright © 2016年 elahuo. All rights reserved.
//

#import "ELHCarLevelTextField.h"
//#import "ELHPickerView.h"

@interface ELHCarLevelTextField () <UIPickerViewDataSource, UIPickerViewDelegate>
/** 存放车辆级别的数组 */
@property (nonatomic, strong) NSArray *carLevelArray;
/** 记录选择位置 */
@property (nonatomic, assign) NSInteger selectedIndex;
@end

@implementation ELHCarLevelTextField
/** carLevelArray的懒加载 */
- (NSArray *)carLevelArray {
    if (_carLevelArray == nil) {
        _carLevelArray = [NSMutableArray array];
        _carLevelArray = @[@"面包车", @"小型厢货", @"2.8米-0.5吨", @"3.8米-1吨", @"4.2米-1.5吨", @"5.1米-3吨", @"6.1米-5吨", @"7.2米-8吨", @"8.1米-10吨", @"9.6米-15吨", @"12.5米-20吨", @"14.5米-30吨"];
    }
    return _carLevelArray;
}


// 对象只要从xib加载完成就会调用
- (void)awakeFromNib{
    // 自定义光标颜色
    self.tintColor = [UIColor lightGrayColor];
    
    [self setUp];
}

// 通过代码创建就调用下面的方法
- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self setUp];
    }
    return self;
}


// 初始化操作
- (void)setUp{
    UIPickerView *pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 0, ScreenW, ScreenH * 0.3)];

    pickerView.backgroundColor = ELHColor(206, 209, 217, 1);
    
    pickerView.dataSource = self;
    pickerView.delegate = self;

    // 初始化车辆级别数据,默认选中第一个
    self.text = self.carLevelArray[0];
    
    // 自定义车辆级别键盘
    self.inputView = pickerView;
}



#pragma nark - UIPickerViewDataSource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return self.carLevelArray.count;
}

#pragma mark - UIPickerViewDelegate
// 返回每一行的标题
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    return self.carLevelArray[row];
}

// 用户选中某一行的时候调用
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    
    self.text = self.carLevelArray[row];
    
}

// 初始化文本框文字
- (void)setUpText{
    [self pickerView:nil didSelectRow:0 inComponent:0];
}


@end
