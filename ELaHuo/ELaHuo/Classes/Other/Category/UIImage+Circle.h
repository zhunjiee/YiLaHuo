//
//  UIImage+BSCircle.h
//  BaiSiBuDeJie
//
//  Created by 侯宝伟 on 15/11/4.
//  Copyright © 2015年 ZHUNJIEE. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (BSCircle)
/**
 *  生成圆形图片
 */
- (UIImage *)circleImage;

+ (instancetype)circleImageNamed:(NSString *)name;

@end
