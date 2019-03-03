//
//  UIImage+BSCircle.m
//  BaiSiBuDeJie
//
//  Created by 侯宝伟 on 15/11/4.
//  Copyright © 2015年 ZHUNJIEE. All rights reserved.
//

#import "UIImage+Circle.h"

@implementation UIImage (BSCircle)

- (UIImage *)circleImage{
    // 开启位图上下文
    UIGraphicsBeginImageContextWithOptions(self.size, NO, 0);
    // 获取位图上下文
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // 设置区域
    CGRect rect = {CGPointZero, self.size};
    // 画圆
    CGContextAddEllipseInRect(context, rect);
    // 剪裁
    CGContextClip(context);
    
    // 将图片画到圆上
    [self drawInRect:rect];
    
    // 取出图片
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    // 关闭位图上下文
    UIGraphicsEndImageContext();
    
    return image;
}

+ (instancetype)circleImageNamed:(NSString *)name{
    return [[self imageNamed:name] circleImage];
}

@end
