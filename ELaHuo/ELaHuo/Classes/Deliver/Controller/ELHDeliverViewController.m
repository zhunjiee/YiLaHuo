//
//  ELHDeliverTableViewController.m
//  ELaHuo
//
//  Created by elahuo on 16/3/9.
//  Copyright © 2016年 elahuo. All rights reserved.
//

#import "ELHDeliverViewController.h"
#import "ELHPlaceholderTextField.h"
#import "WMCustomDatePicker.h"
#import "ELHSearchLocationViewController.h"
#import "NSString+Regular.h"
#import <BaiduMapAPI_Map/BMKMapComponent.h>
#import <BaiduMapAPI_Utils/BMKUtilsComponent.h>
#import <SVProgressHUD.h>
#import "ELHOCToJson.h"
#import "ELHCarLevel.h"
#import "ELHHTTPSessionManager.h"
#import "ELHViewController.h"

@interface ELHDeliverViewController () <WMCustomDatePickerDelegate, ELHSearchLocationDeleagte, UITextFieldDelegate>
// 装货地点
@property (weak, nonatomic) IBOutlet ELHPlaceholderTextField *loadLocationTextField;
@property (weak, nonatomic) IBOutlet UIButton *loadLocationButton;

//  装货时间
@property (weak, nonatomic) IBOutlet ELHPlaceholderTextField *timerTextField;
// 装货信息电话
@property (weak, nonatomic) IBOutlet ELHPlaceholderTextField *loadPhoneNumberTextField;
// 尾板
@property (weak, nonatomic) IBOutlet UIButton *tailBoardButton;
// 侧门
@property (weak, nonatomic) IBOutlet UIButton *sideDoorButton;
// 卸货信息电话
@property (weak, nonatomic) IBOutlet ELHPlaceholderTextField *unloadPhoneNumberTextField;
// 卸货地点
@property (weak, nonatomic) IBOutlet ELHPlaceholderTextField *unloadLocationTextField;
@property (weak, nonatomic) IBOutlet UIButton *unloadLocationButton;


// 里程
@property (weak, nonatomic) IBOutlet ELHPlaceholderTextField *mileageTextField;
// 车辆要求
@property (weak, nonatomic) IBOutlet UITextField *carLevelTextField;

/** 时间选择器 */
@property (nonatomic, strong) WMCustomDatePicker *timerPicker;

/** 装货地点地理位置 */
@property (nonatomic, strong) NSValue *loadPoint;
/** 卸货地点地理位置 */
@property (nonatomic, strong) NSValue *unloadPoint;

/** 网络请求管理者 */
@property (nonatomic, strong) ELHHTTPSessionManager *manager;
@end

@implementation ELHDeliverViewController
#pragma mark - 懒加载
/** timerPicker的懒加载 */
- (WMCustomDatePicker *)timerPicker {
    if (_timerPicker == nil) {
        _timerPicker = [[WMCustomDatePicker alloc]initWithframe:CGRectMake(0, 0, ScreenW, ScreenH * 0.3
) PickerStyle:WMDateStyle_YearMonthDayHourMinute didSelectedDateFinishBack:^(WMCustomDatePicker *picker, NSString *year, NSString *month, NSString *day, NSString *hour, NSString *minute, NSString *weekDay) {
           
        }];
        
        _timerPicker.minLimitDate = [NSDate date];
        _timerPicker.maxLimitDate = [NSDate dateWithTimeIntervalSinceNow:24*60*60*30*12];
        
    }
    return _timerPicker;
}
/** manager的懒加载 */
- (ELHHTTPSessionManager *)manager {
    if (_manager == nil) {
        _manager = [ELHHTTPSessionManager manager];
    }
    return _manager;
}



#pragma mark - 初始化
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setUpNav];

    self.timerTextField.delegate = self;

    [self setUpGestureRecognizer];
    
    // 弹出键盘
    [self.loadPhoneNumberTextField becomeFirstResponder];
    
    self.timerPicker.delegate = self;

    
    self.timerTextField.inputView = self.timerPicker;

    
    [self setUpInCommonUseData];
}


- (void)setUpNav {
    self.navigationItem.title = @"发布订单";
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"发布" style:UIBarButtonItemStyleDone target:self action:@selector(publishButtonClick)];
    self.navigationItem.rightBarButtonItem = item;
}

/**
 *  设置常用数据
 */
