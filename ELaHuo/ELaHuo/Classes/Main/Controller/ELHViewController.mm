//
//  ELHViewController.m
//  ElaHuo
//
//  Created by elahuo on 16/3/7.
//  Copyright © 2016年 elahuo. All rights reserved.
//

#import "ELHViewController.h"
#import "ELHLoginViewController.h"
#import "ELHDeliverViewController.h"
#import "ELHHistoryViewController.h"
#import "ELHAssessViewController.h"
#import "ELHidentificationViewController.h"
#import "IdentityCardViewController.h"
#import "ELHMyWalletViewController.h"
#import "ELHMyCenterViewController.h"
#import "ELHsettingViewController.h"
#import "ELHOrderTableViewController.h"
#import "UIBarButtonItem+Extension.h"
#import "UIImage+Circle.h"
#import "ELHHTTPSessionManager.h"
#import "ELHOrderModel.h"
#import "ELHOrderDetailModel.h"
#import "ELHOCToJson.h"
#import "JPUSHService.h"
#import "ELHAnnotation.h"

/** 菜单左滑的最大距离 */
#define TargetX [UIScreen mainScreen].bounds.size.width * 0.65


@interface ELHViewController () <BMKMapViewDelegate, BMKLocationServiceDelegate, UIGestureRecognizerDelegate, GCDAsyncSocketDelegate, BMKGeoCodeSearchDelegate>
/** 地图视图 */
@property (nonatomic, strong) BMKMapView *mapView;
/** 折叠视图 */
@property (nonatomic, strong) UIView *foldView;
@property (strong, nonatomic) UIButton *foldButton;
/** 位置服务 */
@property (nonatomic, strong) BMKLocationService *locService;
/** 地理编码搜索 */
@property (nonatomic, strong) BMKGeoCodeSearch *searcher;
/** 蒙板视图 */
@property (nonatomic, strong) UIView *HUDView;
/** 是否是第一次定位 */
@property (nonatomic, assign, getter=isFirstLoc) BOOL firstLoc;
/** 网络管理者 */
@property (nonatomic, strong) ELHHTTPSessionManager *manager;
/** 存放订单的数组 */
@property (nonatomic, strong) NSMutableArray *ELHOrderArray;
/** 存放竞价列表(订单详情)的数组 */
@property (nonatomic, strong) NSMutableArray *ELHOrderDetailArray;
/** 存放订单编号的数组 */
@property (nonatomic, strong) NSMutableArray *ELHOrderNumArray;
/** 存放订单状态的数组 */
@property (nonatomic, strong) NSMutableArray *ROStateArray;

/** socket对象 */
@property (nonatomic, strong) GCDAsyncSocket *socket;
/** 存放电子锁编号的数组 */
@property (nonatomic, strong) NSMutableArray *DZSArray;
/** 成交订单司机手机号数组 */
@property (nonatomic, strong) NSMutableArray *dirverPhoneNumArray;

/** 手动定位按钮 */
@property (nonatomic, strong) UIButton *locButton;
/** 经度 */
@property (nonatomic, assign) CGFloat longitude;
/** 纬度 */
@property (nonatomic, assign) CGFloat latitude;
/** 位置信息 */
@property (nonatomic, copy) NSString *myLocation;

/** 位置信息数组 */
@property (nonatomic, strong) NSMutableArray *myLocationArray;
/** 大头针 */
@property (nonatomic, strong) ELHAnnotation *annotation;
/** 存放大头针数组 */
@property (nonatomic, strong) NSMutableArray *annotationArray;

/** 记录上一次的位置 */
@property (nonatomic, strong) CLLocation *preLocation;
/** 记录上一次的位置的数组 */
@property (nonatomic, strong) NSMutableArray *preLocationArray;
/** 存放 上一次的位置的数组 的数组 */
@property (nonatomic, strong) NSMutableArray *preLocationArrayM;
/** 位置数组 */
@property (nonatomic, strong) NSMutableArray *tempLocArray;
/** 位置数组 */
@property (nonatomic, strong) NSMutableArray *locArray;
/** 存放 位置数组 的数组 */
@property (nonatomic, strong) NSMutableArray *locationArrayM;
/** 轨迹线 */
@property (nonatomic, strong) BMKPolyline *polyline;
/** 存放轨迹线数组 */
@property (nonatomic, strong) NSMutableArray *polylineArray;

@property (copy, nonatomic) NSString *DZSBH; // 电子锁编号
@end


@implementation ELHViewController


#pragma mark - 懒加载
/** mapView的懒加载 */
- (BMKMapView *)mapView {
    if (_mapView == nil) {
        CGFloat mapX = 0;
        CGFloat mapY = 0;
        CGFloat mapWidth = self.view.width;
        CGFloat mapHeight = self.view.height - ELHNavY - ELHFoldViewH;
        _mapView = [[BMKMapView alloc] initWithFrame:CGRectMake(mapX, mapY, mapWidth, mapHeight)];
        
        // 添加手动定位按钮
        UIButton *locationButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [locationButton setImage:[UIImage imageNamed:@"pic_location"] forState:UIControlStateNormal];
        [locationButton setImage:[UIImage imageNamed:@"pic_location_highlight"] forState:UIControlStateDisabled];
        [locationButton setImage:[UIImage imageNamed:@"pic_location_highlight"] forState:UIControlStateHighlighted];

        [_mapView addSubview:locationButton];
        self.locButton = locationButton;
        [locationButton addTarget:self action:@selector(locationButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        
        ELHWeakSelf;
        [locationButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(30, 30));
            make.left.equalTo(weakSelf.mapView.mas_left).with.offset(5);
            make.bottom.equalTo(weakSelf.mapView.mas_bottom).with.offset(-5);
        }];

        locationButton.contentEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5);
        
    }
    return _mapView;
}

/** locService的懒加载 */
- (BMKLocationService *)locService {
    if (_locService == nil) {
        _locService = [[BMKLocationService alloc] init];

    }
    return _locService;
}
/** searcher的懒加载 */
- (BMKGeoCodeSearch *)searcher{
    if (!_searcher) {
        _searcher = [[BMKGeoCodeSearch alloc] init];
    }
    return _searcher;
}

/** HUDView的懒加载 */
- (UIView *)HUDView{
    if (!_HUDView) {
        _HUDView = [[UIView alloc] initWithFrame:self.view.bounds];
        _HUDView.backgroundColor = [UIColor blackColor];
    }
    return _HUDView;
}

/** manager的懒加载 */
- (ELHHTTPSessionManager *)manager{
    if (!_manager) {
        _manager = [ELHHTTPSessionManager manager];
        _manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        _manager.operationQueue.maxConcurrentOperationCount = 1;
    }
    return _manager;
}
/** ELHOrderArray的懒加载 */
- (NSMutableArray *)ELHOrderArray{
    if (!_ELHOrderArray) {
        _ELHOrderArray = [NSMutableArray array];
    }
    return _ELHOrderArray;
}
/** ELHOrderDetailArray的懒加载 */
- (NSMutableArray *)ELHOrderDetailArray{
    if (!_ELHOrderDetailArray) {
        _ELHOrderDetailArray = [NSMutableArray array];
    }
    return _ELHOrderDetailArray;
}
/** ELHOrderNumArray的懒加载 */
- (NSMutableArray *)ELHOrderNumArray{
    if (!_ELHOrderNumArray) {
        _ELHOrderNumArray = [NSMutableArray array];
    }
    return _ELHOrderNumArray;
}
/** ROStateArray的懒加载 */
- (NSMutableArray *)ROStateArray{
    if (!_ROStateArray) {
        _ROStateArray = [NSMutableArray array];
    }
    return _ROStateArray;
}
/** DZSArray的懒加载 */
- (NSMutableArray *)DZSArray {
    if (!_DZSArray) {
        _DZSArray = [NSMutableArray array];
    }
    return _DZSArray;
}
/** dirverPhoneNumArray的懒加载 */
- (NSMutableArray *)dirverPhoneNumArray {
    if (!_dirverPhoneNumArray) {
        _dirverPhoneNumArray = [NSMutableArray array];
    }
    return _dirverPhoneNumArray;
}
/** myLocationArray的懒加载 */
- (NSMutableArray *)myLocationArray{
    if (!_myLocationArray) {
        _myLocationArray = [NSMutableArray arrayWithArray:self.DZSArray];
        for (int i = 0; i < _myLocationArray.count ; i++) {
            [_myLocationArray replaceObjectAtIndex:i withObject:@"0"];
        }
    }
    return _myLocationArray;
}
/** annotationArray的懒加载 */
- (NSMutableArray *)annotationArray{
    if (!_annotationArray) {
        _annotationArray = [NSMutableArray arrayWithArray:self.DZSArray];
        for (int i = 0; i < _annotationArray.count; i++) {
            [_annotationArray replaceObjectAtIndex:i withObject:@"0"];
        }
    }
    return _annotationArray;
}

