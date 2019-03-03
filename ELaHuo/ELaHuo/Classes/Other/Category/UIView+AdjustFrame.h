//
//  UIView+AdjustFrame.h
//  QQ_Zone
//
//  Created by apple on 14-12-7.
//  Copyright (c) 2014年 itcast. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (AdjustFrame)
/** X值 */
@property (assign, nonatomic) CGFloat x;
/** Y值 */
@property (assign, nonatomic) CGFloat y;
/** 宽度 */
@property (assign, nonatomic) CGFloat width;
/** 高度 */
@property (assign, nonatomic) CGFloat height;

@property (assign, nonatomic) CGSize size;

@property (assign, nonatomic) CGPoint origin;

/** centerX */
@property (nonatomic, assign) CGFloat centerX;
/** centerY */
@property (nonatomic, assign) CGFloat centerY;
@end
