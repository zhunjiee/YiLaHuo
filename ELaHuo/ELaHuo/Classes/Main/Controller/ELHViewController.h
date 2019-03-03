//
//  ELHViewController.h
//  ElaHuo
//
//  Created by elahuo on 16/3/7.
//  Copyright © 2016年 elahuo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ELHMenuView.h"
#import <BaiduMapAPI_Map/BMKMapComponent.h>
#import <BaiduMapAPI_Utils/BMKUtilsComponent.h>
#import <BaiduMapAPI_Map/BMKPolyline.h>
#import <BaiduMapAPI_Location/BMKLocationComponent.h>
#import <BaiduMapAPI_Search/BMKGeocodeSearch.h>
#import <BaiduMapAPI_Search/BMKGeocodeSearchOption.h>
#import <Masonry.h>
#import <MJExtension.h>
#import <SVProgressHUD.h>
#import <GCDAsyncSocket.h>

@interface ELHViewController : UIViewController

@property (nonatomic, weak) ELHMenuView *menuView;

@end
