//
//  ELHAssessViewController.m
//  ELaHuo
//
//  Created by elahuo on 16/5/16.
//  Copyright © 2016年 elahuo. All rights reserved.
//

#import "ELHAssessViewController.h"
#import "ELHHistoryOrderModel.h"
#import "RatingBar.h"
#import <SVProgressHUD.h>
#import "ELHHTTPSessionManager.h"
#import "ELHOCToJson.h"

@interface ELHAssessViewController () <RatingBarDelegate, UITextViewDelegate>
/** 评价星星 */
@property (nonatomic, strong) RatingBar *ratingBar;

/** 星星个数 */
@property (nonatomic, assign) float starCount;

// 评价等级文字
@property (weak, nonatomic) IBOutlet UILabel *assessLevelLabel;
// 占位文字
@property (weak, nonatomic) IBOutlet UILabel *placeholderLable;
// 文本框
@property (weak, nonatomic) IBOutlet UITextView *textView;

/** 网络请求管理者 */
@property (nonatomic, strong) ELHHTTPSessionManager *manager;

@end

@implementation ELHAssessViewController
#pragma mark - 懒加载
/** manager的懒加载 */
- (ELHHTTPSessionManager *)manager{
    if (!_manager) {
//        _manager.responseSerializer = [AFHTTPResponseSerializer serializer];
//        [_manager.responseSerializer setAcceptableContentTypes:[NSSet setWithObjects:@"application/json", @"text/html", @"text/json", @"text/javascript", @"application/x-javascript", nil]];
        _manager = [ELHHTTPSessionManager manager];
    }
    return _manager;
}


#pragma mark - 初始化
- (void)viewDidLoad {
    [super viewDidLoad];

    [self setUpNav];
    
    [self setUpRatingStar];
}

- (void)setUpNav {
    self.navigationItem.title = @"发表评价";
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"发表" style:UIBarButtonItemStylePlain target:self action:@selector(confirmAssess)];
    
    self.textView.delegate = self;
}

/**
 *  初始化评价星星
 */
- (void)setUpRatingStar {
    CGFloat width = ScreenW * 0.7;
    CGFloat x = (ScreenW - width) * 0.5;
    
    self.ratingBar = [[RatingBar alloc] initWithFrame:CGRectMake(x, 30, width, 30)];
    // 添加到view中
    [self.view addSubview:self.ratingBar];
    // 是否是指示器,是指示器就只能显示结果,不能点击
    self.ratingBar.isIndicator = NO;
    [self.ratingBar setImageDeselected:@"Star_deselected" halfSelected:nil fullSelected:@"Star_selected" andDelegate:self];
}


/**
 *  确认评价
 */
- (void)confirmAssess {
    NSString *startCount = [NSString stringWithFormat:@"%.0f",self.starCount];
    
    if ([startCount isEqual:@"0"]) {
        [SVProgressHUD showImage:nil status:@"请选择一个星级再确认评级吧!"];
        return;
        
    } else {
        BSLog(@"self.HistoryOrder.COId = %@ startCount = %@, \nself.textView.text = %@ ", self.HistoryOrder.COID, startCount, self.textView.text);
        NSArray *tempArray = @[];
        NSDictionary *dict = @{
                               @"COId" : self.COId,
                               @"ROId" : self.ROId,
                               @"COPJStar" : startCount, // 评价星级
                               @"COPJInfo" : self.textView.text, // 评价文本
                               @"COPJLableId" : tempArray,
                               };
        
        NSDictionary *params = [ELHOCToJson ocToJson:dict];
        
        NSString *URL = [NSString stringWithFormat:@"%@COPJInfo_addCOPJInfo.action", ELHBaseURL];
        
        [self.manager POST:URL parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            BSLog(@"%@", responseObject);
            if ([responseObject[@"resultSign"] isEqual:@"1"]) {
                // 发送评价成功的通知
                [[NSNotificationCenter defaultCenter] postNotificationName:ELHAssessSuccessNotification object:nil];
                [SVProgressHUD showImage:nil status:@"评价成功"];
                self.ratingBar.userInteractionEnabled = NO;
                self.textView.userInteractionEnabled = NO;
                [self.navigationController popViewControllerAnimated:YES];
            }
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            
            BSLog(@"%@", error);
        }];
        
    }
}



#pragma mark - RatingBar delegate
- (void)ratingBar:(RatingBar *)ratingBar ratingChanged:(float)newRating {
    self.starCount = newRating;
    
    if (newRating == 0) {
        self.assessLevelLabel.text = nil;
    } else if (newRating == 1) {
        self.assessLevelLabel.text = @"差评";
    } else if (newRating == 2) {
        self.assessLevelLabel.text = @"很一般";
    } else if (newRating == 3) {
        self.assessLevelLabel.text = @"中评";
    } else if (newRating == 4) {
        self.assessLevelLabel.text = @"满意";
    } else if (newRating == 5) {
        self.assessLevelLabel.text = @"非常满意";
    }
}

#pragma mark - UITextViewDelegate
- (void)textViewDidBeginEditing:(UITextView *)textView {
    if (self.textView.text.length != 0) {
        self.placeholderLable.hidden = YES;
    } else {
        self.placeholderLable.hidden = NO;
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    if (self.textView.text.length != 0) {
        self.placeholderLable.hidden = YES;
    } else {
        self.placeholderLable.hidden = NO;
    }
}

- (void)textViewDidChange:(UITextView *)textView {
    if (self.textView.text.length != 0) {
        self.placeholderLable.hidden = YES;
    } else {
        self.placeholderLable.hidden = NO;
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

@end
