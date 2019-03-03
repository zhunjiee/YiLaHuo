//
//  ELHidentificationViewController.m
//  ELaHuo
//
//  Created by elahuo on 16/3/9.
//  Copyright © 2016年 elahuo. All rights reserved.
//

#import "ELHidentificationViewController.h"
#import "ELHIdentityCardViewController.h"
#import "ELHLicenseViewController.h"
#import <SVProgressHUD.h>
#import "ELHHTTPSessionManager.h"
#import "ELHOCToJson.h"
#import <UIImageView+WebCache.h>
#import "ELHUploadFile.h"

@interface ELHidentificationViewController () <UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
/** 网络请求管理者 */
@property (nonatomic, strong) ELHHTTPSessionManager *manager;

@end

@implementation ELHidentificationViewController
#pragma mark - 懒加载
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

    [self setUpClildViewController];
    
    [self setUpScrollView];
    
    [self canPushData];
    
    
    // 默认选中第一个控制器
    if (self.segmentedControl.selectedSegmentIndex == 0) {
        // 加载数据
        [self segmentedControlClick];
    }
}


- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [SVProgressHUD dismiss];
}

/**
 *  初始化scrollView
 */
- (void)setUpScrollView {
    NSInteger count = self.childViewControllers.count;
    
    self.scrollView.contentSize = CGSizeMake(count * self.view.width, 0);
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.pagingEnabled = YES;
    self.scrollView.bounces = NO;
    
    self.scrollView.delegate = self;
}


/**
 *  添加子控制器
 */
- (void)setUpClildViewController {
    // 身份证
    ELHIdentityCardViewController *idCardVC = [UIStoryboard storyboardWithName:NSStringFromClass([ELHIdentityCardViewController class]) bundle:nil].instantiateInitialViewController;
    [self addChildViewController:idCardVC];

    
    // 营业执照
    ELHLicenseViewController *licenseVC = [UIStoryboard storyboardWithName:NSStringFromClass([ELHLicenseViewController class]) bundle:nil].instantiateInitialViewController;
    [self addChildViewController:licenseVC];

}



/**
 *  初始化导航栏
 */
- (void)setUpNav {
    self.navigationItem.title = @"实名认证";
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"提交" style:UIBarButtonItemStyleDone target:self action:@selector(pushButtonClick)];
    self.navigationItem.rightBarButtonItem = item;
}




/**
 *  初始化认证数据
 */