- (void)setUpInCommonUseData {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *loadLocation = [userDefaults objectForKey:@"loadLocation"];
    NSString *loadPhoneNumber = [userDefaults objectForKey:@"loadPhoneNumber"];
    NSString *loadTime = [userDefaults objectForKey:@"loadTime"];
    NSString *tailBorder = [userDefaults objectForKey:@"tailBorder"];
    NSString *sideDoor = [userDefaults objectForKey:@"sideDoor"];
    NSString *unloadLocation = [userDefaults objectForKey:@"unloadLocation"];
    NSString *unloadPhoneNumber = [userDefaults objectForKey:@"unloadPhoneNumber"];
    NSString *mileage = [userDefaults objectForKey:@"mileage"];
    NSString *carLevel = [userDefaults objectForKey:@"carLevel"];

    if (loadLocation != nil && loadLocation.length != 0) {
        self.loadLocationTextField.text = loadLocation;
    } else {
        self.loadLocationTextField.text = nil;
    }
    
    if (loadPhoneNumber != nil && loadPhoneNumber.length != 0) {
        self.loadPhoneNumberTextField.text = loadPhoneNumber;
    } else {
        self.loadPhoneNumberTextField.text = nil;
    }
    if (loadTime != nil && loadTime.length != 0) {
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"yyyy年MM月dd日 HH时mm分";
        // 装货时间
        NSDate *useDate = [formatter dateFromString:loadTime];
        // 当前时间
        NSDate *nowDate = [NSDate date];
        
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSCalendarUnit unit = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute;
        
        NSDateComponents *cmps = [calendar components:unit fromDate:useDate toDate:nowDate options:0];
        
        if (cmps.year >= 0 && cmps.month >= 0 && cmps.day >= 0 && cmps.hour >= 0 && cmps.minute > -30) { // 至少是30分钟以前
            NSTimeInterval onehalfHour = 60 * 30;
            NSDate *myDate = [nowDate dateByAddingTimeInterval:onehalfHour];
            NSString *myTime = [formatter stringFromDate:myDate];
            self.timerTextField.text = myTime;
        } else { // 当前时间30分钟以后
            self.timerTextField.text = loadTime;
        }
    } else {
        self.timerTextField.text = nil;
    }
    if ([tailBorder isEqual:@"1"]) {
        self.tailBoardButton.selected = YES;
    } else {
        self.tailBoardButton.selected = NO;
    }
    if ([sideDoor isEqual:@"1"]) {
        self.sideDoorButton.selected = YES;
    } else {
        self.sideDoorButton.selected = NO;
    }
    if (unloadLocation != nil && unloadLocation.length != 0) {
        self.unloadLocationTextField.text = unloadLocation;
    } else {
        self.unloadLocationTextField.text = nil;
    }
    if (unloadPhoneNumber != nil && unloadPhoneNumber.length != 0) {
        self.unloadPhoneNumberTextField.text = unloadPhoneNumber;
    } else {
        self.unloadPhoneNumberTextField.text = nil;
    }
    if (mileage != nil && mileage.length != 0) {
        self.mileageTextField.text = mileage;
    } else {
        self.mileageTextField.text = nil;
    }
    if (carLevel != nil && carLevel.length != 0) {
        self.carLevelTextField.text = carLevel;
    } else {
        self.carLevelTextField.text = nil;
    }
}

/**
 *  添加手势
 */
- (void)setUpGestureRecognizer {
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(searchLocation:)];
    self.unloadLocationButton.userInteractionEnabled = YES;
    [self.unloadLocationButton addGestureRecognizer:tap];
    
    UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(searchLocation:)];
    self.loadLocationButton.userInteractionEnabled = YES;
    [self.loadLocationButton addGestureRecognizer:tap1];
}


static NSInteger tag = 0;
/**
 *  跳转到搜索地名界面
 */
- (void)searchLocation:(UITapGestureRecognizer *)tap {
    ELHSearchLocationViewController *searchVC = [UIStoryboard storyboardWithName:NSStringFromClass([ELHSearchLocationViewController class]) bundle:nil].instantiateInitialViewController;
    
    searchVC.delegate = self;
    
    [self.navigationController pushViewController:searchVC animated:YES];
    
    tag = [tap view].tag;
}


