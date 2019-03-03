//
//  ELHPayViewController.m
//  ELaHuo
//
//  Created by elahuo on 16/4/1.
//  Copyright © 2016年 elahuo. All rights reserved.
//

#import "ELHPayViewController.h"
#import "ELHChildPayTableViewController.h"
#import "ELHOrderDetailModel.h"
#import "ELHOrderModel.h"
#import "ELHOCToJson.h"
#import "UPPaymentControl.h"
#import <SVProgressHUD.h>
#import "ELHHTTPSessionManager.h"
#import <MJExtension.h>
#import "ELHMyWalletModel.h"


@interface ELHPayViewController () <NSURLConnectionDelegate, ELHChildPayTableViewControllerDelegate>

/** 交易流水号 */
@property (nonatomic, copy) NSString *tn;
/** 存放请求数据的数组 */
@property (nonatomic, strong) NSMutableData *responseData;

/** 网络请求管理者 */
@property (nonatomic, strong) ELHHTTPSessionManager *manager;
/** 存放红包数据的数组 */
@property (nonatomic, strong) NSMutableArray *redEnvelopeArray;
/** 存放红包金额的数据 */
@property (nonatomic, strong) NSMutableArray *redEnvelopeAmountArray;
/** 存放可用红包的数组 */
@property (nonatomic, strong) NSMutableArray *availableArray;
/** 红包ID */
@property (nonatomic, copy) NSString *VCId;
/** 真实价格 */
@property (nonatomic, copy) NSString *actualPrice;
/** 原始价格 */
@property (nonatomic, copy) NSString *originalPrice;

@property (weak, nonatomic) IBOutlet UIView *confirmPayView;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *containerViewBottomConstraint;

@end

@implementation ELHPayViewController
#pragma mark - 懒加载
/** manager的懒加载 */
- (ELHHTTPSessionManager *)manager {
    if (!_manager) {
        _manager = [ELHHTTPSessionManager manager];
    }
    return _manager;
}
/** redEnvelopeArray的懒加载 */
- (NSMutableArray *)redEnvelopeArray{
    if (!_redEnvelopeArray) {
        _redEnvelopeArray = [NSMutableArray array];
    }
    return _redEnvelopeArray;
}
/** redEnvelopeAmountArray的懒加载 */
- (NSMutableArray *)redEnvelopeAmountArray{
    if (!_redEnvelopeAmountArray) {
        _redEnvelopeAmountArray = [NSMutableArray array];
    }
    return _redEnvelopeAmountArray;
}
/** availableArray的懒加载 */
- (NSMutableArray *)availableArray{
    if (!_availableArray) {
        _availableArray = [NSMutableArray array];
    }
    return _availableArray;
}

#pragma mark - 初始化
- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.isExecuteOrder == YES) {
        self.navigationItem.title = @"订单详情";
    } else {
        self.navigationItem.title = @"确认支付";
    }

    if (self.isExecuteOrder == YES) {
        self.confirmButton.hidden = YES;
        self.containerViewBottomConstraint.constant = -35;
        [self.view layoutIfNeeded];
    } else {
        self.confirmButton.hidden = NO;
    }
    
    // 接收到订单支付完成的通知改变订单状态
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(completePayment) name:ELHcomplePayNotification object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    // 支付完成,发送支付完成的消息
    if ([self.confirmButton.titleLabel.text isEqual:@"支付完成"]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:ELHDeliverSuccessNotification object:nil];
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

/**
 *  支付完成,改变按钮文字及不可点击
 */
- (void) completePayment {
    self.navigationItem.title = @"订单详情";
    
    [self.confirmButton setTitle:@"支付完成" forState:UIControlStateNormal];
    self.confirmButton.userInteractionEnabled = NO;
    
    [SVProgressHUD showImage:nil status:@"支付完成,等待发货"];
    
    // 从支付订单界面退出
//    [self.navigationController popViewControllerAnimated:YES];
}

/**
 *  设置数据
 */
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    ELHChildPayTableViewController *childPayVC = segue.destinationViewController;
    childPayVC.delegate = self;
    childPayVC.orderModel = self.orderModel;
    childPayVC.orderDetailModel = self.orderDetailModel;
    childPayVC.isExecuteOrder = self.isExecuteOrder;
}

/**
 *  ELHChildPayTableView的代理方法
 *
 *  @param originalPrice 原始价格
 *  @param actualPrice   真实价格
 *  @param VCId          红包ID
 */
- (void)getOriginalPrice:(NSString *)originalPrice ActualPrice:(NSString *)actualPrice andRedEnvelope:(NSString *)VCId {
    self.originalPrice = originalPrice;
    self.actualPrice = actualPrice;
    self.VCId = VCId;
    
    BSLog(@"原始价格:%@, 实际价格:%@, 红包ID:%@", self.originalPrice, self.actualPrice, self.VCId);
}

/**
 *  确认支付
 */