- (void)setUpIdentificationData {
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSInteger index = self.segmentedControl.selectedSegmentIndex;
    ELHIdentityCardViewController *idCardVC = self.childViewControllers[0];
    ELHLicenseViewController *licenseVC = self.childViewControllers[1];

    NSString *userName = [userDefaults stringForKey:@"GOName"]; // 真实姓名
    NSString *userID = [userDefaults stringForKey:@"GOId"];
    NSString *idCardPictureName = [NSString stringWithFormat:@"GOCardPicture%@.jpg", userID]; // 身份证照片名称
    
    NSString *companyName = [userDefaults stringForKey:@"GOQYMC"]; // 企业名称
    NSString *licenseNumber = [userDefaults stringForKey:@"GOZZH"]; // 营业执照号
    NSString *licenseNumPicName = [NSString stringWithFormat:@"GOZZPicture%@.jpg", userID]; // 营业执照照片名称

    
    // 认证通过后"提交"按钮不可点击
    if (index == 0) { // 显示身份认证界面
        // 取出图片
        UIImage *localImage = [self loadPictureFromCachesPath:idCardPictureName];
        if (userName != nil && localImage != nil) { // 本地有数据
            idCardVC.nameTextField.text = userName;

            BSLog(@"本地身份证图片为 : %@", localImage);
            
            // 展示图片
            idCardVC.takePhotoButton.hidden = YES;
            [idCardVC.idCardPlaceholderImageView setImage:nil];
            
            [idCardVC.idCardImageView setImage:localImage];

            
        } else { // 本地没有图片,去网路下载图片展示
            [idCardVC.idCardPlaceholderImageView setImage:[UIImage imageNamed:@"businessLicense_placeholder"]];
            idCardVC.takePhotoButton.hidden = NO;
            
            if (userID != nil) {
                [SVProgressHUD showWithStatus:@"数据处理中..."];
                
                NSDictionary *dict = @{
                                       @"GOId" : userID,
                                       };
                
                NSDictionary *params = [ELHOCToJson ocToJson:dict];
                
                
                NSString *URL = [NSString stringWithFormat:@"%@GoodsOwner_getGOInfoById.action", ELHBaseURL];
                
                [self.manager POST:URL parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {

                    idCardVC.nameTextField.text = responseObject[@"GOName"]; // 真实姓名
                    [userDefaults setObject:responseObject[@"GOName"] forKey:@"GOName"];
                    
                    // 下载图片
                    NSString *imageURL = [NSString stringWithFormat:@"%@file/DownLoadServlet?imageBNType=GOCardPicture&imageFileName=%@", ELHBaseURL, responseObject[@"GOCardPicture"]];
                    
                    NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageURL]];
                    UIImage *image = [UIImage imageWithData:imageData scale:1.0];
                    BSLog(@"从网络获取身份证照片 :%@ ,大小为 %lu KB", image, imageData.length / 1024);
                    
                    // 保存图片到本地
                    [self savePictureToCachesPath:image imageName:idCardPictureName withScale:1.0];
                    
                    // 展示图片
                    if (image != nil) {
                        idCardVC.takePhotoButton.hidden = YES;
                        [idCardVC.idCardPlaceholderImageView setImage:nil];
                    } else {
                        [idCardVC.idCardPlaceholderImageView setImage:[UIImage imageNamed:@"IDcard_placeholder"]];
                        idCardVC.takePhotoButton.hidden = NO;
                    }
                    
                    // 展示图片
                    [idCardVC.idCardImageView setImage:image];
                    
                    [SVProgressHUD dismiss];
                } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                    BSLog(@"%@", error);
                }];
            }
        }
        
    } else { // 显示企业认证界面
        UIImage *localImage = [self loadPictureFromCachesPath:licenseNumPicName];
        if (userName != nil && localImage != nil) { // 本地有数据
            licenseVC.nameTextField.text = companyName; // 企业名称
            licenseVC.licenseTextField.text = licenseNumber; // 营业执照号
                                    
            // 取出图片
            BSLog(@"本地营业执照照片为 %@", localImage);
            
            // 展示图片
            licenseVC.takePhotoButton.hidden = YES;
            licenseVC.licensePlaceholderImageView.image = nil;
            
            [licenseVC.licenseImageView setImage:localImage];
            
            
        } else { // 本地没有认证信息,去网路下载图片展示
            [licenseVC.licensePlaceholderImageView setImage:[UIImage imageNamed:@"businessLicense_placeholder"]];
            licenseVC.takePhotoButton.hidden = NO;
            
            if (userID != nil) {
                [SVProgressHUD showWithStatus:@"数据处理中..."];
                
                NSDictionary *dict = @{
                                       @"GOId" : userID,
                                       };
                
                NSDictionary *params = [ELHOCToJson ocToJson:dict];
                
                
                NSString *URL = [NSString stringWithFormat:@"%@GoodsOwner_getGOInfoById.action", ELHBaseURL];
                
                [self.manager POST:URL parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                    //        NSLog(@"%@", responseObject);
                    licenseVC.nameTextField.text = responseObject[@"GOQYMC"]; // 真实姓名
                    licenseVC.licenseTextField.text = responseObject[@"GOZZH"]; // 营业执照号
                    [userDefaults setObject:responseObject[@"GOQYMC"] forKey:@"GOQYMC"];
                    [userDefaults setObject:responseObject[@"GOZZH"] forKey:@"GOZZH"];
                    
                    // 下载图片
                    NSString *imageURL = [NSString stringWithFormat:@"%@file/DownLoadServlet?imageBNType=GOZZPicture&imageFileName=%@", ELHBaseURL, responseObject[@"GOZZPicture"]];
                    
                    NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageURL]];
                    UIImage *image = [UIImage imageWithData:imageData scale:1.0];
                    BSLog(@"从网络获取营业执照图片 %@ ,大小为: %lu KB", image, imageData.length / 1024);
                    
                    // 保存图片到本地
                    [self savePictureToCachesPath:image imageName:licenseNumPicName withScale:1.0];
                    
                    // 展示图片
                    if (image != nil) {
                        licenseVC.takePhotoButton.hidden = YES;
                        [licenseVC.licensePlaceholderImageView setImage:nil];
                    } else {
                        [licenseVC.licensePlaceholderImageView setImage:[UIImage imageNamed:@"businessLicense_placeholder"]];
                        licenseVC.takePhotoButton.hidden = NO;
                    }
                    
                    // 展示图片
                    [licenseVC.licenseImageView setImage:image];
                    
                    [SVProgressHUD dismiss];
                } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                    BSLog(@"%@", error);
                }];
            }
        }
    }
    
}


/**
 *  保存图片到caches目录
 */
