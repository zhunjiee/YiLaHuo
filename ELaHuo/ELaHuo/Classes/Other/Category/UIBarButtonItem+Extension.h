//
//  UIBarButtonItem+Extension.h
//  ElaHuo
//
//  Created by elahuo on 16/3/7.
//  Copyright © 2016年 elahuo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIBarButtonItem (Extension)

+ (instancetype)itemWithTarget:(id)target action:(SEL)action normalImage:(UIImage *)normalImage highlightImage:(UIImage *)highlightImage;

@end