static CGPoint aPoint;
static CGPoint bPoint;
#pragma mark - ELHSearchLocationDeleagte
- (void)searchLocationViewController:(ELHSearchLocationViewController *)searchVC didAddLoaction:(NSString *)location andCLLocationPoint:(NSValue *)point {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    
    if (tag == 1) {
        self.loadLocationTextField.text = location;
        self.loadPoint = point;
        
        [userDefaults setObject:self.loadLocationTextField.text forKey:@"loadLocation"]; // 装货地点
        [userDefaults setObject:[NSString stringWithFormat:@"%f", self.loadPoint.CGPointValue.x] forKey:@"loadPointX"]; // 装货地点X
        [userDefaults setObject:[NSString stringWithFormat:@"%f", self.loadPoint.CGPointValue.y] forKey:@"loadPointY"]; // 装货地点Y
        [userDefaults synchronize];
        
        

    } else {
        self.unloadLocationTextField.text = location;
        self.unloadPoint = point;
        
        [userDefaults setObject:self.unloadLocationTextField.text forKey:@"unloadLocation"]; // 卸货地点
        [userDefaults setObject:[NSString stringWithFormat:@"%f", self.unloadPoint.CGPointValue.x] forKey:@"unLoadPointX"]; // 卸货地点X
        [userDefaults setObject:[NSString stringWithFormat:@"%f", self.unloadPoint.CGPointValue.y] forKey:@"unLoadPointY"]; // 卸货地点Y
        [userDefaults synchronize];
        
        
        
    }
    
    
    
    
    if (self.loadPoint == nil && self.loadLocationTextField.text != nil && self.loadLocationTextField.text.length != 0) {
        aPoint = CGPointMake([[userDefaults objectForKey:@"loadPointX"] floatValue], [[userDefaults objectForKey:@"loadPointY"] floatValue]);
        self.loadPoint = [NSValue valueWithCGPoint:aPoint];
        BSLog(@"%f--aaa--%f", aPoint.x, aPoint.y);
    } else {
        aPoint = self.loadPoint.CGPointValue;
        BSLog(@"%f**aaa**%f", aPoint.x, aPoint.y);
    }
    
    if (self.unloadPoint == nil && self.unloadLocationTextField.text != nil && self.unloadLocationTextField.text.length != 0) {
        
        bPoint = CGPointMake([[userDefaults objectForKey:@"unLoadPointX"] floatValue], [[userDefaults objectForKey:@"unLoadPointY"] floatValue]);
        self.unloadPoint = [NSValue valueWithCGPoint:bPoint];
        BSLog(@"%f--bbb--%f", bPoint.x, bPoint.y);
    } else {
        bPoint = self.unloadPoint.CGPointValue;
        BSLog(@"%f**bbb**%f", bPoint.x, bPoint.y);

    }
    // 计算两地间的实际距离
    if (self.loadPoint != nil && self.unloadPoint != nil) {
        BMKMapPoint point1 = BMKMapPointForCoordinate(CLLocationCoordinate2DMake(aPoint.x,aPoint.y));
        BMKMapPoint point2 = BMKMapPointForCoordinate(CLLocationCoordinate2DMake(bPoint.x,bPoint.y));
        CLLocationDistance distance = BMKMetersBetweenMapPoints(point1,point2);
        
        self.mileageTextField.text = [NSString stringWithFormat:@"%.0f公里", distance / (1000.0)];
        
        [userDefaults setObject:self.mileageTextField.text forKey:@"mileage"]; // 里程
    }
}