- (void)savePictureToCachesPath:(UIImage *)image imageName:(NSString *)name withScale:(float)scale {
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSString *cachesPath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject;
        NSString *file = [cachesPath stringByAppendingPathComponent:name];
        NSData *imageData = UIImageJPEGRepresentation(image, scale);
        [imageData writeToFile:file atomically:YES];
    });
}

/**
 *  从caches目录加载图片
 */
- (UIImage *)loadPictureFromCachesPath:(NSString *)pictureName {
    NSString *cachesPath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject;
    NSString *file = [cachesPath stringByAppendingPathComponent:pictureName];
    NSData *imageData = [NSData dataWithContentsOfFile:file];
    UIImage *image = [UIImage imageWithData:imageData];
    return image;
}



/**
 *  点击了提交按钮,提交认证数据
 */
- (void)pushButtonClick {
    // 进行提交前的业务判断
    NSInteger index = self.segmentedControl.selectedSegmentIndex;
    
    ELHIdentityCardViewController *idCardVC = self.childViewControllers[0];
    NSString *idName = idCardVC.nameTextField.text;
    UIImage *idImage = idCardVC.idCardImageView.image;
    
    
    ELHLicenseViewController *licenseVC = self.childViewControllers[1];
    NSString *companyName = licenseVC.nameTextField.text;
    NSString *licenseNumber = licenseVC.licenseTextField.text;
    UIImage *licenseImage = licenseVC.licenseImageView.image;
    
    
    if (index == 0) { // 提交身份认证数据
        if (idName.length == 0 && idImage == nil) {
            [SVProgressHUD showImage:nil status:@"\"真实姓名:\"是必填项"];
            return;
        }
        
        if (idName.length != 0) {
            if (idImage == nil) {
                [SVProgressHUD showImage:nil status:@"\"身份证照片:\"是必填项"];
                return;
            }
        } else if (idImage != nil) {
            if (idName.length == 0) {
                [SVProgressHUD showImage:nil status:@"\"真实姓名:\"是必填项"];
                return;
            }
        }
        
        
        
        if (idName.length != 0 && idImage != nil) {
            // 提交数据
            
            NSString *userID = [[NSUserDefaults standardUserDefaults] stringForKey:@"GOId"];
            NSString *idCardPictureName = [NSString stringWithFormat:@"GOCardPicture%@.jpg", userID];
            
            NSDictionary *dict = @{
                                   @"GOId" : userID, // 货主ID
                                   @"GOName" : idName, // 货主姓名
                                   @"GOCardPicture" : idCardPictureName// 身份证照片名称
                                   };
            
            NSDictionary *params = [ELHOCToJson ocToJson:dict];
            
            
            NSString *URL = [NSString stringWithFormat:@"%@GoodsOwner_updateGO.action", ELHBaseURL];
            
            [SVProgressHUD showWithStatus:@"正在提交中..."];
            [self.manager POST:URL parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                
                // 上传图片
                dispatch_queue_t queue = dispatch_queue_create("upload1", nil);
                dispatch_barrier_async(queue, ^{
                    [self uploadImage:idImage withImageName:idCardPictureName withScale:0.3];
                });
                
                // 创建线程保存用户数据
                dispatch_queue_t myQueue = dispatch_get_global_queue(0, 0);
                dispatch_async(myQueue, ^{
                    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                    [userDefaults setObject:idName forKey:@"GOName"];
                });
                
                
                if ([responseObject[@"resultSign"] intValue] == 1) {
                    [SVProgressHUD showImage:nil status:@"提交数据成功,等待审核"];
                } else {
                    [SVProgressHUD showImage:nil status:@"未知状态"];
                }
                
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                BSLog(@"%@", error);
            }];
            
        }
        
        
        
        
    } else if (index == 1) { // 提交企业认证数据
        
        if (companyName.length == 0 && licenseNumber.length == 0 && licenseImage == nil) {
            [SVProgressHUD showImage:nil status:@"\"企业名称:\"是必填项"];
            return;
        }
        
        if (companyName.length != 0) {
            if (licenseNumber.length == 0) {
                [SVProgressHUD showImage:nil status:@"\"营业执照号:\"是必填项"];
                return;
            } else if (licenseImage == nil) {
                [SVProgressHUD showImage:nil status:@"\"营业执照照片:\"是必填项"];
                return;
            }
        } else if (licenseNumber.length != 0) {
            if (companyName.length == 0) {
                [SVProgressHUD showImage:nil status:@"\"企业名称:\"是必填项"];
                return;
            } else if (licenseImage == nil) {
                [SVProgressHUD showImage:nil status:@"\"营业执照照片:\"是必填项"];
                return;
            }
        } else if (licenseImage != nil) {
            if (companyName.length == 0) {
                [SVProgressHUD showImage:nil status:@"\"企业名称:\"是必填项"];
                return;
            } else if (licenseNumber.length == 0) {
                [SVProgressHUD showImage:nil status:@"\"营业执照号:\"是必填项"];
                return;
            }
        }
        
        if (companyName.length != 0 && licenseNumber.length != 0 && licenseImage != nil) {
            // 提交数据
            NSString *userID = [[NSUserDefaults standardUserDefaults] stringForKey:@"GOId"];
            NSString *licensePictureName = [NSString stringWithFormat:@"GOZZPicture%@.jpg", userID];
            
            NSDictionary *dict = @{
                                   @"GOId" : userID, // 货主ID
                                   @"GOQYMC" : companyName, // 公司名称
                                   @"GOZZH" : licenseNumber, // 营业执照号
                                   @"GOZZPicture" : licensePictureName // 营业执照照片名称
                                   };
            
            NSDictionary *params = [ELHOCToJson ocToJson:dict];
            
            
            NSString *URL = [NSString stringWithFormat:@"%@GoodsOwner_updateGO.action", ELHBaseURL];
            
            [SVProgressHUD showWithStatus:@"正在提交中..."];
            [self.manager POST:URL parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                
                // 上传图片
                dispatch_queue_t queue = dispatch_queue_create("upload1", nil);
                dispatch_barrier_async(queue, ^{
                    [self uploadImage:licenseImage withImageName:licensePictureName withScale:0.3];
                });
                
                
                // 创建线程保存用户数据
                dispatch_queue_t myQueue = dispatch_get_global_queue(0, 0);
                dispatch_async(myQueue, ^{
                    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                    [userDefaults setObject:companyName forKey:@"GOQYMC"]; // 企业名称
                    [userDefaults setObject:licenseNumber forKey:@"GOZZH"]; // 营业执照号
                });
                
                
                if ([responseObject[@"resultSign"] intValue] == 1) {
                    [SVProgressHUD showImage:nil status:@"提交数据成功,等待审核"];
                } else {
                    [SVProgressHUD showImage:nil status:@"未知状态"];
                }
                
                
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                BSLog(@"%@", error);
            }];
        }
        
    }
    
    
    
}


