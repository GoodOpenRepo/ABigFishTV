//
//  ABFMineViewController.m
//  ABigFishTV
//
//  Created by 陈立宇 on 17/9/23.
//  Copyright © 2017年 陈立宇. All rights reserved.
//

#import "ABFMineViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "ABFMineHeaderView.h"
#import "ABFMineMenuCell.h"
#import "ABFMineSimpleCell.h"
#import "MXParallaxHeader.h"
#import "ABFLoginViewController.h"
#import "ABFUserInfo.h"
#import "AppDelegate.h"
#import "ABFListViewController.h"
#import "ABFNoticeController.h"
#import "AppDelegate.h"
#import "ABFCacheManager.h"
#import "QRCodeGenerateVC.h"
#import "SGQRCodeScanningVC.h"
#import "ABFSettingViewController.h"
#import "ABFFriendsViewController.h"
#import "ABFMyChatViewController.h"
#import "ABFCalendarController.h"
#import "UITableView+ABFHighLight.h"


@interface ABFMineViewController ()<UITableViewDelegate,UITableViewDataSource,MenuBindingDelegate,ABFSettingViewControllerDelegate>

@property(nonatomic,weak)   UIImageView     *profile;

@property(nonatomic,strong) NSMutableArray  *menuArray;

@property(nonatomic,assign) CGFloat         cacheSize;

@property(nonatomic,strong) ABFUserInfo     *user;

@property(nonatomic,strong) ABFMineHeaderView *headerView;

@property(nonatomic,strong)  UIView         *footerView;

@property(nonatomic,weak)   UIButton        *loginout;

@property(nonatomic,weak)   UIButton        *settingBtn;
@end

@implementation ABFMineViewController

- (NSMutableArray*)menuArray{
    
    if(_menuArray == nil){
        _menuArray = [NSMutableArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"profile.plist" ofType:nil]];
    }
    return _menuArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = LINE_BG;
    self.automaticallyAdjustsScrollViewInsets = NO;
   
    [self addTableView];
    [self addTableHeaderView];
    //[self addTableFooterView];
    NSLog(@"login controller");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    [self setStatusBarBackgroundColor:COMMON_COLOR];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [self.navigationController.navigationBar setBarTintColor:COMMON_COLOR];
    self.navigationController.navigationBar.translucent = NO;
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSFontAttributeName:[UIFont systemFontOfSize:20],NSForegroundColorAttributeName:COMMON_COLOR}];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
    //self.title = @"";
    
    UIButton *settingBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    //settingBtn.hidden = YES;
    settingBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [settingBtn setImage:[UIImage imageNamed:@"btn_setting"] forState:UIControlStateNormal];
    //settingBtn.contentEdgeInsets = UIEdgeInsetsMake(20, 20, -10, -5);
    //settingBtn.imageEdgeInsets = UIEdgeInsetsMake(10, 10, 0, 0);
    [settingBtn addTarget:self action:@selector(settingClick:)
         forControlEvents:UIControlEventTouchUpInside];
    _settingBtn = settingBtn;
    UIBarButtonItem *rightBtnItem = [[UIBarButtonItem alloc] initWithCustomView:settingBtn];
    self.navigationItem.rightBarButtonItem = rightBtnItem;
    
    [self.tabBarController.tabBar setHidden:NO];
    [AppDelegate APP].allowRotation = false;
    if ([AppDelegate APP].user) {
        NSLog(@"login.... username=%@",[AppDelegate APP].user.username);
        NSString *url = [AppDelegate APP].user.profile;
        
        NSURL *httpurl = [NSURL URLWithString:url];
        [self.profile sd_setImageWithURL:httpurl placeholderImage:[UIImage imageNamed:@"profile"]];
        _headerView.username.text = [AppDelegate APP].user.username;
        _headerView.historyTLab.text =[NSString stringWithFormat:@"%ld",[AppDelegate APP].user.history] ;
        _headerView.likeTLab.text =[NSString stringWithFormat:@"%ld",[AppDelegate APP].user.likenum] ;
        _headerView.messageTLab.text =[NSString stringWithFormat:@"%ld",[AppDelegate APP].user.notices] ;
        //_headerView.settingBtn.hidden = NO;
        _settingBtn.hidden = NO;
        _settingBtn.alpha = 1;
    }else{
        //_loginout.hidden = YES;
        _settingBtn.hidden = YES;
        _settingBtn.alpha = 0;
    }
    
    [_tableView reloadData];
    
}

- (void)setStatusBarBackgroundColor:(UIColor *)color {
    
    UIView *statusBar = nil;
    if (@available(iOS 13.0, *)) {
        UIView *_localStatusBar = [[UIApplication sharedApplication].keyWindow.windowScene.statusBarManager performSelector:@selector(createLocalStatusBar)];
        statusBar = [_localStatusBar performSelector:@selector(statusBar)];
    } else {
        // Fallback on earlier versions
        statusBar = [[[UIApplication sharedApplication] valueForKey:@"statusBarWindow"] valueForKey:@"statusBar"];
    }
    if ([statusBar respondsToSelector:@selector(setBackgroundColor:)]) {
        statusBar.backgroundColor = color;
    }
}


- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    //[self.tabBarController.tabBar setHidden:NO];
    _settingBtn.hidden = YES;
    _settingBtn.alpha = 0;
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    UIView *statusBar = nil;
    if (@available(iOS 13.0, *)) {
        UIView *_localStatusBar = [[UIApplication sharedApplication].keyWindow.windowScene.statusBarManager performSelector:@selector(createLocalStatusBar)];
        statusBar = [_localStatusBar performSelector:@selector(statusBar)];
    } else {
        // Fallback on earlier versions
        statusBar = [[[UIApplication sharedApplication] valueForKey:@"statusBarWindow"] valueForKey:@"statusBar"];
    }
    self.view.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
    _tableView.frame = CGRectMake( 0, statusBar.frame.size.height, kScreenWidth, kScreenHeight-self.tabBarController.tabBar.frame.size.height-statusBar.frame.size.height);
}

- (void) addTableView{

    self.automaticallyAdjustsScrollViewInsets = NO;
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    tableView.backgroundColor = LINE_BG;
    tableView.showsVerticalScrollIndicator = NO;
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.bounces = NO;
    tableView.abf_highLightColor = LINE_BG;
    
    [self.view addSubview:tableView];
    [tableView registerClass:[ABFMineSimpleCell class] forCellReuseIdentifier:@"mycell"];
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView = tableView;

}

- (void) addTableHeaderView{
    
    ABFMineHeaderView *headerView = [[ABFMineHeaderView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenWidth*2/3)];
    headerView.delegate = self;
    //headerView.delegate = self;
    //_tableView.parallaxHeader.view = headerView;
    //_tableView.parallaxHeader.height = 170;
    //_tableView.parallaxHeader.mode = MXParallaxHeaderModeFill;
    _tableView.tableHeaderView = headerView;
    headerView.profile.userInteractionEnabled = YES;
    _profile = headerView.profile;
    _headerView = headerView;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickLogin:)];
    [_profile addGestureRecognizer:tap];

}

-(void) addTableFooterView{

    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, kScreenHeight-self.tabBarController.tabBar.frame.size.height-60, kScreenWidth, 60)];
    footerView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:footerView];
    //_tableView.tableFooterView = footerView;
    _footerView = footerView;
    UIButton *loginout = [UIButton buttonWithType:UIButtonTypeCustom];
    [loginout setTitle:@"退出" forState:UIControlStateNormal];
    loginout.backgroundColor = [UIColor redColor];
    [loginout setTintColor:COMMON_COLOR];
    [loginout setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    loginout.layer.masksToBounds = YES;
    loginout.layer.cornerRadius = 5.0;
    [loginout addTarget:self action:@selector(loginoutAction:) forControlEvents:UIControlEventTouchUpInside];
    
    [footerView addSubview:loginout];
    //_loginBtn = loginBtn;
    _loginout = loginout;
    [loginout mas_makeConstraints:^(MASConstraintMaker *make){
        make.top.equalTo(self.footerView.mas_top).offset(10);
        make.centerX.equalTo(self.footerView.mas_centerX);
        make.left.equalTo(self.footerView.mas_left).offset(5);
        make.right.equalTo(self.footerView.mas_right).offset(-5);
    }];

    
}

