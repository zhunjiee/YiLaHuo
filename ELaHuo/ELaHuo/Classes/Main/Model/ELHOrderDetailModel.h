//
//  ELHOrderDetailModel.h
//  ELaHuo
//
//  Created by elahuo on 16/3/30.
//  Copyright © 2016年 elahuo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ELHOrderDetailModel : NSObject
/** 车辆级别 */
@property (nonatomic, copy) NSString *COCLEVEL;
/** 车主ID */
@property (nonatomic, copy) NSString *COId;
/** 车主姓名 */
@property (nonatomic, copy) NSString *COName;
/** 车主电话 */
@property (nonatomic, copy) NSString *COMobile;
/** 订单价格/车主报价 */
@property (nonatomic, copy) NSString *Price;
/** 尾板 */
@property (nonatomic, copy) NSString *COCISWB;
/** 侧门 */
@property (nonatomic, copy) NSString *COCCMNUM;
/** 星级评价 */
@property (nonatomic, copy) NSString *COPJStar;
/** 车牌号 */
@property (nonatomic, copy) NSString *COCPLATENUMBER;
/** 支付ID */
@property (nonatomic, copy) NSString *OPId;
@end