#pragma mark - 监听方法
- (void)publishButtonClick {
    // 进行提交前的业务逻辑判断
    if ((self.loadLocationTextField.text == nil || self.loadLocationTextField.text.length == 0) || (self.timerTextField.text == nil || self.timerTextField.text.length == 0) || (self.loadPhoneNumberTextField.text == nil || self.loadPhoneNumberTextField.text.length == 0) || (self.unloadLocationTextField.text == nil || self.unloadLocationTextField.text.length == 0) || (self.unloadPhoneNumberTextField.text == nil || self.unloadPhoneNumberTextField.text.length == 0) || (self.carLevelTextField.text == nil || self.carLevelTextField.text.length == 0)) {
        [SVProgressHUD showImage:nil status:@"请您填写所有内容"];
        return;
    } else if ([self.loadPhoneNumberTextField.text checkPhoneNumInput] == NO || [self.unloadPhoneNumberTextField.text checkPhoneNumInput] == NO) {
        [SVProgressHUD showImage:nil status:@"请输入正确的手机号码"];
        return;
    } else if ([self judgeLoadTime] == NO) {
        [SVProgressHUD showImage:nil status:@"必须大于30分钟"];
        return;
    }
    
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    int GOId = [[userDefaults stringForKey:@"GOId"] intValue];
    // 尾板
    int tailBorder = [self tailBoard];
    // 侧门
    int sideDoor = [self sideDoor];
    // 车辆要求
    NSString *carLevel =  [ELHCarLevel exchangeCarLevel:self.carLevelTextField.text];
    
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    fmt.dateFormat = @"yyyy年MM月dd日 HH时mm分";
    NSDate *deliverDate = [fmt dateFromString:self.timerTextField.text];
    NSDateFormatter *fmt1 = [[NSDateFormatter alloc] init];
    fmt1.dateFormat = @"yyyy-MM-dd HH:mm";
    NSString *deliverDateStr = [fmt1 stringFromDate:deliverDate];
    
    NSString *distance = [self.mileageTextField.text substringToIndex:self.mileageTextField.text.length - 2];
    BSLog(@"ROKM = %@", distance);
    
    NSDictionary *dict = @{
                           @"GOId" : @(GOId), // 货主ID
                           @"ROLoadSite" : self.loadLocationTextField.text, // 装货地点
                           @"ROLLon" : @(aPoint.x),
                           @"ROLLat" : @(aPoint.y),
                           @"ROLoadTime" : deliverDateStr,
                           @"COCLoadM" : self.loadPhoneNumberTextField.text,
                           @"ROIsWB" : @(tailBorder),
                           @"ROCMNum" : @(sideDoor),
                           @"ROUnloadSite" : self.unloadLocationTextField.text, // 卸货地点
                           @"ROULlon" : @(bPoint.x),
                           @"ROULLat" : @(bPoint.y),
                           @"COCUnloadM" : self.unloadPhoneNumberTextField.text,
                           @"ROKM" : distance,
                           @"COCLevel" : carLevel,
                           };
    
    NSDictionary *params = [ELHOCToJson ocToJson:dict];
    
    ELHWeakSelf;
    NSString *URL = [NSString stringWithFormat:@"%@RealtimeOrder_addRO.action", ELHBaseURL];
    
    [SVProgressHUD showWithStatus:@"正在发布中..."];
    
    [self.manager POST:URL parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        BSLog(@"%@", responseObject);
        
        if ([responseObject[@"resultSign"] intValue] == 1) {
            [SVProgressHUD showImage:nil status:@"发布成功"];
            
            // 触发后台的推送
            [self getOrderNumer:responseObject[@"ROBM"] AndCarLevel:responseObject[@"COCLevel"]];
            
            // 发送发货成功的通知
            [[NSNotificationCenter defaultCenter] postNotificationName:ELHDeliverSuccessNotification object:nil];
        } else if ([responseObject[@"resultSign"] intValue] == -1) {
            [SVProgressHUD showImage:nil status:@"发布失败"];
        }
        
        [SVProgressHUD dismiss];

        
        // 退出发布订单界面
        [weakSelf.navigationController popViewControllerAnimated:YES];
        
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [SVProgressHUD showImage:nil status:@"发布失败"];
        BSLog(@"error = %@", error);
    }];
}


- (void) getOrderNumer:(NSString *)ROBM AndCarLevel:(NSString *)carLevel {
    NSString *registrationID = [[NSUserDefaults standardUserDefaults] stringForKey:@"registrationID"];
    if (registrationID.length == 0 || registrationID == nil) {
        registrationID = @"NULL";
    }
    BSLog(@"registrationID = %@, ROBM = %@, COCLevel = %@", registrationID, ROBM, carLevel);
    
    NSDictionary *dict = @{
                           @"GOClientId" : registrationID,
                           @"ROBM" : ROBM,
                           @"COCLevel" : carLevel,
                           };
    
    NSDictionary *params = [ELHOCToJson ocToJson:dict];

    NSString *URL = [NSString stringWithFormat:@"%@RealtimeOrder_sendNewROJP.action", ELHBaseURL];
//    ELHWeakSelf;
    [self.manager POST:URL parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        BSLog(@"responseObject = %@", responseObject);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        BSLog(@"error = %@", error);
    }];
}


- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [SVProgressHUD dismiss];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    // 尾板
    int tailBorder = [self tailBoard];
    // 侧门
    int sideDoor = [self sideDoor];
    
    [userDefaults setObject:[NSString stringWithFormat:@"%d", tailBorder] forKey:@"tailBorder"]; // 尾板
    [userDefaults setObject:[NSString stringWithFormat:@"%d", sideDoor] forKey:@"sideDoor"]; // 侧门
    [userDefaults setObject:self.loadPhoneNumberTextField.text forKey:@"loadPhoneNumber"]; // 装货电话
    [userDefaults setObject:self.timerTextField.text forKey:@"loadTime"]; // 装货时间
    BSLog(@"%@", self.timerTextField.text);
    [userDefaults setObject:self.unloadPhoneNumberTextField.text forKey:@"unloadPhoneNumber"]; // 卸货电话
    [userDefaults setObject:self.carLevelTextField.text forKey:@"carLevel"]; // 车辆要求
    [userDefaults synchronize];
}


// 控制尾板按钮可否选中
- (IBAction)tailBoardButtonClick:(UIButton *)button {
    button.selected = !button.isSelected;
}

// 尾板是否选中
- (int)tailBoard {
    if (self.tailBoardButton.isSelected) {
        return 1;
    } else {
        return 0;
    }
}

// 控制侧门按钮可否选中
- (IBAction)sideDoorButtonClick:(UIButton *)button {
    button.selected = !button.isSelected;
}

// 侧门是否选中
- (int)sideDoor {
    if (self.sideDoorButton.isSelected) {
        return 1;
    } else {
        return 0;
    }
}

#pragma mark - WMCustomDatePickerDelegate
- (void)finishDidSelectDatePicker:(WMCustomDatePicker *)datePicker year:(NSString *)year month:(NSString *)month day:(NSString *)day hour:(NSString *)hour minute:(NSString *)minute weekDay:(NSString *)weekDay {
    // 转换时间格式
    NSString *pickerTime = [NSString stringWithFormat:@"%@%@%@ %@%@",year,month,day,hour,minute];
    self.timerTextField.text = pickerTime;
    
//    NSString *pickerYear = [pickerTime substringWithRange:NSMakeRange(0, 4)];
//    NSString *pickerMonth = [pickerTime substringWithRange:NSMakeRange(5, 2)];
//    NSString *pickerDay = [pickerTime substringWithRange:NSMakeRange(8, 2)];
//    NSString *pickerHour = [pickerTime substringWithRange:NSMakeRange(11, 2)];
//    NSString *pickerMinute = [pickerTime substringWithRange:NSMakeRange(14, 2)];
//    
//    self.timerTextField.text = [NSString stringWithFormat:@"%@-%@-%@ %@:%@", pickerYear, pickerMonth, pickerDay, pickerHour, pickerMinute];
//    
//    BSLog(@"%@", self.timerTextField.text);
}


#pragma mark - UITable相关
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 40;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (section == 2) {
        return 20;
    }
    return 0.00001;
}


- (void)textFieldDidEndEditing:(UITextField *)textField {
    // 判断装货时间
    if (self.timerTextField.text.length != 0) {
        if ([self judgeLoadTime] == NO) {
            [SVProgressHUD showImage:nil status:@"必须大于30分钟"];
            
            [self.timerTextField setText:nil];
 
        }
    }
}

/**
 *  判断装货时间至少要提前30分钟
 */
- (BOOL)judgeLoadTime {
    NSString *timeString = self.timerTextField.text;
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy年MM月dd日 HH时mm分";
    
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    
    
    // 装货时间
    NSDate *time = [formatter dateFromString:timeString];
    NSInteger interval = [zone secondsFromGMTForDate: time];
    NSDate *loadTime = [time dateByAddingTimeInterval:interval];
    // 当前时间
    NSInteger interval1 = [zone secondsFromGMTForDate: [NSDate date]];
    NSDate *nowTime = [[NSDate date] dateByAddingTimeInterval:interval1];
    
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSCalendarUnit unit = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute;
    
    // 比较时间差
    NSDateComponents *comps = [calendar components:unit fromDate:nowTime toDate:loadTime options:0];
    
    if (comps.year == 0 && comps.month == 0 && comps.day == 0 && comps.hour == 0) {
        if (comps.minute < 30) {
            return NO;
        } else {
            return YES;
        }
        
    } else if (comps.year > 0 || comps.month > 0 || comps.day > 0 || comps.hour > 0) {
        return YES;
        
    } else {
        
        return NO;
    }
}


/**
 *  滚动退出键盘
 */
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.view endEditing:YES];
}
@end
