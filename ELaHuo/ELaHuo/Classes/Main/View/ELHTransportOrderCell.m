//
//  ELHTransportOrderCell.m
//  ELaHuo
//
//  Created by elahuo on 16/3/31.
//  Copyright © 2016年 elahuo. All rights reserved.
//

#import "ELHTransportOrderCell.h"
#import "ELHOrderModel.h"
#import "ELHCarLevel.h"
#import "ELHViewController.h"

@interface ELHTransportOrderCell ()
// 价格
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
// 里程
@property (weak, nonatomic) IBOutlet UILabel *mileageLabel;
// 车辆级别
@property (weak, nonatomic) IBOutlet UILabel *carLevelLabel;

@end


@implementation ELHTransportOrderCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)setOrderModel:(ELHOrderModel *)orderModel {
    _orderModel = orderModel;
    
    self.priceLabel.text = [NSString stringWithFormat:@"￥%.2f", orderModel.ROPrice];
    self.mileageLabel.text = [NSString stringWithFormat:@"%.2fkm", orderModel.ROKM];
    self.carLevelLabel.text = [ELHCarLevel setUpCarLevel:[NSString stringWithFormat:@"%d", orderModel.COCLevel]];
}

/**
 *  发送解封密码给收货人
 */
- (IBAction)unblockButtonClick {
    
}

@end
