//
//  ELHMyWalletCell.m
//  ELaHuo
//
//  Created by elahuo on 16/4/6.
//  Copyright © 2016年 elahuo. All rights reserved.
//

#import "ELHMyWalletCell.h"
#import "ELHMyWalletModel.h"

@interface ELHMyWalletCell ()
// 金额
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
// 获取时间
@property (weak, nonatomic) IBOutlet UILabel *getTimeLabel;
// 期限
@property (weak, nonatomic) IBOutlet UILabel *deadlineLabel;
// 满多少可用
@property (weak, nonatomic) IBOutlet UILabel *fullAmountLabel;



// 左边部分的宽度
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leftWidthConstaint;
// 右边部分的宽度
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rightWidthConstaint;

@end

@implementation ELHMyWalletCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    // 动态修改子控件的宽度
    self.leftWidthConstaint.constant = ScreenW * 0.35;
    self.rightWidthConstaint.constant = ScreenW * 0.63;
    [self layoutIfNeeded];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


/**
 *  设置数据
 */
- (void)setMyWalletModel:(ELHMyWalletModel *)myWalletModel {
    _myWalletModel = myWalletModel;
    
    float VCAmount = [myWalletModel.VCAmount floatValue];
    self.priceLabel.text = [NSString stringWithFormat:@"￥%.1f", VCAmount];
    self.getTimeLabel.text = [NSString stringWithFormat:@"●获取日期:%@", myWalletModel.VCGetTime];
    if ([myWalletModel.VCTerm isEqual:@"-1"]) {
        self.deadlineLabel.text = @"无限期";
    } else {
        self.deadlineLabel.text = [NSString stringWithFormat:@"●限期:%@天", myWalletModel.VCTerm];
    }
    float VCFullAmount = [myWalletModel.VCFullAmount floatValue];
    self.fullAmountLabel.text = [NSString stringWithFormat:@"●满%.1f可用", VCFullAmount];
}
@end