/** tempLocArray的懒加载 */
- (NSMutableArray *)tempLocArray{
    if (!_tempLocArray) {
        _tempLocArray = [NSMutableArray array];
    }
    return _tempLocArray;
}
/** locArray的懒加载 */
- (NSMutableArray *)locArray{
    if (!_locArray) {
        _locArray = [NSMutableArray arrayWithArray:self.DZSArray];
        for (int i = 0; i < _locArray.count; i++) {
            [_locArray replaceObjectAtIndex:i withObject:@"0"];
        }
    }
    return _locArray;
}
/** locationArrayM的懒加载 */
- (NSMutableArray *)locationArrayM{
    if (!_locationArrayM) {
        _locationArrayM = [NSMutableArray arrayWithArray:self.DZSArray];
        for (int i = 0; i < _locationArrayM.count; i++) {
            [_locationArrayM replaceObjectAtIndex:i withObject:[NSMutableArray array]];
        }
    }
    return _locationArrayM;
}
/** preLocationArray的懒加载 */
- (NSMutableArray *)preLocationArray{
    if (!_preLocationArray) {
        _preLocationArray = [NSMutableArray arrayWithArray:self.DZSArray];
        for (int i = 0; i < _preLocationArrayM.count; i++) {
            [_preLocationArrayM replaceObjectAtIndex:i withObject:@"-0.0-"];
        }
    }
    return _preLocationArray;
}
/** preLocationArrayM的懒加载 */
- (NSMutableArray *)preLocationArrayM{
    if (!_preLocationArrayM) {
        _preLocationArrayM = [NSMutableArray arrayWithArray:self.DZSArray];
        for (int i = 0; i < _preLocationArrayM.count; i++) {
            [_preLocationArrayM replaceObjectAtIndex:i withObject:@"-0.0-"];
        }
    }
    return _preLocationArrayM;
}
/** polylineArray的懒加载 */
- (NSMutableArray *)polylineArray{
    if (!_polylineArray) {
        _polylineArray = [NSMutableArray arrayWithArray:self.DZSArray];
        for (int i = 0; i < _polylineArray.count; i++) {
            [_polylineArray replaceObjectAtIndex:i withObject:@"0"];
        }
    }
    return _polylineArray;
}



#pragma mark - 初始化
- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *username = [userDefaults stringForKey:@"name"];
    if (username != nil) {
        // 自动登录,加载用户信息
        [self autoLoginWithUserName:username];
        
    }
    
    // 初始化导航栏
    [self setUpNav];
    // 添加菜单子视图
    [self setUpMenuChildViews];
    // 添加手势
    [self addGestureRecognizer];
    
    // 初始化地图
    [self setUpBaiduMap];
    
    // 注册通知
    [self registerNotification];
    
    // 加载订单列表
    [self setUpOrderView];
    
    

    
    // 定时请求数据(这样做非常的low, 以后要改为服务器推送)
    [self startLoop];
}




/**
 *  加载订单列表视图
 */
- (void)setUpOrderView {
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.autoresizingMask = NO;
    
    ELHOrderTableViewController *orderVC = [[ELHOrderTableViewController alloc] init];
    
    [self addChildViewController:orderVC];
    
    [self.view addSubview:orderVC.tableView];
}


/**
 *  定时发送请求数据
 */
- (void)startLoop{
    [NSThread detachNewThreadSelector:@selector(loopMethod) toTarget:self withObject:nil];
}
- (void)loopMethod{
    // 每5分钟重新请求一次
    [NSTimer scheduledTimerWithTimeInterval:300.0f target:self selector:@selector(loadOrderData) userInfo:nil repeats:YES];
    
    NSRunLoop *loop = [NSRunLoop currentRunLoop];
    
    [loop run];
}

/**
 *  自动登录
 */
