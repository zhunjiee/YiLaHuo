//
//  ELHChildPayTableViewController.h
//  ELaHuo
//
//  Created by elahuo on 16/6/20.
//  Copyright © 2016年 elahuo. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ELHOrderDetailModel;
@class ELHOrderModel;

@protocol ELHChildPayTableViewControllerDelegate <NSObject>
- (void)getOriginalPrice:(NSString *)originalPrice ActualPrice:(NSString *)actualPrice andRedEnvelope:(NSString *)VCId;
@end

@interface ELHChildPayTableViewController : UITableViewController

@property (weak, nonatomic) IBOutlet UILabel *loadLabal; // 出发地
@property (weak, nonatomic) IBOutlet UILabel *unloadLabel; // 目的地
@property (weak, nonatomic) IBOutlet UILabel *mileageLabel; // 里程

@property (weak, nonatomic) IBOutlet UIButton *unloadPhoneButton; // 收货人电话

// 司机姓名
@property (weak, nonatomic) IBOutlet UILabel *dirverNameLabel;
// 司机电话
@property (weak, nonatomic) IBOutlet UILabel *dirverPhoneLabel;
// 车型
@property (weak, nonatomic) IBOutlet UILabel *carLevelLabel;
// 车牌号
@property (weak, nonatomic) IBOutlet UILabel *carNumberLabel;


// 司机报价
@property (weak, nonatomic) IBOutlet UILabel *dirverPriceLabel;
// 优惠券
@property (weak, nonatomic) IBOutlet UILabel *couponLabel;
// 实际价格
@property (weak, nonatomic) IBOutlet UILabel *actualPriceLabel;

/** 订单模型 */
@property (nonatomic, strong) ELHOrderModel *orderModel;
/** 竞价订单模型 */
@property (nonatomic, strong) ELHOrderDetailModel *orderDetailModel;

/**
 *  用于传递 真实价格 给父控制器的block
 */
@property (copy, nonatomic) void (^getActualPriceBlock)(NSString *);

/**
 *  用于传递 红包ID 给父控制器的block
 */
@property (copy, nonatomic) void (^getVCIdBlock)(NSString *);

@property (weak, nonatomic) id<ELHChildPayTableViewControllerDelegate> delegate;

@property (assign, nonatomic) BOOL isExecuteOrder; // 是执行订单,显示完整的司机电话
@end
