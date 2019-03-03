//
//  UIBarButtonItem+ELHPlaceholderColor.m
//  ELaHuo
//
//  Created by elahuo on 16/3/9.
//  Copyright © 2016年 elahuo. All rights reserved.
//

#import "UITextField+ELHPlaceholderColor.h"

@implementation UITextField (ELHPlaceholderColor)
static NSString *const BSPlaceholderColor = @"placeholderLabel.textColor";
- (void)setPlaceholderColor:(UIColor *)placeholderColor{
    if (placeholderColor == nil) {
        // 设置默认占位文字颜色
        [self setValue:[UIColor lightGrayColor] forKeyPath:BSPlaceholderColor];
    }else{
        // 保存之前的占位文字,因为之前可能没有占位文字,为了保证placeholderLabel被创建了,所以先 保存起来 再变成 空格
        NSString *placeholder = self.placeholder;
        self.placeholder = @" "; // 保证placeholderLabel被创建了
        
        [self setValue:placeholderColor forKeyPath:BSPlaceholderColor];
        
        // 恢复之前的占位文字
        self.placeholder = placeholder;
    }
}

- (UIColor *)placeholderColor{
    return [self valueForKeyPath:BSPlaceholderColor];
}
@end