- (void)autoLoginWithUserName:(NSString *)username {
//    NSString *registrationID = [JPUSHService registrationID];
    NSString *registrationID = [[NSUserDefaults standardUserDefaults] stringForKey:@"registrationID"];
    if (registrationID.length == 0 || registrationID == nil) {
        registrationID = @"NULL";
    }
    BSLog(@"\n>>>>>>>>>>>>>>> registrationID <<<<<<<<<<<<<<<\n%@", registrationID);
    
    NSDictionary *dict = @{
                           @"GOMobile" : username,
                           @"GOClientId" : registrationID,
                           @"isMandatory" : @"1", // 强制登录
                           };
    
    NSDictionary *params = [ELHOCToJson ocToJson:dict];
    
    NSString *URL = [NSString stringWithFormat:@"%@GoodsOwner_loginGO.action", ELHBaseURL];
    
    [self.manager POST:URL parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSString *resultStr =[[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        NSData *reslutData = [resultStr dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *resultDict = [NSJSONSerialization JSONObjectWithData:reslutData options:NSJSONReadingMutableContainers error:nil];

        
        if ([resultDict[@"resultSign"] intValue] == 1) {
            BSLog(@"-------**********--------自动登录成功--------***********--------");
            // 存储密码到本地
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            [userDefaults setObject:username forKey:@"name"];
            [userDefaults setObject:resultDict[@"GOId"] forKey:@"GOId"];
            [userDefaults setObject:resultDict[@"GOOnlyCode"] forKey:@"GOOnlyCode"];
            
            [userDefaults setObject:resultDict[@"GOQYRZ"] forKey:@"GOQYRZ"]; // 企业认证是否通过：1表示通过，0表示未通过，提示用户去认证后才能进行后续操作
            [userDefaults setObject:resultDict[@"GOSMRZ"] forKey:@"GOSMRZ"]; // 实名认证是否通过：1表示通过，0表示未通过，提示用户去认证后才能进行后续操作
            [userDefaults synchronize];

            // 加载用户信息
            [self loadUserInfo:username andGOQYRZ:resultDict[@"GOQYRZ"] andGOSMRZ:resultDict[@"GOSMRZ"]];
            
            [SVProgressHUD showWithStatus:@"订单加载中"];
            // 加载用户数据
            [self loadOrderData];
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        BSLog(@"%@", error);
    }];
    
}


/**
 *  加载订单数据,设置控件位置
 */
static NSInteger OrderDetailNum = 0;
//static NSString *DZSBH = nil;
- (void)loadOrderData {
    // 清空旧数据
    self.DZSArray = nil;
    self.dirverPhoneNumArray = nil;
    self.ELHOrderArray = nil;
    self.ELHOrderDetailArray = nil;
    self.ELHOrderNumArray = nil;
    self.ROStateArray = nil;
    ELHOrderTableViewController *orderVC = self.childViewControllers.firstObject;
    orderVC.stateArray = nil;
    orderVC.orderDetailArray = nil;
    orderVC.orderArray = nil;
    orderVC.orderNumArray = nil;
    orderVC.confirmTag = 0;
    OrderDetailNum = 0;
    self.DZSBH = nil;
    
    NSString *userID = [[NSUserDefaults standardUserDefaults] stringForKey:@"GOId"];
    BSLog(@"-------GOId(laodOrderData) = %@---------", userID);
    if (userID != nil) {
        BSLog(@"~~~~~*****----- 加载订单数据 -----*****~~~~~");
//        BSLog(@"self.OrderNumArray = %@", self.ELHOrderNumArray);
        NSDictionary *dict = @{
                               @"GOId" : userID,
                               };
        
        NSDictionary *params = [ELHOCToJson ocToJson:dict];
        NSString *URL = [NSString stringWithFormat:@"%@RealtimeOrder_getROListCon12345.action", ELHBaseURL];
        
        ELHWeakSelf;
        [self.manager POST:URL parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            NSString *resultStr =[[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
            NSData *reslutData = [resultStr dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *resultDict = [NSJSONSerialization JSONObjectWithData:reslutData options:NSJSONReadingMutableContainers error:nil];
            BSLog(@"订单详情 : %@", resultDict);
            
            weakSelf.ELHOrderArray = [ELHOrderModel mj_objectArrayWithKeyValuesArray:resultDict];
            orderVC.orderArray = weakSelf.ELHOrderArray;
            
            // 获取订单编号
            for (int i = 0; i < weakSelf.ELHOrderArray.count; i++) {
                ELHOrderModel *model = weakSelf.ELHOrderArray[i];
                
                [weakSelf.ELHOrderNumArray addObject:model.ROBM];
                [weakSelf.ROStateArray addObject:[NSString stringWithFormat:@"%d", model.ROState]];
                
                orderVC.orderNumArray = weakSelf.ELHOrderNumArray;
                
//                BSLog(@"\nOrderNumArray = %@\nROStateArray = %@", weakSelf.ELHOrderNumArray, weakSelf.ROStateArray);
                
                // 获取电子锁
                if (model.COMMCODE != nil) {
                    NSString *dzsbh = [NSString stringWithFormat:@"%@AA", model.COMMCODE];
                    [weakSelf.DZSArray addObject:dzsbh];
                    [weakSelf.dirverPhoneNumArray addObject:model.COId];
                }

            }
            
            NSLog(@"DZSArray----%@", weakSelf.DZSArray);
          
            
            // *****************************向服务器订阅位置信息 ******************************
            if (weakSelf.DZSArray.count != 0) {
                // 截取字符串
                NSString *tempDZSBH = [weakSelf.DZSArray componentsJoinedByString:@""];
                BSLog(@"%@", tempDZSBH);
                self.DZSBH = [tempDZSBH substringToIndex:tempDZSBH.length - 2];
                //            BSLog(@"self.DZSBH = %@", self.DZSBH);
                NSString *username = [[NSUserDefaults standardUserDefaults] objectForKey:@"name"];
                
                // 发送socket请求
                [self subscribeLocationFormServerWithDZSBH:self.DZSBH username:username tag:0];
            }
            
            
            /**
             *  根据 订单编号 获取 竞价订单列表
             */
            NSMutableArray *ordTempArray = [NSMutableArray arrayWithArray:weakSelf.ELHOrderNumArray]; // 创建临时数组用于存放接收到的数据,确保临时数组的长度和你请求到的数据的组数是一样的,这样才能保证你"第几个请求返回的数据放在数组的第几个位置", 这句代码 [tempArray setObject:responseDict atIndexedSubscript:i]; 实现该功能
            if (weakSelf.ELHOrderNumArray != nil) {
                dispatch_queue_t queue = dispatch_queue_create("order", DISPATCH_QUEUE_CONCURRENT);
                dispatch_group_t group = dispatch_group_create();
                
                for (int i = 0; i < weakSelf.ELHOrderNumArray.count ; i++) {
                    ELHOrderModel *orderModel = weakSelf.ELHOrderArray[i];
                    dispatch_group_async(group, queue, ^{
                        NSString *urlStr = [NSString stringWithFormat:@"%@OrderPrice_getOPListByROBM.action", ELHBaseURL];
                        NSURL *url = [NSURL URLWithString:urlStr];
                        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
                        request.HTTPMethod = @"POST";
                        request.HTTPBody = [[NSString stringWithFormat:@"jo={ROBM=\"%@\",ROState=\"%@\"}", weakSelf.ELHOrderNumArray[i], weakSelf.ROStateArray[i]] dataUsingEncoding:NSUTF8StringEncoding];
                        
                        NSURLResponse *response;
                        NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:nil];
                        
                        if (data != nil) {
                            NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
//                             BSLog(@"responseDict=%@", responseDict);
                            // 第几个请求返回的数据放在数组的第几个位置
                            [ordTempArray setObject:responseDict atIndexedSubscript:i];
//                            BSLog(@"车主信息 = %@", ordTempArray);
                            
                            for (NSObject *obj in responseDict) {
                                if (obj != nil && orderModel.ROState == 2) {
                                    OrderDetailNum++;
                                }
                            }
//                            BSLog(@"竞价的司机总数为 = %ld", (long)OrderDetailNum);
                        }

                    });
                }
                
                dispatch_group_notify(group, dispatch_get_main_queue(), ^{
                    // 将所有请求到的数据按顺序放到一个数组中,之后进行别的操作刷新数据就可以了
                    [weakSelf.ELHOrderDetailArray addObjectsFromArray:[ELHOrderDetailModel mj_objectArrayWithKeyValuesArray:ordTempArray]];
                    
                    ELHOrderTableViewController *orderVC = weakSelf.childViewControllers.firstObject;
                    orderVC.orderDetailArray = weakSelf.ELHOrderDetailArray;
//                    BSLog(@"ELHOrderDetailArray=%@", weakSelf.ELHOrderDetailArray);
                    
                    
                    /**
                     *  未折叠的情况下重新布局子控件
                     */
                    if (self.foldButton.selected == NO) {
                        // 展开订单栏
                        [self launchOrderViewWithOrderViewController:orderVC];
                    }
                    
                    [orderVC.tableView reloadData];
                    
                    [SVProgressHUD dismiss];
                });
                
            }
            

        
            // 添加状态标识,用于区分是展开还是关闭状态
            for (int i = 0; i < orderVC.orderArray.count; i++) {
                // 默认所有的分区都是闭合
                [orderVC.stateArray addObject:@"0"];
            }
            
            // 刷新数据
            [orderVC.tableView reloadData];
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            BSLog(@"%@", error);
            [SVProgressHUD dismiss];
        }];
        
    } else {
        // 折叠订单栏
        [self foldOrderViewWithOrderViewController:orderVC];
        [SVProgressHUD dismiss];
    }
    
}


#pragma mark - Socket
- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port {
    BSLog(@"与服务器链接成功,建立通信链接");
    // 客户端链接成功后,要监听数据读取
    [sock readDataWithTimeout:-1 tag:100];
    [sock readDataWithTimeout:-1 tag:102];
}


- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err {
    BSLog(@"与服务器断开链接 %@", err);
}


/**
 *  向服务器订阅位置数据
 */
- (void)subscribeLocationFormServerWithDZSBH:(NSString *)DZSBH username:(NSString *)username tag:(NSInteger)tag {
    // 链接服务器
    GCDAsyncSocket *socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_global_queue(0, 0)];
    NSError *error = nil;
    [socket connectToHost:@"120.76.24.17" onPort:9981 error:&error];
    
    if (error) {
        BSLog(@"socketError=%@", error);
    }
    self.socket = socket;
    
    // 创建socket链接服务器
    if (username != nil) {
        // 登录
        NSString *loginStr = [NSString stringWithFormat:@"(Mobile)Cmd:1,ConnectionType:Socket,GisCommVersionType:TCP_WebGIS,GisID:Android_GIS,SubcribeCommunicateIdArr:%@,SubcribleFlag:true,UserName:dev,loginId:%@,loginPass:dev", DZSBH, username];
        
        [socket writeData:[loginStr dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:100];
        
        // 订阅
        NSString *readStr = [NSString stringWithFormat:@"(Mobile)Cmd:4,ConnectionType:Socket,GisCommVersionType:TCP_WebGIS,GisID:Android_GIS,SubcribeCommunicateIdArr:%@,SubcribleFlag:true,UserName:dev,loginId:%@,loginPass:dev", DZSBH, username];
        
        [socket writeData:[readStr dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:102];

        BSLog(@"订阅成功");
    }
    
    
}



- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag {
    BSLog(@"数据写入成功 + tag = %ld", (long)tag);
    [sock readDataWithTimeout:-1 tag:100];
    [sock readDataWithTimeout:-1 tag:102];
}


- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    
    if (tag == 100) {
        // 登录成功
        
    } else if (tag == 102) {
        // 订阅到地理位置信息
        NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        BSLog(@"\n读取数据:\n--- socket = %@", str);
    
        /**
         *  根据不同的电子锁号绘制大头针
         */
        NSError *error;
        NSDictionary *locDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
        NSString *communicatId = [locDictionary objectForKey:@"communicatId"]; // 电子锁号
        NSString *lon = [locDictionary objectForKey:@"lon"]; // 原始经度
        NSString *lat = [locDictionary objectForKey:@"lat"]; // 原始纬度
//        BSLog(@"原始坐标为:<%@---%@>", lon, lat);
        
        
        
        
        // 向服务器纠偏并向地图添加大头针
        [self correctShiftWithLongitude:lon latitude:lat finishBlock:^(NSArray *correctLocArray) {
            if (correctLocArray.count == 2 && correctLocArray[0] != nil && correctLocArray[1] != nil) {
//                BSLog(@"纠偏后坐标为: <%@---%@>", correctLocArray[0], correctLocArray[1]);
                
                float longitude = [correctLocArray[0] floatValue];
                float latitude = [correctLocArray[1] floatValue];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (lon != nil && lat != nil) {
                        // 遍历存放电子锁的数组
                        for (int i = 0; i < self.DZSArray.count; i++) {
                            // 截取正确的电子锁号
                            NSString *dzsbh = self.DZSArray[i];
                            NSString *dzs = [dzsbh substringToIndex:dzsbh.length - 2];
                            BSLog(@"dzs = %@ communicatId= %@", dzs, communicatId);
                            // 对比电子锁号添加对应位置大头针
                            if ([communicatId isEqual:dzs]) {
                                //发起反向地理编码检索
                                self.searcher.delegate = self;
                                CLLocationCoordinate2D pt = (CLLocationCoordinate2D){[correctLocArray[1] floatValue], [correctLocArray[0] floatValue]};
                                BMKReverseGeoCodeOption *reverseGeoCodeSearchOption = [[BMKReverseGeoCodeOption alloc] init];
                                reverseGeoCodeSearchOption.reverseGeoPoint = pt;
                                [_searcher reverseGeoCode:reverseGeoCodeSearchOption];
                                
                                
                                // 根据tag值移除前一个annotation标注
                                // 移除前一个位置的大头针
                                if (self.annotationArray.count != 0) {
                                    if ([self.annotationArray[i] isKindOfClass:[ELHAnnotation class]]) {
                                        [self.mapView removeAnnotation:self.annotationArray[i]];
                                    }
                                }
                                
                                
                                // 创建一个新的annotation标注
                                ELHAnnotation *annotation = [[ELHAnnotation alloc] init];
                                annotation.tag = i;
                                CLLocationCoordinate2D coor;
                                coor.longitude = longitude;
                                coor.latitude = latitude;
                                annotation.coordinate = coor;
                                [self.mapView addAnnotation:annotation];
//                                BSLog(@"annotation的tag值为:%d", annotation.tag);
                                self.annotation = annotation;

                                
                                // 替换数组内对应位置的大头针标注对象
                                [self.annotationArray setObject:annotation atIndexedSubscript:i];
                                // 重新添加大头针
                                [self.mapView addAnnotation:self.annotationArray[i]];
                                
                                
                                // 绘制运行轨迹
                                CLLocation *userLocation = [[CLLocation alloc] initWithLatitude:[correctLocArray[1] floatValue] longitude:[correctLocArray[0] floatValue]];
                                [self startTrailRouteWithUserLocation:userLocation index:i];

                            } else {
                                continue;
                            }
                        }
            
                    }
                    
                });
            }
        }];
        
    }
    
    // 准备读取下一次数据
    [sock readDataWithTimeout:-1 tag:102];
}

/**
 * 纠正偏移经纬度
 *
 *  @param lat 原始经度
 *  @param lon 原始纬度
 */
- (void)correctShiftWithLongitude:(NSString *)lon latitude:(NSString *)lat finishBlock:(void(^)(NSArray *correctLocArray))finishBlock {
    if ([lat isEqual:@"-0.0"] || [lon isEqual:@"-0.0"]) {
        //        [SVProgressHUD showImage:nil status:@"实时定位失败"];
        return;
        
    } else {
        if (lat != nil && lon != nil) {
            NSDictionary *dict = @{
                                   @"lon" : lon, // 原始经度
                                   @"lat" : lat, // 原始纬度
                                   };
 
            NSDictionary *params = [ELHOCToJson ocToJson:dict];
            
            NSString *URL = [NSString stringWithFormat:@"%@BN_getOffset.action", ELHBaseURL];
            
            [self.manager POST:URL parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
                
                NSDictionary *locDictionary = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
//                BSLog(@"纠偏返回值<responseObject> = %@", responseObject);
                
                NSString *lon = [locDictionary objectForKey:@"lon"]; // 纠正后经度
                NSString *lat = [locDictionary objectForKey:@"lat"]; // 纠正后纬度

                if (lon != nil && lat != nil) {
                    NSArray *tempArray = @[lon, lat];
                    
                    if (finishBlock) {
                        finishBlock(tempArray);
                    }
                }
                
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                BSLog(@"%@", error);
            }];
        }
        
    }
}




#pragma mark - 基础设置
/**
 *  导航栏的相关设置
 */
- (void)setUpNav {
    UIImageView *titleView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 64, 22)];
    titleView.contentMode = UIViewContentModeScaleAspectFit;
    UIImage *image = [UIImage imageNamed:@"logo_title"];
    [titleView setImage:image];
    self.navigationItem.titleView = titleView;
    
    UIBarButtonItem *item = [UIBarButtonItem itemWithTarget:self action:@selector(menuButtonClick) normalImage:[UIImage circleImageNamed:[self imageNameWithLogin]] highlightImage:nil];
    self.navigationItem.leftBarButtonItem = item;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"发货" style:UIBarButtonItemStylePlain target:self action:@selector(deliverButtonClick)];

}

