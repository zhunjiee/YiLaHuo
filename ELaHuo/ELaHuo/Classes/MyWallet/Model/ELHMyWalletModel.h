//
//  ELHMyWalletModel.h
//  ELaHuo
//
//  Created by elahuo on 16/4/7.
//  Copyright © 2016年 elahuo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ELHMyWalletModel : NSObject
/** 红包ID */
@property (nonatomic, copy) NSString *VCId;
/** 金额 */
@property (nonatomic, copy) NSString *VCAmount;
/** 满多少可用 */
@property (nonatomic, copy) NSString *VCFullAmount;
/** 限期 */
@property (nonatomic, copy) NSString *VCTerm;
/** 获取日期 */
@property (nonatomic, copy) NSString *VCGetTime;

@end
