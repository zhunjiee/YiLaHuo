//
//  ELHDirverInfoModel.h
//  ELaHuo
//
//  Created by elahuo on 16/6/19.
//  Copyright © 2016年 elahuo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ELHDirverInfoModel : NSObject
/** 车主ID */
@property (nonatomic, copy) NSString *COId;
/** 车主姓名 */
@property (nonatomic, copy) NSString *COName;
/** 车主电话 */
@property (nonatomic, copy) NSString *COMobile;
/** 车牌号 */
@property (nonatomic, copy) NSString *COCPLATENUMBER;
/** 车辆级别 */
@property (nonatomic, copy) NSString *COCLEVEL;
/** 尾板 */
@property (nonatomic, copy) NSString *COCISWB;
/** 侧门 */
@property (nonatomic, copy) NSString *COCCMNUM;
/** 星级评价 */
@property (nonatomic, copy) NSString *COPJStar;

@end
