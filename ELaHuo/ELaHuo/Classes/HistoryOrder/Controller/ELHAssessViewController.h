//
//  ELHAssessViewController.h
//  ELaHuo
//
//  Created by elahuo on 16/5/16.
//  Copyright © 2016年 elahuo. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ELHHistoryOrderModel;

@interface ELHAssessViewController : UIViewController
/** 历史订单模型 */
@property (nonatomic, strong) ELHHistoryOrderModel *HistoryOrder;
@property (nonatomic, strong) NSString *COId;
@property (nonatomic, strong) NSString *ROId;
@end
