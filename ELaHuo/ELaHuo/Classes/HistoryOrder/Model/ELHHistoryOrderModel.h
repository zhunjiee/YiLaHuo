//
//  ELHHistoryOrderModel.h
//  ELaHuo
//
//  Created by elahuo on 16/4/6.
//  Copyright © 2016年 elahuo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ELHHistoryOrderModel : NSObject
/** 货主ID */
@property (nonatomic, copy) NSString *COID;
/** 订单主键 */
@property (nonatomic, copy) NSString *ROID;
/** 里程 */
@property (nonatomic, copy) NSString *ROKM;
/** 订单状态 */
@property (nonatomic, copy) NSString *ROSTATE;
/** 装货地点 */
@property (nonatomic, copy) NSString *ROLOADSITE;
/** 卸货地点 */
@property (nonatomic, copy) NSString *ROUNLOADSITE;
/** 装货电话 */
@property (nonatomic, copy) NSString *COCLOADM;
/** 卸货电话 */
@property (nonatomic, copy) NSString *COCUNLOADM;

/** 装货时间 */
@property (nonatomic, copy) NSString *ROLOADTIME;
/** 车辆要求 */
@property (nonatomic, copy) NSString *COCLEVEL;

/** 订单编号 */
@property (nonatomic, copy) NSString *ROBM;
@end
