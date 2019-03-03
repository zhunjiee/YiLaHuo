//
//  ELHHistoryOrderCell.m
//  ELaHuo
//
//  Created by elahuo on 16/4/6.
//  Copyright © 2016年 elahuo. All rights reserved.
//

#import "ELHHistoryOrderCell.h"
#import "ELHHistoryOrderModel.h"

@interface ELHHistoryOrderCell ()
@property (weak, nonatomic) IBOutlet UILabel *timelabel;
@property (weak, nonatomic) IBOutlet UILabel *loadLabel;
@property (weak, nonatomic) IBOutlet UILabel *unloadLabel;
@property (weak, nonatomic) IBOutlet UILabel *mileageLabel;
@property (weak, nonatomic) IBOutlet UILabel *orderNumberLabel;


@end

@implementation ELHHistoryOrderCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


/**
 *  设置数据
 */
- (void)setHistoryOrderModel:(ELHHistoryOrderModel *)historyOrderModel {
    _historyOrderModel = historyOrderModel;
    
    self.timelabel.text = historyOrderModel.ROLOADTIME;
    self.loadLabel.text = historyOrderModel.ROLOADSITE;
    self.unloadLabel.text = historyOrderModel.ROUNLOADSITE;
    self.mileageLabel.text = [NSString stringWithFormat:@"%@公里", historyOrderModel.ROKM];
    self.orderNumberLabel.text = [NSString stringWithFormat:@"订单编号:%@", historyOrderModel.ROBM];
}

/**
 *  跳转到订单详情页
 */
- (IBAction)selectedButtonDidClick:(UIButton *)sender {
    
}


@end