/**
 *  根据是否登录设置导航栏图片
 */
- (NSString *)imageNameWithLogin {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *username = [userDefaults stringForKey:@"name"];
    
    if (username != nil) {
        return @"icon_head_nav";
    } else {
        return @"icon_head_nav_1";
    }
}

/**
 *  创建菜单子视图
 */
- (void)setUpMenuChildViews {
    // 菜单视图
    ELHMenuView *menuView = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([ELHMenuView class]) owner:nil options:nil].lastObject;
    // 设置菜单视图的尺寸
    CGFloat menuViewX = -TargetX;
    CGFloat menuViewY = 0;
    CGFloat menuViewWith = TargetX;
    CGFloat menuViewHeight = ScreenH;
    menuView.frame = CGRectMake(menuViewX, menuViewY, menuViewWith, menuViewHeight);
    
    [self.view addSubview:menuView];
    
    self.menuView = menuView;
    
    self.firstLoc = YES;
    
    // 点击菜单按钮进行界面跳转
    [menuView.loginButton addTarget:self action:@selector(loginButtonDidClick) forControlEvents:UIControlEventTouchUpInside]; // 登录注册
    [menuView.historyOrderButton addTarget:self action:@selector(historyOrderButtonDidClick) forControlEvents:UIControlEventTouchUpInside]; // 历史订单
    [menuView.identificationButton addTarget:self action:@selector(identificationButtonDidClick) forControlEvents:UIControlEventTouchUpInside]; // 实名认证
    [menuView.myWalletButton addTarget:self action:@selector(myWalletButtonDidClick) forControlEvents:UIControlEventTouchUpInside]; // 我的钱包
    [menuView.settingButton addTarget:self action:@selector(settingButtonDidClick) forControlEvents:UIControlEventTouchUpInside]; // 系统设置
}


