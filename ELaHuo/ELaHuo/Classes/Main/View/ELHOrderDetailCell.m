//
//  ELHOrderDetailCell.m
//  ELaHuo
//
//  Created by elahuo on 16/3/31.
//  Copyright © 2016年 elahuo. All rights reserved.
//

#import "ELHOrderDetailCell.h"
#import "ELHOrderDetailModel.h"
#import "ELHCarLevel.h"

@interface ELHOrderDetailCell ()
// 司机姓名
@property (weak, nonatomic) IBOutlet UILabel *dirverNameLabel;
// 车辆详情
@property (weak, nonatomic) IBOutlet UILabel *carLevelLabel;
// 尾板/侧门
@property (weak, nonatomic) IBOutlet UILabel *slideDoorLabel;
// 司机报价
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;

@property (weak, nonatomic) IBOutlet UIImageView *star1;
@property (weak, nonatomic) IBOutlet UIImageView *star2;
@property (weak, nonatomic) IBOutlet UIImageView *star3;
@property (weak, nonatomic) IBOutlet UIImageView *star4;
@property (weak, nonatomic) IBOutlet UIImageView *star5;
@property (weak, nonatomic) IBOutlet UILabel *noStarLabel; // 暂无星级

@end

@implementation ELHOrderDetailCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)setOrderDetailModel:(ELHOrderDetailModel *)orderDetailModel {
    _orderDetailModel = orderDetailModel;
    
    // 车主姓名
    NSString *dirverName;
    if (orderDetailModel.COName.length > 3) {
        dirverName = [orderDetailModel.COName substringWithRange:NSMakeRange(0, 2)];
    } else {
        dirverName = [orderDetailModel.COName substringWithRange:NSMakeRange(0, 1)];
    }
    self.dirverNameLabel.text = [NSString stringWithFormat:@"%@师傅", dirverName];
    
    // 车辆级别
    self.carLevelLabel.text = [ELHCarLevel setUpCarLevel:orderDetailModel.COCLEVEL];
    
    if ([orderDetailModel.COCISWB isEqual:@"1"] && [orderDetailModel.COCCMNUM isEqual:@"1"]) {
        self.slideDoorLabel.text = @"尾板/侧门";
    } else if ([orderDetailModel.COCISWB isEqual:@"1"] && [orderDetailModel.COCCMNUM isEqual:@"0"]) {
        self.slideDoorLabel.text = @"尾板";
    } else if ([orderDetailModel.COCISWB isEqual:@"0"] && [orderDetailModel.COCCMNUM isEqual:@"1"]) {
        self.slideDoorLabel.text = @"侧门";
    } else {
        self.slideDoorLabel.text = @"";
    }
    
    // 车主报价
    self.priceLabel.text = [NSString stringWithFormat:@"%.0f元", [orderDetailModel.Price floatValue]];
    
    // 司机星级
    if ([self.orderDetailModel.COPJStar floatValue] == 0) {
        [self.star1 setImage:[UIImage imageNamed:@"Star_deselected"]];
        [self.star2 setImage:[UIImage imageNamed:@"Star_deselected"]];
        [self.star3 setImage:[UIImage imageNamed:@"Star_deselected"]];
        [self.star4 setImage:[UIImage imageNamed:@"Star_deselected"]];
        [self.star5 setImage:[UIImage imageNamed:@"Star_deselected"]];
        
    } else if ([self.orderDetailModel.COPJStar floatValue] == 1) {
        [self.star1 setImage:[UIImage imageNamed:@"Star_selected"]];
        [self.star2 setImage:[UIImage imageNamed:@"Star_deselected"]];
        [self.star3 setImage:[UIImage imageNamed:@"Star_deselected"]];
        [self.star4 setImage:[UIImage imageNamed:@"Star_deselected"]];
        [self.star5 setImage:[UIImage imageNamed:@"Star_deselected"]];
        
    } else if ([self.orderDetailModel.COPJStar floatValue] == 2) {
        [self.star1 setImage:[UIImage imageNamed:@"Star_selected"]];
        [self.star2 setImage:[UIImage imageNamed:@"Star_selected"]];
        [self.star3 setImage:[UIImage imageNamed:@"Star_deselected"]];
        [self.star4 setImage:[UIImage imageNamed:@"Star_deselected"]];
        [self.star5 setImage:[UIImage imageNamed:@"Star_deselected"]];
        
    } else if ([self.orderDetailModel.COPJStar floatValue] == 3) {
        [self.star1 setImage:[UIImage imageNamed:@"Star_selected"]];
        [self.star2 setImage:[UIImage imageNamed:@"Star_selected"]];
        [self.star3 setImage:[UIImage imageNamed:@"Star_selected"]];
        [self.star4 setImage:[UIImage imageNamed:@"Star_deselected"]];
        [self.star5 setImage:[UIImage imageNamed:@"Star_deselected"]];
        
    } else if ([self.orderDetailModel.COPJStar floatValue] == 4) {
        [self.star1 setImage:[UIImage imageNamed:@"Star_selected"]];
        [self.star2 setImage:[UIImage imageNamed:@"Star_selected"]];
        [self.star3 setImage:[UIImage imageNamed:@"Star_selected"]];
        [self.star4 setImage:[UIImage imageNamed:@"Star_selected"]];
        [self.star5 setImage:[UIImage imageNamed:@"Star_deselected"]];
        
    } else if ([self.orderDetailModel.COPJStar floatValue] == 5) {
        [self.star1 setImage:[UIImage imageNamed:@"Star_selected"]];
        [self.star2 setImage:[UIImage imageNamed:@"Star_selected"]];
        [self.star3 setImage:[UIImage imageNamed:@"Star_selected"]];
        [self.star4 setImage:[UIImage imageNamed:@"Star_selected"]];
        [self.star5 setImage:[UIImage imageNamed:@"Star_selected"]];
        
    }
}
@end
