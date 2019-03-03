//
//  DirverInfoViewController.m
//  ELaHuo
//
//  Created by elahuo on 16/6/17.
//  Copyright © 2016年 elahuo. All rights reserved.
//

#import "DirverInfoViewController.h"
#import "ELHOrderDetailModel.h"
#import "ELHDirverInfoModel.h"
#import "ELHHTTPSessionManager.h"
#import "ELHOCToJson.h"
#import <MJExtension.h>
#import "ELHCarLevel.h"

@interface DirverInfoViewController ()
@property (weak, nonatomic) IBOutlet UILabel *dirverNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *star1;
@property (weak, nonatomic) IBOutlet UIImageView *star2;
@property (weak, nonatomic) IBOutlet UIImageView *star3;
@property (weak, nonatomic) IBOutlet UIImageView *star4;
@property (weak, nonatomic) IBOutlet UIImageView *star5;
@property (weak, nonatomic) IBOutlet UILabel *noStarLabel;
@property (weak, nonatomic) IBOutlet UITextField *phoneNumTextField;
@property (weak, nonatomic) IBOutlet UITextField *carLevelTextField;
@property (weak, nonatomic) IBOutlet UITextField *carNumTextField;

@property (strong, nonatomic) ELHHTTPSessionManager *manager;

@property (strong, nonatomic) NSMutableArray *dirverInfoArray;
@property (strong, nonatomic) ELHDirverInfoModel *dirverInfoModel;
@end

@implementation DirverInfoViewController
#pragma mark - 懒加载
- (ELHHTTPSessionManager *)manager {
    if (!_manager) {
        _manager = [ELHHTTPSessionManager manager];
    }
    return _manager;
}

- (NSMutableArray *)dirverInfoArray {
    if (!_dirverInfoArray) {
        _dirverInfoArray = [NSMutableArray array];
    }
    return _dirverInfoArray;
}

#pragma mark - 初始化
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self loadDirverInformation];
    
    self.navigationItem.title = @"司机详情";
}

/**
 *  加载司机信息
 */
