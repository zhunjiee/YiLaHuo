//
//  FAQViewController.m
//  ELaHuo
//
//  Created by elahuo on 16/7/28.
//  Copyright © 2016年 elahuo. All rights reserved.
//

#import "FAQViewController.h"

@interface FAQViewController ()
@property (weak, nonatomic) IBOutlet UIWebView *FAQWebView;

@end

@implementation FAQViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"常见问题";
    
    NSString* path = [[NSBundle mainBundle] pathForResource:@"常见问题" ofType:@"html"];
    NSURL* url = [NSURL fileURLWithPath:path];
    NSURLRequest* request = [NSURLRequest requestWithURL:url] ;
    [self.FAQWebView loadRequest:request];
}


@end
