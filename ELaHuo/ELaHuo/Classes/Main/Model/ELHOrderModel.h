//
//  ELHOrderModel.h
//  ELaHuo
//
//  Created by elahuo on 16/3/25.
//  Copyright © 2016年 elahuo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ELHOrderModel : NSObject
/** 货主ID */
@property (nonatomic, copy) NSString *GOId;
/** 订单ID */
@property (nonatomic, copy) NSString *ROId;
/** 车主ID */
@property (nonatomic, copy) NSString *COId;

/** 电子锁编码 */
@property (nonatomic, copy) NSString *COMMCODE;
/** 订单编号 */
@property (nonatomic, copy) NSString *ROBM;

/** 装货地点 */
@property (nonatomic, copy) NSString *ROLoadSite;
/** 卸货地点 */
@property (nonatomic, copy) NSString *ROUnloadSite;
/** 发件人电话 */
@property (nonatomic, copy) NSString *COCLoadM;
/** 收件人电话 */
@property (nonatomic, copy) NSString *COCUnloadM;

/** 发布时间 */
@property (nonatomic, copy) NSString *COPublishTime;
/** 装货时间 */
@property (nonatomic, copy) NSString *ROLoadTime;
/** 支付时间 */
@property (nonatomic, copy) NSString *ROPayTime;

/** 订单状态 */
@property (nonatomic, assign) int ROState;

/** 订单价格 */
@property (nonatomic, assign) float ROPrice;
/** 车辆级别 */
@property (nonatomic, assign) int COCLevel;
/** 尾板 */
@property (nonatomic, assign) int ROIsWB;
/** 尾板 */
@property (nonatomic, assign) int ROCMNum;
/** 里程 */
@property (nonatomic, assign) double ROKM;
/** 解封密码 */
@property (nonatomic, copy) NSString *COPassword;

@end
