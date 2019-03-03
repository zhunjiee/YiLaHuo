//
//  ELHServiceViewController.m
//  ELaHuo
//
//  Created by elahuo on 16/3/29.
//  Copyright © 2016年 elahuo. All rights reserved.
//

#import "ELHServiceViewController.h"

@interface ELHServiceViewController ()
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation ELHServiceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"服务条款";
    
    NSString* path = [[NSBundle mainBundle] pathForResource:@"e拉货货主服务条款" ofType:@"html"];
    NSURL* url = [NSURL fileURLWithPath:path];
    NSURLRequest* request = [NSURLRequest requestWithURL:url] ;
    [self.webView loadRequest:request];
}

@end