/**
 *  是否可以提交认证数据
 */
- (void)canPushData {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *GOQYRZ = [userDefaults stringForKey:@"GOQYRZ"]; // 企业认证
    NSString *GOSMRZ = [userDefaults stringForKey:@"GOSMRZ"]; // 实名认证

    
    // 认证通过后"提交"按钮不可点击
    if (self.scrollView.contentOffset.x < ScreenW) { // 显示身份认证界面
        
        if (GOSMRZ != nil && [GOSMRZ isEqual:@"1"]) { // 实名认证通过
            self.navigationItem.rightBarButtonItem.enabled = NO;
            // 设置文字相关属性(不能点击显示灰色)
            NSMutableDictionary *notClickAttrs = [NSMutableDictionary dictionary];
            notClickAttrs[NSFontAttributeName] = [UIFont systemFontOfSize:17];
            notClickAttrs[NSForegroundColorAttributeName] = [UIColor grayColor];
            [self.navigationItem.rightBarButtonItem setTitleTextAttributes:notClickAttrs forState:UIControlStateNormal];

            self.childViewControllers.firstObject.view.userInteractionEnabled = NO;
            
        } else {
            self.navigationItem.rightBarButtonItem.enabled = YES;
            self.childViewControllers.firstObject.view.userInteractionEnabled = YES;
            // 设置文字相关属性(能点击显示全局色)
            NSMutableDictionary *canClickAttrs = [NSMutableDictionary dictionary];
            canClickAttrs[NSFontAttributeName] = [UIFont systemFontOfSize:17];
            canClickAttrs[NSForegroundColorAttributeName] = ELHGlobalColor;
            [self.navigationItem.rightBarButtonItem setTitleTextAttributes:canClickAttrs forState:UIControlStateNormal];
        }
        
    } else { // 显示企业认证界面
        if (GOQYRZ != nil && [GOQYRZ isEqual:@"1"]) { // 实名认证通过
            self.navigationItem.rightBarButtonItem.enabled = NO;
            // 设置文字相关属性(不能点击显示灰色)
            NSMutableDictionary *notClickAttrs = [NSMutableDictionary dictionary];
            notClickAttrs[NSFontAttributeName] = [UIFont systemFontOfSize:17];
            notClickAttrs[NSForegroundColorAttributeName] = [UIColor grayColor];
            [self.navigationItem.rightBarButtonItem setTitleTextAttributes:notClickAttrs forState:UIControlStateNormal];
            self.childViewControllers.lastObject.view.userInteractionEnabled = NO;
            
        } else {
            self.navigationItem.rightBarButtonItem.enabled = YES;
            self.childViewControllers.lastObject.view.userInteractionEnabled = YES;
            // 设置文字相关属性(能点击显示全局色)
            NSMutableDictionary *canClickAttrs = [NSMutableDictionary dictionary];
            canClickAttrs[NSFontAttributeName] = [UIFont systemFontOfSize:17];
            canClickAttrs[NSForegroundColorAttributeName] = ELHGlobalColor;
            [self.navigationItem.rightBarButtonItem setTitleTextAttributes:canClickAttrs forState:UIControlStateNormal];
        }
    }
    
    
}