#pragma mark - 地图相关
/**
 *  初始化地图
 */
- (void)setUpBaiduMap {
    //适配ios7
    if ([[[UIDevice currentDevice] systemVersion] doubleValue] >= 7.0) {
        self.navigationController.navigationBar.translucent = NO;
    }
    
    // 设置logo位置
    self.mapView.logoPosition = BMKLogoPositionRightBottom;
    
    // 添加折叠视图
    UIView *foldView = [[UIView alloc] initWithFrame:CGRectMake(0, self.mapView.height, ScreenW, ELHFoldViewH)];
    foldView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:foldView];
    self.foldView = foldView;
    
    // 添加折叠按钮
    UIButton *foldButton = [UIButton buttonWithType:UIButtonTypeCustom];
    foldButton.frame = CGRectMake(0, 0, 50, ELHFoldViewH);
    [foldButton setImage:[UIImage imageNamed:@"icon_fold"] forState:UIControlStateNormal];
    [foldButton setImage:[UIImage imageNamed:@"icon_fold_selected"] forState:UIControlStateSelected];
    [foldButton addTarget:self action:@selector(foldButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
    self.foldButton = foldButton;
    [foldView addSubview:foldButton];
    
    // 支持双击放大等手势操作
    self.mapView.gesturesEnabled = YES;
    
    // 显示比例尺
    self.mapView.showMapScaleBar = YES;
    // 设置比例尺的位置
    self.mapView.mapScaleBarPosition = CGPointMake(40, CGRectGetMaxY(self.mapView.frame) - 30);
    
    //进入地图开始显示自己的坐标(开启定位服务)
    [self.locService startUserLocationService];
    self.mapView.showsUserLocation = YES;
    
    self.mapView.userTrackingMode = BMKUserTrackingModeNone;
    
    [self.mapView setZoomLevel:17]; // 地图缩放比例
    
    [self.view addSubview:self.mapView];
    
    
    //设置定位图层自定义样式
    BMKLocationViewDisplayParam *userlocationStyle = [[BMKLocationViewDisplayParam alloc] init];
    // 隐藏精度圈
    userlocationStyle.isAccuracyCircleShow = NO;
    //定位图标
    userlocationStyle.locationViewImgName = @"location";
    //更新参样式信息
    [_mapView updateLocationViewWithParam:userlocationStyle];
    
    // 添加自定义手势
    [self addCustomGestures];
    
    
    

}

- (void)viewWillAppear:(BOOL)animated {
    [self.mapView viewWillAppear];
    self.mapView.delegate = self; // 此处记得不用的时候需要置nil，否则影响内存的释放
    self.locService.delegate = self;
    
    // 重新加载订单数据
//    BSLog(@"<<<<<_____________重新加载数据_____________>>>>>")
//    [self loadOrderData];
}

-(void)viewWillDisappear:(BOOL)animated {
    [self.mapView viewWillDisappear];
    self.mapView.delegate = nil; // 不用时，置nil
    self.locService.delegate = nil;
    self.searcher.delegate = nil;
}

- (void)dealloc {
    // 移除通知
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    self.mapView = nil;

}

/**
 *  接收反向地理编码结果,并创建大头针,将地理位置显示在大头针气泡
 *
 */
- (void)onGetReverseGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKReverseGeoCodeResult *)result errorCode:(BMKSearchErrorCode)error{
  if (error == BMK_SEARCH_NO_ERROR) {
      // 在此处理正常结果
      self.myLocation = result.address;
      
      // 设置泡泡标题
      self.annotation.title = self.myLocation;
  }else {
      BSLog(@"抱歉，未找到结果");
  }
}


/**
 *  开始记录轨迹
 *
 *  @param userLocation 实时更新的位置信息
 */
- (void)startTrailRouteWithUserLocation:(CLLocation *)userLocation index:(NSInteger)index {
    // 计算本次定位与上次定位之间的距离
    BSLog(@"index = %ld", (long)index);
    if (self.preLocationArray.count != 0 && self.preLocationArrayM.count != 0 && self.preLocationArrayM.count == self.DZSArray.count) {
        
        CLLocation *preLocation = self.preLocationArrayM[index];
        
        // 没有存储过位置信息
        if (preLocation != nil && ![preLocation isKindOfClass:[CLLocation class]]) {
            // 将当前位置保存为前一个点的位置
//            [self.preLocationArray replaceObjectAtIndex:index withObject:userLocation];
//            BSLog(@"\n没有保存过preLocationArray!!! = %@", self.preLocationArray);
            // 替换对应位置数组
            [self.preLocationArrayM replaceObjectAtIndex:index withObject:userLocation];
            BSLog(@"\n没有保存过preLocationArrayM!!! = %@", self.preLocationArrayM);
            
        } else if (preLocation != nil && [preLocation isKindOfClass:[CLLocation class]]) {
            // 有前一个位置且位置信息不为(0.0 , 0.0)
            if (preLocation.coordinate.latitude != 0.0 && preLocation.coordinate.longitude != 0.0) {
                CGFloat distance = [userLocation distanceFromLocation:preLocation];
                BSLog(@"与上一位置点的距离为:%f", distance);
                
                // 小于5米忽略
                if (distance < 10) {
                    return;
                }
                
//                BSLog(@"self.locArray = %@", self.locArray);
//                // 将符合的位置点存储到数组中
//                BSLog(@"\nindex%ld的locArray = %@", (long)index, self.locArray[index]);
//                [self.tempLocArray addObject:userLocation];
//                [self.locArray[index] replaceObjectAtIndex:index withObject:self.tempLocArray];
//                BSLog(@"self.locArray = %@", self.locArray);
                // 存放多条运行轨迹
                NSMutableArray *tempLocArray = self.locationArrayM[index];
                BSLog(@"tempLocArray = %@" ,tempLocArray);
                [tempLocArray addObject:userLocation];
                [self.locationArrayM replaceObjectAtIndex:index withObject:tempLocArray];
                BSLog(@"\nlocationArrayM = %@", self.locationArrayM);
                
                // 保存前一个点的位置
//                [self.preLocationArray replaceObjectAtIndex:index withObject:preLocation];
//                BSLog(@"\n替换self.preLocationArray = %@", self.preLocationArray);
                [self.preLocationArrayM replaceObjectAtIndex:index withObject:preLocation];
                BSLog(@"\n替换self.preLocationArrayM = %@", self.preLocationArrayM);
                
                // 绘制运行轨迹
                [self drawRoutePolyLineWithIndex:index];
            }
            
        } else {
            return;
        }
        
        
        
    } else {
        return;
    }
    
    
}


