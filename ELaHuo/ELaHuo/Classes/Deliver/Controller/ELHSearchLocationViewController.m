//
//  ELHSearchLocationViewController.m
//  ELaHuo
//
//  Created by elahuo on 16/3/18.
//  Copyright © 2016年 elahuo. All rights reserved.
//

#import "ELHSearchLocationViewController.h"
#import <BaiduMapAPI_Search/BMKSearchComponent.h>

@interface ELHSearchLocationViewController () <BMKSuggestionSearchDelegate, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *NoResultLabel;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

/** 检索对象 */
@property (nonatomic, strong) BMKSuggestionSearch *searcher;

/** 搜索栏 */
@property (nonatomic, strong) UISearchBar *searchBar;

/** 搜索到的关键词结果 */
@property (nonatomic, strong) NSArray *keyListArray;
/** 搜索到的城市列表 */
@property (nonatomic, strong) NSArray *cityListArray;
/** 搜索到的行政区列表 */
@property (nonatomic, strong) NSArray *districtListArray;
/** 搜索到的CLLocationCoordinate2D数组 */
@property (nonatomic, strong) NSArray *ptListArray;
@end

@implementation ELHSearchLocationViewController

#pragma mark - 懒加载
/** searcher的懒加载 */
- (BMKSuggestionSearch *)searcher {
    if (_searcher == nil) {
        _searcher = [[BMKSuggestionSearch alloc] init];
    }
    return _searcher;
}


#pragma mark - 初始化
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    self.view.backgroundColor = ELHColor(236, 236, 236, 1);
    self.tableView.backgroundColor = [UIColor whiteColor];
    
    [self setUpNav];
    
    [self setUpSearchBar];
}



/**
 *  创建searchBar
 */
- (void)setUpSearchBar {
    UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, ScreenW - 100, 44)];

    searchBar.delegate = self;
    searchBar.tintColor = ELHGlobalColor;
    searchBar.placeholder = @"搜索";
    [searchBar becomeFirstResponder];
    self.navigationItem.titleView = searchBar;
    
    // 设置searchBar的颜色
    UIView *searchTextField = nil;
    if ([[[UIDevice currentDevice] systemVersion] doubleValue] >= 7.0) {
        searchBar.barTintColor = [UIColor whiteColor];
        searchTextField = [[[searchBar.subviews firstObject] subviews] lastObject];
    } else {
        for (UIView *subView in searchBar.subviews) {
            if ([subView isKindOfClass:NSClassFromString(@"UISearchBarTextField")]) {
                searchTextField = subView;
            }
        }
    }
    searchTextField.backgroundColor = ELHColor(236, 236, 236, 1);
    
    
    self.searchBar = searchBar;
}

/**
 *  初始化导航栏
 */
- (void)setUpNav {

    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStyleDone target:self action:@selector(cancelButtonClick)];
    self.navigationItem.rightBarButtonItem = item;

}

- (void)cancelButtonClick {
    [self.searchBar resignFirstResponder];
    
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)viewWillAppear:(BOOL)animated{
    // 隐藏返回按钮
    [self.navigationItem setHidesBackButton:YES];
    
    self.searcher.delegate = self;
}

-(void)viewWillDisappear:(BOOL)animated {
    self.searcher.delegate = nil;
}


#pragma mark - UISearchBarDelegate
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (![searchText isEqualToString:@""]) {
        // 发送内容进行搜索
        BMKSuggestionSearchOption* option = [[BMKSuggestionSearchOption alloc] init];
        option.keyword  = searchText;
        [self.searcher suggestionSearch:option];
        
    } else {
        self.keyListArray = nil;
        self.cityListArray = nil;
        self.districtListArray = nil;
        self.ptListArray = nil;
        
        [self.tableView reloadData];
        self.NoResultLabel.hidden = YES;
    }
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    if (![searchBar.text isEqualToString:@""]) {
        // 发送内容进行搜索
        BMKSuggestionSearchOption* option = [[BMKSuggestionSearchOption alloc] init];
        option.keyword  = searchBar.text;
        [self.searcher suggestionSearch:option];
        
        self.tableView.hidden = NO;
        [self.tableView reloadData];
    } else {
        self.keyListArray = nil;
        self.cityListArray = nil;
        self.districtListArray = nil;
        self.ptListArray = nil;
        
        [self.tableView reloadData];
        self.NoResultLabel.hidden = YES;
    }
}




//实现Delegate处理回调结果
- (void)onGetSuggestionResult:(BMKSuggestionSearch*)searcher result:(BMKSuggestionResult*)result errorCode:(BMKSearchErrorCode)error{
    if (error == BMK_SEARCH_NO_ERROR) {
        
        self.keyListArray = result.keyList;
        self.cityListArray = result.cityList;
        self.districtListArray = result.districtList;
        self.ptListArray = result.ptList;
        
        [self.tableView reloadData];
        self.NoResultLabel.hidden = YES;
    } else {
        BSLog(@"抱歉，未找到结果");
        self.tableView.hidden = YES;
        self.NoResultLabel.hidden = NO;
        
    }
}




#pragma mark - UITableview相关
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (self.keyListArray.count != 0) {
        
        return [self.keyListArray count];
    } else {
        tableView.hidden = YES;
        return 0;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *flag=@"cellFlag";
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:flag];
    if (cell==nil) {
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:flag];
    }

    cell.detailTextLabel.textColor = [UIColor lightGrayColor];
    
    // 设置数据
    [cell.textLabel setText:self.keyListArray[indexPath.row]];
    [cell.detailTextLabel setText:[NSString stringWithFormat:@"%@-%@", self.cityListArray[indexPath.row], self.districtListArray[indexPath.row]]];

    return cell;
}


/**
 *  选中某行后将数据传回上一个控制器
 */
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.searchBar resignFirstResponder];
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    NSString *location;
    
    
    if ([cell.detailTextLabel.text isEqualToString:@"-"]) {
        location = cell.textLabel.text;
        
    } else if ([cell.detailTextLabel.text hasSuffix:@"-"]) {
        location = [NSString stringWithFormat:@"%@(%@)", cell.textLabel.text, self.cityListArray[indexPath.row]];
        
    } else {
        location = [NSString stringWithFormat:@"%@(%@)", cell.textLabel.text, cell.detailTextLabel.text];
    }
    
    
    if ([self.delegate respondsToSelector:@selector(searchLocationViewController:didAddLoaction:andCLLocationPoint:)]) {
        [self.delegate searchLocationViewController:self didAddLoaction:location andCLLocationPoint:self.ptListArray[indexPath.row]];
        
        
        
        // 回到上一个控制器
        [self.navigationController popViewControllerAnimated:YES];
    }
}

/**
 *  滚动退出键盘
 */
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.searchBar endEditing:YES];
}
@end