-(void)loginoutAction:(id)sender{
    NSLog(@"out...");
    [AppDelegate APP].user = nil;
    ABFMineViewController *vc = [[ABFMineViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
    //[self.navigationController popToViewController:vc animated:YES];
    
}

-(void)pushVC:(NSInteger)tag{
    NSLog(@"index=%ld",tag);
    if(tag == 102 || tag == 103){
        ABFListViewController *vc = [[ABFListViewController alloc] init];
        vc.navigationController.navigationBar.hidden = YES;
        vc.index = tag;
        [self.navigationController pushViewController:vc animated:YES];
        //vc.modalPresentationStyle = UIModalPresentationFullScreen;
        //[self presentViewController:vc animated:YES completion:nil];
    }else if(tag == 101){
        ABFNoticeController *vc = [[ABFNoticeController alloc] init];
        vc.navigationController.navigationBar.hidden = YES;
        vc.index = tag;
        [self.navigationController pushViewController:vc animated:YES];
        //vc.modalPresentationStyle = UIModalPresentationFullScreen;
        //[self presentViewController:vc animated:YES completion:nil];
        
    }
}

-(void)loaddata{

    [self.tableView reloadData];
}


/*********table********/

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    
    return self.menuArray.count;
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *title = [self.menuArray[indexPath.row] objectForKey:@"name"];
    NSString *icon  = [self.menuArray[indexPath.row] objectForKey:@"icon"];
    ABFMineSimpleCell *cell = [tableView dequeueReusableCellWithIdentifier:@"mycell" forIndexPath:indexPath];
    /*
    ABFMineSimpleCell *cell = [[ABFMineSimpleCell alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 40) title:title];*/
    [cell setTitle:title];
    if([title isEqualToString:@"清理缓存"]){
        [cell setDesc:[self getCacheSize]];
    }
    [cell setIconName:icon];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.001f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.0f;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    NSString *title = [self.menuArray[indexPath.row] objectForKey:@"name"];
    if([title isEqualToString:@"扫一扫"]){
        //ABFQRViewController *vc = [[ABFQRViewController alloc] init];
        //[self.navigationController pushViewController:vc animated:YES];
        [self qrscan];
    }
    if([title isEqualToString:@"粉丝"]){
        //ABFQRViewController *vc = [[ABFQRViewController alloc] init];
        //[self.navigationController pushViewController:vc animated:YES];
        //[self qrscan];
        ABFFriendsViewController *vc = [[ABFFriendsViewController alloc] init];
         vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
    }
    if([title isEqualToString:@"微话题"]){
        ABFMyChatViewController *vc = [[ABFMyChatViewController alloc] init];
         vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
    }
    if([title isEqualToString:@"日历"]){
        ABFCalendarController *vc = [[ABFCalendarController alloc] init];
         vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
    }
    
    
}


-(NSString *) getCacheSize{
    
    CGFloat cacheSize = [ABFCacheManager manager].filePath;
    NSLog(@"cache size %f",_cacheSize);
    NSString *strCacheSize = [NSString stringWithFormat:@"%f",cacheSize];
    strCacheSize = [strCacheSize substringWithRange:NSMakeRange(0, 3)];
    strCacheSize = [strCacheSize stringByAppendingString:@"M"];
    
    return strCacheSize;
}

-(void)clickLogin:(id)sender{

    NSLog(@"login...");
    if([AppDelegate APP].user){
    }else{
        
        ABFLoginViewController *vc = [[ABFLoginViewController alloc] init];
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:vc];
        //vc.view.frame = self.view.bounds;
        //[self.navigationController pushViewController:vc animated:YES];
        navController.modalPresentationStyle = UIModalPresentationFullScreen;
        
        [self presentViewController:navController animated:YES completion:nil];
    }
    
}

-(void)qrscan{

    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if (device) {
        AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        if (status == AVAuthorizationStatusNotDetermined) {
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                if (granted) {
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        SGQRCodeScanningVC *vc = [[SGQRCodeScanningVC alloc] init];
                        [self.navigationController pushViewController:vc animated:YES];
                    });
                    // 用户第一次同意了访问相机权限
                    NSLog(@"用户第一次同意了访问相机权限 - - %@", [NSThread currentThread]);
                    
                } else {
                    // 用户第一次拒绝了访问相机权限
                    NSLog(@"用户第一次拒绝了访问相机权限 - - %@", [NSThread currentThread]);
                }
            }];
        } else if (status == AVAuthorizationStatusAuthorized) { // 用户允许当前应用访问相机
            SGQRCodeScanningVC *vc = [[SGQRCodeScanningVC alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
        } else if (status == AVAuthorizationStatusDenied) { // 用户拒绝当前应用访问相机
            UIAlertController *alertC = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"请去-> [设置 - 隐私 - 相机 - SGQRCodeExample] 打开访问开关" preferredStyle:(UIAlertControllerStyleAlert)];
            UIAlertAction *alertA = [UIAlertAction actionWithTitle:@"确定" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
                
            }];
            
            [alertC addAction:alertA];
            [self presentViewController:alertC animated:YES completion:nil];
            
        } else if (status == AVAuthorizationStatusRestricted) {
            NSLog(@"因为系统原因, 无法访问相册");
        }
    } else {
        UIAlertController *alertC = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"未检测到您的摄像头" preferredStyle:(UIAlertControllerStyleAlert)];
        UIAlertAction *alertA = [UIAlertAction actionWithTitle:@"确定" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        
        [alertC addAction:alertA];
        [self presentViewController:alertC animated:YES completion:nil];
    }

}


-(void)settingVC:(id)sender{
    //NSLog(@"setting");
    ABFSettingViewController *vc = [[ABFSettingViewController alloc] init];
    //[self.navigationController pushViewController:vc animated:YES];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:vc];
    navController.modalPresentationStyle = UIModalPresentationFullScreen;
    
    vc.delegate = self;
    [self presentViewController:navController animated:YES completion:nil];
}
-(void)settingClick:(id)sender{
    ABFSettingViewController *vc = [[ABFSettingViewController alloc] init];
    //[self.navigationController pushViewController:vc animated:YES];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:vc];
    navController.modalPresentationStyle = UIModalPresentationFullScreen;
    vc.delegate = self;
    [self presentViewController:navController animated:YES completion:nil];
}

-(void)logoutAction{
    NSLog(@"logout");
    NSURL *httpurl = [NSURL URLWithString:@""];
    [self.profile sd_setImageWithURL:httpurl placeholderImage:[UIImage imageNamed:@"profile"]];
    _headerView.settingBtn.hidden = YES;
    _headerView.username.text = @"登录";
    _headerView.historyTLab.text =[NSString stringWithFormat:@"%d",0] ;
    _headerView.likeTLab.text =[NSString stringWithFormat:@"%d",0] ;
    _headerView.messageTLab.text =[NSString stringWithFormat:@"%d",0] ;
}


- (BOOL)shouldAutorotate{
    return YES;
}
- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