- (void)loadDirverInformation {
    // 设置数据
    
    // 姓名
    NSString *dirverName;
    if (self.orderDetailModel.COName != nil && self.orderDetailModel.COName.length > 3) {
        dirverName = [self.orderDetailModel.COName substringWithRange:NSMakeRange(0, 2)];
    } else {
        dirverName = [self.orderDetailModel.COName substringWithRange:NSMakeRange(0, 1)];
    }
    self.dirverNameLabel.text = [NSString stringWithFormat:@"%@师傅", dirverName];
    
    // 司机星级
    if ([self.orderDetailModel.COPJStar floatValue] >= 0 && [self.orderDetailModel.COPJStar floatValue] < 1) {
        [self.star1 setImage:[UIImage imageNamed:@"Star_deselected"]];
        [self.star2 setImage:[UIImage imageNamed:@"Star_deselected"]];
        [self.star3 setImage:[UIImage imageNamed:@"Star_deselected"]];
        [self.star4 setImage:[UIImage imageNamed:@"Star_deselected"]];
        [self.star5 setImage:[UIImage imageNamed:@"Star_deselected"]];

    } else if ([self.orderDetailModel.COPJStar floatValue] >= 1 && [self.orderDetailModel.COPJStar floatValue] < 2) {
        [self.star1 setImage:[UIImage imageNamed:@"Star_selected"]];
        [self.star2 setImage:[UIImage imageNamed:@"Star_deselected"]];
        [self.star3 setImage:[UIImage imageNamed:@"Star_deselected"]];
        [self.star4 setImage:[UIImage imageNamed:@"Star_deselected"]];
        [self.star5 setImage:[UIImage imageNamed:@"Star_deselected"]];

    } else if ([self.orderDetailModel.COPJStar floatValue] >= 2 && [self.orderDetailModel.COPJStar floatValue] < 3) {
        [self.star1 setImage:[UIImage imageNamed:@"Star_selected"]];
        [self.star2 setImage:[UIImage imageNamed:@"Star_selected"]];
        [self.star3 setImage:[UIImage imageNamed:@"Star_deselected"]];
        [self.star4 setImage:[UIImage imageNamed:@"Star_deselected"]];
        [self.star5 setImage:[UIImage imageNamed:@"Star_deselected"]];

    } else if ([self.orderDetailModel.COPJStar floatValue] >= 3 && [self.orderDetailModel.COPJStar floatValue] < 4) {
        [self.star1 setImage:[UIImage imageNamed:@"Star_selected"]];
        [self.star2 setImage:[UIImage imageNamed:@"Star_selected"]];
        [self.star3 setImage:[UIImage imageNamed:@"Star_selected"]];
        [self.star4 setImage:[UIImage imageNamed:@"Star_deselected"]];
        [self.star5 setImage:[UIImage imageNamed:@"Star_deselected"]];

    } else if ([self.orderDetailModel.COPJStar floatValue] >= 4 && [self.orderDetailModel.COPJStar floatValue] < 5) {
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
    
    // 手机号
    if (self.orderDetailModel.COMobile != nil) {
        self.phoneNumTextField.text = [NSString stringWithFormat:@"%@****%@", [self.orderDetailModel.COMobile substringWithRange:NSMakeRange(0, 3)], [self.orderDetailModel.COMobile substringWithRange:NSMakeRange(7, 4)]];
    } else {
        self.phoneNumTextField.text = nil;
    }
    
    // 车辆详情
    if ([self.orderDetailModel.COCISWB isEqual:@"1"] && [self.orderDetailModel.COCCMNUM isEqual:@"1"]) {
        self.carLevelTextField.text = [NSString stringWithFormat:@"%@/尾板/侧门", [ELHCarLevel setUpCarLevel:self.orderDetailModel.COCLEVEL]];
    } else if ([self.orderDetailModel.COCISWB isEqual:@"1"] && [self.orderDetailModel.COCCMNUM isEqual:@"0"]) {
        self.carLevelTextField.text = [NSString stringWithFormat:@"%@/尾板", [ELHCarLevel setUpCarLevel:self.orderDetailModel.COCLEVEL]];
    } else if ([self.orderDetailModel.COCISWB isEqual:@"0"] && [self.orderDetailModel.COCCMNUM isEqual:@"1"]) {
        self.carLevelTextField.text = [NSString stringWithFormat:@"%@/侧门", [ELHCarLevel setUpCarLevel:self.orderDetailModel.COCLEVEL]];
    } else {
        self.carLevelTextField.text = [NSString stringWithFormat:@"%@", [ELHCarLevel setUpCarLevel:self.orderDetailModel.COCLEVEL]];
    }
    
    // 车牌号
    if (self.orderDetailModel.COCPLATENUMBER != nil) {
        self.carNumTextField.text = self.orderDetailModel.COCPLATENUMBER;
    } else {
        self.carNumTextField.text = nil;
    }
}


- (void)loadDirverInfo {
    NSDictionary *dict = @{
                           @"COId" : self.COId,
                           };
    
    NSDictionary *params = [ELHOCToJson ocToJson:dict];
    NSString *URL = [NSString stringWithFormat:@"%@CarOwner_getCOInfoById.action", ELHBaseURL];
    ELHWeakSelf;
    [self.manager POST:URL parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        BSLog(@"%@", responseObject);
        
        // 通过字典创建模型
        weakSelf.dirverInfoModel = [ELHDirverInfoModel mj_objectWithKeyValues:responseObject];
        
        // 设置数据
        
        // 姓名
        NSString *dirverName;
        if (weakSelf.dirverInfoModel.COName != nil && weakSelf.dirverInfoModel.COName.length > 3) {
            dirverName = [weakSelf.dirverInfoModel.COName substringWithRange:NSMakeRange(0, 2)];
        } else {
             dirverName = [weakSelf.dirverInfoModel.COName substringWithRange:NSMakeRange(0, 1)];
        }
        self.dirverNameLabel.text = [NSString stringWithFormat:@"%@师傅", dirverName];
        
        // 司机星级
        if ([weakSelf.dirverInfoModel.COPJStar floatValue] == 0) {
            self.star1.hidden = YES;
            self.star2.hidden = YES;
            self.star3.hidden = YES;
            self.star4.hidden = YES;
            self.star5.hidden = YES;
            self.noStarLabel.hidden = NO;
        } else if ([weakSelf.dirverInfoModel.COPJStar floatValue] == 1) {
            self.star1.hidden = NO;
            self.star2.hidden = YES;
            self.star3.hidden = YES;
            self.star4.hidden = YES;
            self.star5.hidden = YES;
            self.noStarLabel.hidden = YES;
        } else if ([weakSelf.dirverInfoModel.COPJStar floatValue] == 2) {
            self.star1.hidden = NO;
            self.star2.hidden = NO;
            self.star3.hidden = YES;
            self.star4.hidden = YES;
            self.star5.hidden = YES;
            self.noStarLabel.hidden = YES;
        } else if ([weakSelf.dirverInfoModel.COPJStar floatValue] == 3) {
            self.star1.hidden = NO;
            self.star2.hidden = NO;
            self.star3.hidden = NO;
            self.star4.hidden = YES;
            self.star5.hidden = YES;
            self.noStarLabel.hidden = YES;
        } else if ([weakSelf.dirverInfoModel.COPJStar floatValue] == 4) {
            self.star1.hidden = NO;
            self.star2.hidden = NO;
            self.star3.hidden = NO;
            self.star4.hidden = NO;
            self.star5.hidden = YES;
            self.noStarLabel.hidden = YES;
        } else if ([weakSelf.dirverInfoModel.COPJStar floatValue] == 5) {
            self.star1.hidden = NO;
            self.star2.hidden = NO;
            self.star3.hidden = NO;
            self.star4.hidden = NO;
            self.star5.hidden = NO;
            self.noStarLabel.hidden = YES;
        }
        
        // 手机号
        if (weakSelf.dirverInfoModel.COMobile != nil) {
            self.phoneNumTextField.text = [NSString stringWithFormat:@"%@****%@", [weakSelf.dirverInfoModel.COMobile substringWithRange:NSMakeRange(0, 3)], [weakSelf.dirverInfoModel.COMobile substringWithRange:NSMakeRange(7, 4)]];
        } else {
            self.phoneNumTextField.text = nil;
        }
        
        // 车辆详情
        if ([weakSelf.dirverInfoModel.COCISWB isEqual:@"1"] && [weakSelf.dirverInfoModel.COCCMNUM isEqual:@"1"]) {
            self.carLevelTextField.text = [NSString stringWithFormat:@"%@/尾板/侧门", [ELHCarLevel setUpCarLevel:weakSelf.dirverInfoModel.COCLEVEL]];
        } else if ([weakSelf.dirverInfoModel.COCISWB isEqual:@"1"] && [weakSelf.dirverInfoModel.COCCMNUM isEqual:@"0"]) {
            self.carLevelTextField.text = [NSString stringWithFormat:@"%@/尾板", [ELHCarLevel setUpCarLevel:weakSelf.dirverInfoModel.COCLEVEL]];
        } else if ([weakSelf.dirverInfoModel.COCISWB isEqual:@"0"] && [weakSelf.dirverInfoModel.COCCMNUM isEqual:@"1"]) {
            self.carLevelTextField.text = [NSString stringWithFormat:@"%@/侧门", [ELHCarLevel setUpCarLevel:weakSelf.dirverInfoModel.COCLEVEL]];
        } else {
            self.carLevelTextField.text = [NSString stringWithFormat:@"%@", [ELHCarLevel setUpCarLevel:weakSelf.dirverInfoModel.COCLEVEL]];
        }
        
        // 车牌号
        if (weakSelf.dirverInfoModel.COCPLATENUMBER != nil) {
            self.carNumTextField.text = weakSelf.dirverInfoModel.COCPLATENUMBER;
        } else {
            self.carNumTextField.text = nil;
        }
        
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        BSLog(@"%@", error);
    }];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.000001;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 40;
}
@end