#pragma mark - 监听方法
/**
 *  segmentedControl按钮被点击
 */
- (IBAction)segmentedControlClick {
    // 滚动到对应位置
    NSInteger index = self.segmentedControl.selectedSegmentIndex;

    CGFloat offsetX = index * self.view.width;
    self.scrollView.contentOffset = CGPointMake(offsetX, 0);
    
    // 添加对应的子控制器
    UIViewController *vc = self.childViewControllers[index];
    vc.view.frame = CGRectMake(offsetX, 0, self.scrollView.width, self.scrollView.height);
    
    [self.scrollView addSubview:vc.view];
    
    // 初始化数据
    [self setUpIdentificationData];
    
    // 提交按钮是否可以点击
    [self canPushData];
}




/**
 *  上传图片
 */
- (void)uploadImage:(UIImage *)image withImageName:(NSString *)imageName withScale:(float)scale {
    // ************************* 上传图片 *********************************
    ELHUploadFile *upload = [[ELHUploadFile alloc] init];
    
    NSString *urlString = [NSString stringWithFormat:@"%@file/UploadServlet", ELHBaseURL];
    
//    NSData *data = UIImagePNGRepresentation(image);
    NSData *data = UIImageJPEGRepresentation(image, scale); // 压缩图片
    
    NSMutableDictionary *imageDic = [NSMutableDictionary dictionary];
    [imageDic setValue:data forKey:[NSString stringWithFormat:@"%@", imageName]];
    NSMutableDictionary *pramDic = [NSMutableDictionary dictionary];
    [pramDic setValue:[NSString stringWithFormat:@"%@", image] forKey:@"title"];
    
    [upload uploadFileWithURL:[NSURL URLWithString:urlString] imageDic:imageDic pramDic:pramDic];
}



//将图片保存到本地
- (void)SaveImageToLocal:(UIImage*)image Keys:(NSString*)key {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    //[preferences persistentDomainForName:LocalPath];
    [userDefaults setObject:UIImagePNGRepresentation(image) forKey:key];
}

//本地是否有相关图片
- (BOOL)LocalHaveImage:(NSString*)key {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    //[preferences persistentDomainForName:LocalPath];
    NSData *imageData = [userDefaults objectForKey:key];
    if (imageData) {
        return YES;
    }
    return NO;
}

//从本地获取图片
- (UIImage*)GetImageFromLocal:(NSString*)key {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    //[preferences persistentDomainForName:LocalPath];
    NSData *imageData = [userDefaults objectForKey:key];
    UIImage *image;
    if (imageData) {
        image = [UIImage imageWithData:imageData];
    }
    else {
        BSLog(@"未从本地获得图片");
    }
    return image;
}


static int firstPage = 0;
#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    // 计算滚动到哪一页
    NSInteger index = scrollView.contentOffset.x / scrollView.width;
    
    // 添加子控制器View
    [self showVC:index];
    
    // 选中对应的按钮
    self.segmentedControl.selectedSegmentIndex = index;
    
    
    // 防止拖拽完后(不论有没有滚动到下一页)就刷新数据的bug
    int currentPage = self.scrollView.contentOffset.x / (self.scrollView.contentSize.width * 0.5);
    if (currentPage != firstPage) {
        // 初始化数据
        [self setUpIdentificationData];
        
        firstPage = currentPage;
    }
    
    
   
    
    [self canPushData];
}

/**
 *  显示子控制器View
 */
- (void)showVC:(NSInteger)index {
    CGFloat offseX = index * self.view.width;
    
    UIViewController *vc = self.childViewControllers[index];
    
    // 判断控制器的view没有加载过才加载
    if (vc.view.superview) {
        return;
    }
    
    vc.view.frame = CGRectMake(offseX, 0, self.scrollView.width, self.scrollView.height);
    
    [self.scrollView addSubview:vc.view];
}

@end
