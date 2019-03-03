//
//  ELHConst.m
//  ELaHuo
//
//  Created by 侯宝伟 on 16/3/7.
//  Copyright © 2016年 elahuo. All rights reserved.
//

#import <UIKit/UIKit.h>

/** 请求路径 */
NSString * const ELHBaseURL = @"http://120.76.24.17:8080/elahuoms/";
//NSString * const ELHBaseURL = @"http://192.168.10.107:8080/elahuoms/";
/** 导航栏的Y值 */
CGFloat const ELHNavY = 64;
/** 订单的高度 */
CGFloat const ELHOrderH = 90;
/** 折叠视图的高度 */
CGFloat const ELHFoldViewH = 25;
/** 竞价列表的高度 */
CGFloat const ELHBiddingOrderH = 44;
/** 大头像的宽度 */
CGFloat const ELHHeaderWidth = 60;


/** 注册成功的通知 */
NSString * const ELHRegisterSuccessNotification = @"ELHRegisterSuccessNotification";

/** 登录成功的通知 */
NSString * const ELHLoginSuccessNotification = @"ELHLoginSuccessNotification";

/** 退出登录的通知 */
NSString * const ELHCancelLoginNotification = @"ELHCancelLoginNotification";


/** 订单按钮被点击的通知 */
NSString * const ELHorderButtonDidClickNotification = @"ELHorderButtonDidClickNotification";

/** 发货成功的通知 */
NSString * const ELHDeliverSuccessNotification = @"ELHDeliverSuccessNotification";

/** 取消订单的通知 */
NSString * const ELHcancelOrderButtonClickNotification = @"ELHcancelOrderButtonClickNotification";

/** 确认送达的通知 */
NSString * const ELHConfirmServiceNotification = @"ELHConfirmServiceNotification";

/** 支付完成的通知 */
NSString * const ELHcomplePayNotification = @"ELHcomplePayNotification";

/** 评价成功的通知 */
NSString * const ELHAssessSuccessNotification = @"ELHAssessSuccessNotification";


/** 收到订单完成自定义消息的通知 */
NSString * const JumpToHistoryOrderViewNotification = @"JumpToHistoryOrderViewNotification";


/** 收到已通知司机自定义消息的通知 */
NSString * const NoticeDirverNotification = @"NoticeDirverNotification";

/** 收到强制登出自定义消息的通知 */
NSString * const forceLogoutNotification = @"forceLogoutNotification";

