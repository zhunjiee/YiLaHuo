//
//  ELHConst.h
//  ELaHuo
//
//  Created by 侯宝伟 on 16/3/7.
//  Copyright © 2016年 elahuo. All rights reserved.
//

#import <UIKit/UIKit.h>

/** 请求路径 */
UIKIT_EXTERN NSString * const ELHBaseURL;

/** 导航栏的Y值 */
UIKIT_EXTERN CGFloat const ELHNavY;
/** 普通订单的高度 */
UIKIT_EXTERN CGFloat const ELHOrderH;
/** 折叠视图的高度 */
UIKIT_EXTERN CGFloat const ELHFoldViewH;
/** 执行状态订单的高度 */
UIKIT_EXTERN CGFloat const ELHExecuteOrderH;
/** 竞价列表的高度 */
UIKIT_EXTERN CGFloat const ELHBiddingOrderH;
/** 大头像的宽度 */
UIKIT_EXTERN CGFloat const ELHHeaderWidth;



/** 注册成功的通知 */
UIKIT_EXTERN NSString * const ELHRegisterSuccessNotification;

/** 登录成功的通知 */
UIKIT_EXTERN NSString * const ELHLoginSuccessNotification;

/** 退出登录的通知 */
UIKIT_EXTERN NSString * const ELHCancelLoginNotification;


/** 订单按钮被点击的通知 */
UIKIT_EXTERN NSString * const ELHorderButtonDidClickNotification;

/** 发货成功的通知 */
UIKIT_EXTERN NSString * const ELHDeliverSuccessNotification;

/** 取消订单的通知 */
UIKIT_EXTERN NSString * const ELHcancelOrderButtonClickNotification;

/** 确认送达的通知 */
UIKIT_EXTERN NSString * const ELHConfirmServiceNotification;

/** 评价成功的通知 */
UIKIT_EXTERN NSString * const ELHAssessSuccessNotification;

/** 支付完成的通知 */
UIKIT_EXTERN NSString * const ELHcomplePayNotification;


/** 收到订单完成自定义消息的通知 */
UIKIT_EXTERN NSString * const JumpToHistoryOrderViewNotification;


/** 收到已通知司机自定义消息的通知 */
UIKIT_EXTERN NSString * const NoticeDirverNotification;


/** 收到强制登出自定义消息的通知 */
UIKIT_EXTERN NSString * const forceLogoutNotification;