/**
 *  绘制轨迹路线
 */
- (void)drawRoutePolyLineWithIndex:(NSInteger)index {
    // 轨迹点数组个数
    NSArray *locationArray = self.locationArrayM[index];
    NSUInteger count = locationArray.count;
    
    // 动态分配存储空间
    // BMKMapPoint是个结构体：地理坐标点，用直角地理坐标表示 X：横坐标 Y：纵坐标
    BMKMapPoint *tempPoints = new BMKMapPoint[count];
    
    [locationArray enumerateObjectsUsingBlock:^(CLLocation *location, NSUInteger idx, BOOL * _Nonnull stop) {
        BMKMapPoint locationPoint = BMKMapPointForCoordinate(location.coordinate);
        tempPoints[idx] = locationPoint;
    }];
    
    // 移除原有的绘图
    if (self.polylineArray[index]) {
        [self.mapView removeOverlay:self.polylineArray[index]];
    }
    
    // 通过points构建BMKPolyline
    BMKPolyline *polyline = [BMKPolyline polylineWithPoints:tempPoints count:count];
    [self.polylineArray replaceObjectAtIndex:index withObject:polyline];
    
    // 添加路线,绘图
    if (self.polylineArray[index]) {
        [self.mapView addOverlay:self.polylineArray[index]];
        
        
        // 移动到大头针对应位置
        CLLocation *carLocation = locationArray.lastObject;
        if (carLocation != nil) {
            CLLocationCoordinate2D pt = (CLLocationCoordinate2D){carLocation.coordinate.latitude, carLocation.coordinate.longitude};
            self.mapView.centerCoordinate = pt;
            
        }

    }
    
    // 清空tempPoints 内存
    delete [] tempPoints;
    
//    [self mapViewFitPolyline:self.polyline];
}

/**
 *  根据polyline设置地图范围
 *
 *  @param polyline
 */
- (void)mapViewFitPolyline:(BMKPolyline *)polyline {
    CGFloat ltX, ltY, rbX, rbY;
    if (polyline.pointCount < 1) {
        return;
    }
    BMKMapPoint pt = polyline.points[0];
    ltX = pt.x, ltY = pt.y;
    rbX = pt.x, rbY = pt.y;
    for (int i = 0; i < polyline.pointCount; i++) {
        BMKMapPoint pt = polyline.points[i];
        if (pt.x < ltX) {
            ltX = pt.x;
        }
        if (pt.x > rbX) {
            rbX = pt.x;
        }
        if (pt.y > ltY) {
            ltY = pt.y;
        }
        if (pt.y < rbY) {
            rbY = pt.y;
        }
    }
    BMKMapRect rect;
    rect.origin = BMKMapPointMake(ltX , ltY);
//    rect.size = BMKMapSizeMake(rbX - ltX, rbY - ltY);
    [self.mapView setVisibleMapRect:rect];
    self.mapView.zoomLevel = self.mapView.zoomLevel - 0.3;
}


/**
 *  根据overlay生成对应的view
 */
- (BMKOverlayView *)mapView:(BMKMapView *)mapView viewForOverlay:(id<BMKOverlay>)overlay {
    if ([overlay isKindOfClass:[BMKPolyline class]]) {
        BMKPolylineView* polylineView = [[BMKPolylineView alloc] initWithOverlay:overlay];
        polylineView.fillColor = [[UIColor clearColor] colorWithAlphaComponent:0.7];
        polylineView.strokeColor = [[UIColor greenColor] colorWithAlphaComponent:0.8];
        polylineView.lineWidth = 3.0;
        return polylineView;
    }
    return nil;
}


/**
 *  地图标注大头针
 */