- (IBAction)confiemButtonDidClick:(UIButton *)sender {
    BSLog(@"self.actualPrice = %@", self.actualPrice);
    BSLog(@"self.VCId = %@", self.VCId);
    if ([self.actualPrice isEqual:@"正在计算中..."] || self.actualPrice.length == 0) {
        sender.userInteractionEnabled = NO;
        return;
    } else {
        sender.userInteractionEnabled = YES;
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"注意" message:@"请在10分钟之内完成支付,否则此订单失效" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            // 将OPId保存起来,取消支付时更新订单状态
            [[NSUserDefaults standardUserDefaults] setObject:self.orderDetailModel.OPId forKey:@"OPId"];
            // 装货时间
            NSString *ROLoadTime = [self.orderModel.ROLoadTime substringWithRange:NSMakeRange(0, 19)];
            // 里程
            NSString *ROKM = [NSString stringWithFormat:@"%.0f", self.orderModel.ROKM];
            
            BSLog(@"\nROLoadTime = %@ \nOPId = %@ \nCOId = %@ \nROId = %@ \nROKM = %@", ROLoadTime, self.orderDetailModel.OPId, self.orderDetailModel.COId, self.orderModel.ROId, ROKM);
            
            NSDictionary *dict = @{
                                   @"ROId" : self.orderModel.ROId,
                                   @"ROLoadTime" : ROLoadTime,
                                   @"ROKM" : ROKM,
                                   @"COId" : self.orderDetailModel.COId,
                                   @"OPId" : self.orderDetailModel.OPId,
                                   };
            
            NSDictionary *params = [ELHOCToJson ocToJson:dict];
            NSString *URL = [NSString stringWithFormat:@"%@RealtimeOrder_controCarOwner.action", ELHBaseURL];
            [self.manager POST:URL parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
                BSLog(@"responseObject = %@", responseObject);
                
                if ([responseObject[@"resultSign"] intValue] == 1) { // 时间不重合进入支付界面
                    BSLog(@"可以支付");
                    // 订单编号
                    NSString *orderID = self.orderNumber;
                    
                    // 获取订单发送时间(当前系统时间)
                    NSDate *now = [NSDate date];
                    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                    formatter.dateFormat = @"yyyyMMddHHmmss";
                    NSString *dateStr = [formatter stringFromDate:now];
                    
                    
                    // 获取交易流水号(TN)
                    NSString *URLStr = [NSString stringWithFormat:@"%@form05_6_2_Consume?txnAmt=%@&orderId=%@&ROId=%@&VCId=%@&COId=%@&txnTime=%@&txnAmtP=%@", ELHBaseURL, self.actualPrice, orderID, self.ROId,self.VCId, self.orderDetailModel.COId, dateStr, self.originalPrice];
                    BSLog(@"%@", URLStr);
                    
                    [self startNetWithURL:[NSURL URLWithString:URLStr]];
                    
                } else if ([responseObject[@"resultSign"] intValue] == 0) { // 时间重合,不可支付
                    [SVProgressHUD showImage:nil status:@"司机暂时无法接单,请稍后再支付"];
                    return;
                }
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                BSLog(@"error = %@", error);
            }];
  
        }];
        
        [alertController addAction:cancelAction];
        [alertController addAction:confirmAction];
        
        [self presentViewController:alertController animated:YES completion:nil];
    }
}


/**
 *  向服务器获取交易流水号(TN)
 *
 */
- (void)startNetWithURL:(NSURL *)url {
    [SVProgressHUD showWithStatus:@"正在处理中"];
    
    NSURLRequest * urlRequest=[NSURLRequest requestWithURL:url];
    NSURLConnection* urlConn = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
    [urlConn start];
}

#pragma mark - NSURLConnection Delegate
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse*)response {
    NSHTTPURLResponse* rsp = (NSHTTPURLResponse*)response;
    NSInteger code = [rsp statusCode];
    if (code != 200) {
        
        [SVProgressHUD showImage:nil status:@"网络错误"];
        [connection cancel];
    } else {
        
        _responseData = [[NSMutableData alloc] init];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [_responseData appendData:data];

}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [SVProgressHUD dismiss];
    NSString* tn = [[NSMutableString alloc] initWithData:_responseData encoding:NSUTF8StringEncoding];
    BSLog(@"tn = %@", tn);
    if (tn != nil && tn.length > 0)
    {
        [[UPPaymentControl defaultControl] startPay:tn fromScheme:@"ELaHuoUPPay" mode:@"00" viewController:self];
        
    }
    
    
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    BSLog(@"%@", error);
    [SVProgressHUD showImage:nil status:@"网络错误"];
}



#pragma mark UPPayPluginResult
- (void)UPPayPluginResult:(NSString *)result {
    NSString* msg = [NSString stringWithFormat:@"支付结果：%@", result];
    [SVProgressHUD showImage:nil status:msg];
    BSLog(@"%@", msg);
}


#pragma UITable相关
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (section == 2) {
        return 20;
    }
    return 0.00001;
}
@end
