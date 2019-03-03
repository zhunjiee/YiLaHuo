//
//  ELHDetailHistoryOrderViewController.m
//  ELaHuo
//
//  Created by elahuo on 16/4/6.
//  Copyright © 2016年 elahuo. All rights reserved.
//

#import "ELHDetailHistoryOrderViewController.h"
#import "ELHHistoryOrderModel.h"
#import "UMSocial.h"
#import "UMSocialControllerService.h"
#import "AppDelegate.h"

@interface ELHDetailHistoryOrderViewController () <UMSocialUIDelegate>
@property (weak, nonatomic) IBOutlet UILabel *loadLocationLabel; // 装货地点
@property (weak, nonatomic) IBOutlet UILabel *loadTimeLable; // 装货时间
@property (weak, nonatomic) IBOutlet UILabel *loadPhoneLabel; // 装货电话
@property (weak, nonatomic) IBOutlet UILabel *unloadLocationLabel; // 卸货地点
@property (weak, nonatomic) IBOutlet UILabel *unloadPhoneLabel; // 卸货电话
@property (weak, nonatomic) IBOutlet UILabel *mileageLabel; // 里程
@property (weak, nonatomic) IBOutlet UILabel *carLevelLabel; // 车辆类型

@end

@implementation ELHDetailHistoryOrderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setUpNav];
    
    [self setUpDeatilHistoryOrder];
}

- (void)setUpNav {
    self.navigationItem.title = @"订单详情";
    
    // 分享按钮
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_share"] style:UIBarButtonItemStyleDone target:self action:@selector(shareOrder)];
    self.navigationItem.rightBarButtonItem = item;
}

// 订单分享
- (void)shareOrder {
    
     NSString *shareText = [NSString stringWithFormat:@"e拉货-最安全的互联网货运平台 http://www.elahuo.net \n各大app平台搜索下载,注册输入我的邀请码(%@),赢取100元红包大礼!", [[NSUserDefaults standardUserDefaults] objectForKey:@"GOOnlyCode"]];
    [UMSocialSnsService presentSnsIconSheetView:self appKey:UmengAppkey shareText:shareText shareImage:nil shareToSnsNames:@[UMShareToWechatSession,UMShareToWechatTimeline,UMShareToSina,UMShareToQQ] delegate:self];
    
}

-(void)didCloseUIViewController:(UMSViewControllerType)fromViewControllerType
{
    NSLog(@"didClose is %d",fromViewControllerType);
}

//下面得到分享完成的回调
-(void)didFinishGetUMSocialDataInViewController:(UMSocialResponseEntity *)response
{
    NSLog(@"didFinishGetUMSocialDataInViewController with response is %@",response);
    //根据`responseCode`得到发送结果,如果分享成功
    if(response.responseCode == UMSResponseCodeSuccess)
    {
        //得到分享到的平台名
        NSLog(@"share to sns name is %@",[[response.data allKeys] objectAtIndex:0]);
    }
}



/**
 *  设置历史订单详情数据
 */
- (void)setUpDeatilHistoryOrder {
    self.loadTimeLable.text = self.HistoryOrder.ROLOADTIME;
    self.loadLocationLabel.text = self.HistoryOrder.ROLOADSITE;
    self.loadPhoneLabel.text = self.HistoryOrder.COCLOADM;
    self.unloadLocationLabel.text = self.HistoryOrder.ROUNLOADSITE;
    self.unloadPhoneLabel.text = self.HistoryOrder.COCUNLOADM;
    self.mileageLabel.text = [NSString stringWithFormat:@"%@km", self.HistoryOrder.ROKM];
    self.carLevelLabel.text = self.HistoryOrder.COCLEVEL;
}


#pragma mark - UITable相关
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 40;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.00001;
}

@end