- (BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id <BMKAnnotation>)annotation {
    if ([annotation isKindOfClass:[BMKPointAnnotation class]]) {
        BMKPinAnnotationView *newAnnotationView = [[BMKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"myAnnotation"];
        newAnnotationView.pinColor = BMKPinAnnotationColorPurple;
        newAnnotationView.animatesDrop = NO;// 设置该标注点动画显示
        return newAnnotationView;
    }
    return nil;
}


//处理方向变更信息
- (void)didUpdateUserHeading:(BMKUserLocation *)userLocation {
    if (self.isFirstLoc) {
        [self.mapView updateLocationData:userLocation];
        self.mapView.centerCoordinate = userLocation.location.coordinate;
    }
    self.firstLoc = NO;
    self.locButton.enabled = YES;
}
//处理位置坐标更新
- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation {
    if (self.isFirstLoc) {
        [self.mapView updateLocationData:userLocation];
        
        self.mapView.centerCoordinate = userLocation.location.coordinate;
    }
    
    self.firstLoc = NO;
    self.locButton.enabled = YES;
}

/**
 *  添加双击手势放大地图
 */
- (void)addCustomGestures {
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    doubleTap.delegate = self;
    doubleTap.numberOfTapsRequired = 2;
    doubleTap.cancelsTouchesInView = NO;
    doubleTap.delaysTouchesEnded = NO;
    
    [self.mapView addGestureRecognizer:doubleTap];

    doubleTap.delegate = self;
}
- (void)handleDoubleTap:(UITapGestureRecognizer *)theDoubleTap {
    // 放大地图
    [self.mapView zoomIn];
}




#pragma mark - 外部监控方法
/**
 *  点击了折叠按钮
 */
- (void)foldButtonDidClick:(UIButton *)button {
    button.selected = !button.isSelected;
    BSLog(@"折叠折叠");
    ELHOrderTableViewController *orderVC = self.childViewControllers.firstObject;
    if (button.isSelected) {
        [self foldOrderViewWithOrderViewController:orderVC];
    } else {
        [self launchOrderViewWithOrderViewController:orderVC];
    }
}
/**
 *  折叠订单栏
 */
- (void)foldOrderViewWithOrderViewController:(ELHOrderTableViewController *)orderVC {
    self.mapView.frame = CGRectMake(0, 0, ScreenW, ScreenH - ELHNavY - ELHFoldViewH);
    orderVC.tableView.frame = CGRectMake(0, CGRectGetMaxY(self.mapView.frame), 0, 0);
    self.foldView.frame = CGRectMake(0, self.mapView.height, ScreenW, ELHFoldViewH);
    // 重新设置地图比例尺的位置
    self.mapView.showMapScaleBar = YES;
    self.mapView.mapScaleBarPosition = CGPointMake(40, CGRectGetMaxY(self.mapView.frame) - 30);
}
/**
 *  展开订单栏
 */
- (void)launchOrderViewWithOrderViewController:(ELHOrderTableViewController *)orderVC {
    // ************************布局子控件*******************************
    NSInteger count = self.ELHOrderArray.count;
    
    CGFloat tableViewY = ScreenH - count * ELHOrderH - OrderDetailNum * ELHBiddingOrderH - ELHNavY;
    CGFloat tableViewH = count * ELHOrderH + OrderDetailNum * ELHBiddingOrderH;
    
    if (tableViewY < ELHFoldViewH) {
        tableViewY = ELHFoldViewH;
    }
    
    if (tableViewH > ScreenH - ELHNavY - ELHFoldViewH) {
        tableViewH = ScreenH - ELHNavY - ELHFoldViewH;
    }
    
    orderVC.tableView.frame = CGRectMake(0, tableViewY, ScreenW, tableViewH);
    
    if (tableViewY != ELHFoldViewH) {
        self.mapView.showMapScaleBar = YES;
        self.mapView.frame = CGRectMake(0, 0, ScreenW, tableViewY - ELHFoldViewH);
        self.foldView.frame = CGRectMake(0, self.mapView.height, ScreenW, ELHFoldViewH);
        // 重新设置地图比例尺的位置
        self.mapView.mapScaleBarPosition = CGPointMake(40, CGRectGetMaxY(self.mapView.frame) - 30);
    } else {
        self.mapView.showMapScaleBar = NO;
        self.mapView.frame = CGRectMake(0, -ScreenH, ScreenW, ScreenH);
        
        self.foldView.frame = CGRectMake(0, 0, ScreenW, ELHFoldViewH);
    }
    // ************************布局子控件*******************************
}
/**
 *  点击了定位按钮
 */
- (void)locationButtonClick:(UIButton *)button {
    self.locButton.enabled = NO;

    // 重新加载订单数据
    [self loadOrderData];
    [self.mapView setZoomLevel:17]; // 地图缩放比例
    // 重新定位
    self.firstLoc = YES;
    [self.locService startUserLocationService];
}

/**
 *  订单被点击,展开订单列表,重新计算高度
 */
- (void)orderDidClick {
    // 重新计算mapView的高度
    ELHOrderTableViewController *orderVC = self.childViewControllers.firstObject;
    self.mapView.height = ScreenH - orderVC.tableView.height - 63;
    
    // 重新设置地图比例尺的位置
    self.mapView.mapScaleBarPosition = CGPointMake(40, CGRectGetMaxY(self.mapView.frame) - 30);
}


/**
 *  进入主界面后,加载以前登录的用户数据
 */
- (void)loadUserInfo:(NSString *)username andGOQYRZ:(NSString *)GOQYRZ andGOSMRZ:(NSString *)GOSMRZ  {
    if (username != nil) {
        [self.menuView.loginButton setTitle:username forState:UIControlStateNormal];
        
        UIBarButtonItem *item = [UIBarButtonItem itemWithTarget:self action:@selector(menuButtonClick) normalImage:[UIImage circleImageNamed:@"icon_head_nav"] highlightImage:nil];
        self.navigationItem.leftBarButtonItem = item;
        
        [self.menuView.loginButton setTitleColor:ELHGlobalColor forState:UIControlStateNormal];
        [self.menuView.loginButton setImage:[UIImage imageNamed:@"icon_head"] forState:UIControlStateNormal];
    }
    
    if (GOQYRZ != nil && [GOQYRZ isEqual:@"1"]) {
        self.menuView.companyIdentity.selected = YES;
    }
    
    if (GOSMRZ != nil && [GOSMRZ isEqual:@"1"]) {
        self.menuView.trueNameIdentity.selected = YES;
    }
}

/**
 *  登录后显示用户名
 */
- (void)showUserName {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *username = [userDefaults stringForKey:@"name"];
    NSString *GOQYRZ = [userDefaults stringForKey:@"GOQYRZ"]; // 企业认证
    NSString *GOSMRZ = [userDefaults stringForKey:@"GOSMRZ"]; // 实名认证
    
    // 显示用户名
    [self loadUserInfo:username andGOQYRZ:GOQYRZ andGOSMRZ:GOSMRZ];

}

/**
 *  点击了菜单图标
 */
- (void)menuButtonClick {
    if (CGRectGetMaxX(self.menuView.frame) <= 0) {
        [UIView animateWithDuration:0.3 animations:^{
            self.menuView.frame = [self frameWithOffsetX:TargetX];
            [self setUpHUDWithMenuView:self.menuView];
        }];
    } else if (CGRectGetMaxX(self.menuView.frame) >= ScreenW * 0.4) {
        [UIView animateWithDuration:0.3 animations:^{
            self.menuView.frame = [self frameWithOffsetX:-TargetX];
            [self removeHUDView];
        }];
    }
    
    
}

/**
 *  发货
 */
- (void)deliverButtonClick {
    if (CGRectGetMaxX(self.menuView.frame) > 0) {
        [self menuButtonClick];
    }
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *name = [userDefaults objectForKey:@"name"];
    
    // 没有登录 跳转到登录界面
    if (name == nil) {
        [SVProgressHUD showImage:nil status:@"请您先登录"];
        ELHLoginViewController *loginVC = [UIStoryboard storyboardWithName:NSStringFromClass([ELHLoginViewController class]) bundle:nil].instantiateInitialViewController;
        [self.navigationController pushViewController:loginVC animated:YES];
    } else {
        // 登录后 跳转到发货界面
        ELHDeliverViewController *deliverVC = [UIStoryboard storyboardWithName:NSStringFromClass([ELHDeliverViewController class]) bundle:nil].instantiateInitialViewController;
        
        [self.navigationController pushViewController:deliverVC animated:YES];
    }
}


/**
 *  登录/注册
 */
- (void)loginButtonDidClick {
    if ([[NSUserDefaults standardUserDefaults] stringForKey:@"name"] != nil) {
        // 登录状态,进入个人中心
        ELHMyCenterViewController *myCenterVC = [UIStoryboard storyboardWithName:NSStringFromClass([ELHMyCenterViewController class]) bundle:nil].instantiateInitialViewController;
        [self.navigationController pushViewController:myCenterVC animated:YES];
        
    } else {
        // 未登录,进入登录界面
        ELHLoginViewController *loginVC = [UIStoryboard storyboardWithName:NSStringFromClass([ELHLoginViewController class]) bundle:nil].instantiateInitialViewController;
        [self.navigationController pushViewController:loginVC animated:YES];
    }
}
/**
 *  历史订单
 */
- (void)historyOrderButtonDidClick {
    ELHHistoryViewController *historyVC = [[ELHHistoryViewController alloc] init];
    [self menuButtonDidClick:historyVC];
}
/**
 *  实名认证
 */
- (void)identificationButtonDidClick {
    // 老界面
//    ELHidentificationViewController *identificationVC = [UIStoryboard storyboardWithName:NSStringFromClass([ELHidentificationViewController class]) bundle:nil].instantiateInitialViewController;
    
    // 新界面
    IdentityCardViewController *identificationVC = [UIStoryboard storyboardWithName:@"IdentificationViewController" bundle:nil].instantiateInitialViewController;
    
    [self menuButtonDidClick:identificationVC];
}
/**
 *  我的钱包
 */
- (void)myWalletButtonDidClick {
    ELHMyWalletViewController *myWalletVC = [[ELHMyWalletViewController alloc] init];
    [self menuButtonDidClick:myWalletVC];
}
/**
 *  系统设置
 */
- (void)settingButtonDidClick {
    ELHsettingViewController *settingVC = [UIStoryboard storyboardWithName:NSStringFromClass([ELHsettingViewController class]) bundle:nil].instantiateInitialViewController;
    [self menuButtonDidClick:settingVC];
    
}

/**
 *  点击菜单里面相应的按钮后进行逻辑判断并跳转到相应的控制器
 */
- (void)menuButtonDidClick:(UIViewController *)viewController {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *username = [userDefaults stringForKey:@"name"];
    
    if (username != nil) {
        [self menuButtonClick];

        [self.navigationController pushViewController:viewController animated:YES];
    } else {
        [SVProgressHUD showImage:nil status:@"请您先登录"];
        return;
    }
}

/**
 *  退出登录,登录按钮显示为"登录/注册"
 */
- (void)cancelLogin {
    UIBarButtonItem *item = [UIBarButtonItem itemWithTarget:self action:@selector(menuButtonClick) normalImage:[UIImage circleImageNamed:@"icon_head_nav_1"] highlightImage:nil];
    self.navigationItem.leftBarButtonItem = item;
    [self.menuView.loginButton setTitle:@"登录/注册" forState:UIControlStateNormal];
    [self.menuView.loginButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [self.menuView.loginButton setImage:[UIImage imageNamed:@"icon_head_1"] forState:UIControlStateNormal];
    self.menuView.trueNameIdentity.selected = NO;
    self.menuView.companyIdentity.selected = NO;
    
    // 移除地图覆盖物
    [self.mapView removeAnnotations:self.annotationArray];
    [self.mapView removeOverlays:self.polylineArray];
    
    // 加载订单数据
    [self loadOrderData];
}

/**
 *  确认送达,重新加载订单数据
 */
- (void)confirmServiceButtonDidClick {
    ELHOrderTableViewController *orderVC = self.childViewControllers.firstObject;
    // 1. 移除对应订单的大头针标注
    BSLog(@"self.annotationArray = %@", self.annotationArray);
    if (self.annotationArray.count != 0) {
        if ( self.annotationArray[orderVC.confirmTag] != nil) {
            [self.mapView removeAnnotation:self.annotationArray[orderVC.confirmTag]];
            [self.annotationArray removeObjectAtIndex:orderVC.confirmTag];
        } else {
            return;
        }
    } else {
        return;
    }
    // 清除对应订单的位置信息
    [self.myLocationArray removeObjectAtIndex:orderVC.confirmTag];

    
    // 2. 移除对应运行轨迹线
    if (self.polylineArray.count != 0) {
        if (self.polylineArray[orderVC.confirmTag] != nil) {
            [self.mapView removeOverlay:self.polylineArray[orderVC.confirmTag]];
        } else {
            return;
        }
    } else {
        return;
    }
    // 清除运行轨迹线对应的位置信息
    [self.locationArrayM removeObjectAtIndex:orderVC.confirmTag];
    [self.preLocationArrayM removeObjectAtIndex:orderVC.confirmTag];
    
    
    // 重新加载订单数据
    [self loadOrderData];
}

/**
 *  发货成功
 */
- (void)deliverSuccess {
    [SVProgressHUD showWithStatus:@"更新订单数据"];
    // 重新加载订单数据
    [self loadOrderData];
}


/**
 *  取消订单,重新加载订单数据
 */
- (void)cancelOrderButtonClick {
    [SVProgressHUD showWithStatus:@"更新订单数据"];
    // 重新加载订单数据
    [self loadOrderData];
}


/**
 *  跳转到历史订单界面
 */
- (void)jumpToAssessOrderView:(NSNotification *)notification {
    NSDictionary *extras = notification.userInfo;
    ELHAssessViewController *assessVC = [UIStoryboard storyboardWithName:NSStringFromClass([ELHAssessViewController class]) bundle:nil].instantiateInitialViewController;
    // 设置数据
    assessVC.COId = [NSString stringWithFormat:@"%@", [extras valueForKey:@"COId"]];
    assessVC.ROId = [NSString stringWithFormat:@"%@", [extras valueForKey:@"ROId"]];
    [self.navigationController pushViewController:assessVC animated:YES];
}

/**
 *  跳转到重新登录页面
 */
- (void)jumpToRestartLoginView {
    ELHLoginViewController *loginVC = [UIStoryboard storyboardWithName:NSStringFromClass([ELHLoginViewController class]) bundle:nil].instantiateInitialViewController;
    [self.navigationController pushViewController:loginVC animated:YES];
}


/**
 *  注册监听通知
 */
- (void)registerNotification {
    // 监听到登录成功的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showUserName) name:ELHLoginSuccessNotification object:nil];
    
    // 监听到退出登录的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cancelLogin) name:ELHCancelLoginNotification object:nil];
    
    // 监听 确认送达 的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(confirmServiceButtonDidClick) name:ELHConfirmServiceNotification object:nil];

    // 监听 发货成功,刷新订单界面
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deliverSuccess) name:ELHDeliverSuccessNotification object:nil];
    // 监听 支付成功 的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deliverSuccess) name:ELHcomplePayNotification object:nil];
    
    // 监听到取消订单的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cancelOrderButtonClick) name:ELHcancelOrderButtonClickNotification object:nil];
    
    // 监听到订单完成自定义消息的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(jumpToAssessOrderView:) name:JumpToHistoryOrderViewNotification object:nil];
    
    // 监听到强制登出自定义消息的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(jumpToRestartLoginView) name:forceLogoutNotification object:nil];
}


