//
//  ELHPlaceholderTextField.m
//  ELaHuo
//
//  Created by elahuo on 16/3/9.
//  Copyright © 2016年 elahuo. All rights reserved.
//

#import "ELHPlaceholderTextField.h"
#import "UITextField+ELHPlaceholderColor.h"

@implementation ELHPlaceholderTextField

static NSString * const ELHPlaceholderColor = @"placeholderLabel.textColor";

- (void)awakeFromNib {
    // 自定义光标颜色
    self.tintColor = [UIColor lightGrayColor];
    
    // 设置占位文字颜色
    self.placeholderColor = [UIColor lightGrayColor];
}

- (BOOL)becomeFirstResponder{
    self.placeholderColor = [UIColor lightGrayColor];
    return [super becomeFirstResponder];
}

- (BOOL)resignFirstResponder{
    self.placeholderColor = [UIColor lightGrayColor];
    return [super resignFirstResponder];
}

@end
