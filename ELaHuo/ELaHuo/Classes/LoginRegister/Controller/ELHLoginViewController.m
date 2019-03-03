//
//  ELHLoginViewController.m
//  ELaHuo
//
//  Created by elahuo on 16/3/8.
//  Copyright © 2016年 elahuo. All rights reserved.
//

#import "ELHLoginViewController.h"
#import "ELHRegisterViewController.h"

@interface ELHLoginViewController ()
// 底部视图
@property (weak, nonatomic) IBOutlet UIView *bottomView;
// 底部视图约束
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomViewConstraint;
@end


@implementation ELHLoginViewController


#pragma mark - 初始化
- (void)viewDidLoad {
    [super viewDidLoad];
    
     self.navigationItem.title = @"登录";
    
    // 添加通知监听键盘的弹出与隐藏
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}


- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}





#pragma mark - 监听方法
/**
 *  键盘弹出, bottomView上移
 */
- (void)keyboardWillShow:(NSNotification *)note {
    // 获取键盘的frame
    CGRect keyboardBounds = [note.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    // 拿到键盘的弹出时间
    double duration = [note.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    // 计算transform
    CGFloat transformY = keyboardBounds.size.height;
    
    void (^animations)(void) = ^{
        self.bottomView.transform = CGAffineTransformMakeTranslation(0, -transformY);
    };

    if (duration > 0) {
        int options = [note.userInfo[UIKeyboardAnimationCurveUserInfoKey] intValue];
        
        [UIView animateWithDuration:duration delay:0 options:options animations:animations completion:nil];
        
    } else {
        
        animations();
    }
}

/**
 *  键盘消失, bottomView下移复原
 */
- (void)keyboardWillHide:(NSNotification *)note {
    double duration = [note.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    void (^animations)(void) = ^{
        self.bottomView.transform = CGAffineTransformIdentity;
    };
    
    if (duration > 0) {
        int options = [note.userInfo[UIKeyboardAnimationCurveUserInfoKey] intValue];
        
        [UIView animateWithDuration:duration delay:0 options:options animations:animations completion:nil];
        
    } else {
        animations();
    }
}



/**
 *  用户注册
 */
- (IBAction)registerButtonClick {
    ELHRegisterViewController *registerVC = [UIStoryboard storyboardWithName:NSStringFromClass([ELHRegisterViewController class]) bundle:nil].instantiateInitialViewController;
    [self.navigationController pushViewController:registerVC animated:YES];
}


@end