#pragma mark - 手势相关
/**
 *  添加手势
 */
- (void)addGestureRecognizer {
    // 添加屏幕边缘拖拽手势
    UIScreenEdgePanGestureRecognizer *screenEdgePan = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(screenEdgePan:)];
    screenEdgePan.edges = UIRectEdgeLeft;
    [self.view addGestureRecognizer:screenEdgePan];
    
    // 添加点按手势
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    [self.HUDView addGestureRecognizer:tap];
    tap.delegate = self;
    
    // 添加拖拽手势
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    [self.menuView addGestureRecognizer:pan];
}


/**
 *  点按手势:点击屏幕时复位
 */
- (void)tap:(UITapGestureRecognizer *)tap {
    if (CGRectGetMaxX(self.menuView.frame) > 0) {
        [UIView animateWithDuration:0.3 animations:^{
            self.menuView.frame = [self frameWithOffsetX:-TargetX];
            [self removeHUDView];
        }];
    }
}
/**
 *  屏幕边缘拖拽手势:显示菜单
 */
- (void)screenEdgePan:(UIScreenEdgePanGestureRecognizer *)screenEdgePan {
    [self addPanGestureRecognizer:screenEdgePan];
}

/**
 *  菜单左滑返回手势
 */
- (void)pan:(UIPanGestureRecognizer *)pan {
    [self addPanGestureRecognizer:pan];
}

/**
 *  添加拖拽手势
 */
- (void)addPanGestureRecognizer:(UIPanGestureRecognizer *)gesture {
    // 拖拽mainView,展示菜单视图
    CGFloat offsetX = [gesture translationInView:self.menuView].x;
    
    self.menuView.frame = [self frameWithOffsetX:offsetX];
    
    // 防止滑动过了
    if (self.menuView.x > 0) {
        self.menuView.x = 0;
    }
    
    // 菜单显示的时候主view上覆盖蒙板
    [self setUpHUDWithMenuView:self.menuView];
    
    
    // 复位
    [gesture setTranslation:CGPointZero inView:self.menuView];
    
    // 手指抬起的时候定位
    if (gesture.state == UIGestureRecognizerStateEnded) {
        CGFloat maxX = CGRectGetMaxX(self.menuView.frame);
        if (maxX > ScreenW * 0.45) {
            
            CGFloat offsetX = TargetX - maxX;
            
            [UIView animateWithDuration:0.3 animations:^{
                self.menuView.frame = [self frameWithOffsetX:offsetX];
            }];
        } else if (maxX < ScreenW * 0.45) {
            CGFloat offsetX = -maxX;
            
            [UIView animateWithDuration:0.3 animations:^{
                self.menuView.frame = [self frameWithOffsetX:offsetX];
                [self removeHUDView];
            }];
        }
    }
}

/**
 *  消除view间手势的影响
 */
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([touch.view isDescendantOfView:self.menuView]) {
        return NO;
    }
    return YES;
}



#pragma mark - 其他
/**
 *  创建蒙板视图
 *
 *  @param offsetX 手势偏移位置
 */
- (void)setUpHUDWithMenuView:(UIView *)menuView {
    CGFloat maxX = CGRectGetMaxX(menuView.frame);
    self.HUDView.alpha = maxX / TargetX;
    [self.view addSubview:self.HUDView];
    // menuView显示在最前边
    [self.view bringSubviewToFront:self.menuView];
}

/**
 *  移除蒙板视图
 */
- (void)removeHUDView {
    [self.HUDView removeFromSuperview];
}

/**
 *  根据offsetX计算菜单视图的位置
 */
- (CGRect)frameWithOffsetX:(CGFloat)offsetX {
    CGRect tempFrame = self.menuView.frame;
    tempFrame.origin.x += offsetX;
    self.menuView.frame = tempFrame;
    return self.menuView.frame;
}



@end
