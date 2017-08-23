//
//  TYTabbarController.m
//  TabbarAnimationDemo
//
//  Created by Tiny on 2017/8/22.
//  Copyright © 2017年 LOVEGO. All rights reserved.
//

#import "TYTabbarController.h"
#import "TYTabBar.h"
#import "ViewController.h"
#import "TYBarItemModel.h"

@interface TYTabbarController ()<TYTabBarDelegate>

@property (nonatomic,strong) TYTabBar *tyTabbar;

@end

@implementation TYTabbarController

-(void)viewDidLoad{
    [super viewDidLoad];
    
    [self setupTabbar];
    
    //设置controllers
    [self loadViewControllers];
}


-(void)setupTabbar{
    TYTabBar *tabbar = [[TYTabBar alloc] init];
    self.tyTabbar = tabbar;
    self.tyTabbar.realDelegate = self;
    //给tabbar设置内容
   //准备数据
    NSArray *arr = @[@"首页",@"分类",@"购物车",@"搜索",@"我的"];//title
    NSArray *arr1 = @[@"search_1",@"search_2",@"search_3"]; //如果需要帧动画 这里需要传入每个按钮点击后的动画帧
    NSArray *barImages = @[@[@"home_sel",@"home_sel"],      //按钮默认图片和选中后图片
                           @[@"classify_sel",@"classify_sel"],
                           @[@"cart",@"cart"],
                           @[@"search_sel",@"search_sel"],
                           @[@"mine_sel",@"mine_sel"],
                        ];
    NSArray *anmations = @[@(TYBarItemAnimationTypeScale),@(TYBarItemAnimationTypeRotate),@(TYBarItemAnimationTypeRotate),@(TYBarItemAnimationTypeFrames),@(TYBarItemAnimationTypeScale)];
    NSMutableArray *datas = [NSMutableArray array];
    for (int i =0;  i < 5; i++) {
        //每个按钮都可以单独设置图片 文字 动画效果(暂时只有4种效果)等
        TYBarItemModel *model = [[TYBarItemModel alloc] initWithTitle:arr[i] images:arr1 normalImage:barImages[i][0] selectedImage:barImages[i][1] AnimationType:[anmations[i] integerValue]];
        [datas addObject:model];
    }
    //初始化tabbar数据
    [self.tyTabbar loadItemsWithData:datas];
    //替换系统的tabbar
    [self setValue:tabbar forKeyPath:@"tabBar"];
    
    //设置角标
    [self.tyTabbar badgeText:@"9" forIndex:0];
    [self.tyTabbar badgeText:@"." forIndex:3];
    
}

- (void) loadViewControllers {
    
    ViewController* homepageVC = [[ViewController alloc] init];
    [self setUpOneChildVcWithVc:homepageVC  title:@"首页"];
    
    ViewController * classifyVC = [[ViewController alloc] init];
    [self setUpOneChildVcWithVc:classifyVC  title:@"分类"];
    
    ViewController* shoppingCartVC = [[ViewController alloc] init];
    [self setUpOneChildVcWithVc:shoppingCartVC  title:@"购物车"];
    
    ViewController * searchVC = [[ViewController alloc] init];
    [self setUpOneChildVcWithVc:searchVC  title:@"搜索"];
    
    ViewController* personalCenterVC = [[ViewController alloc] init];
    [self setUpOneChildVcWithVc:personalCenterVC  title:@"我的"];
}


- (void)setUpOneChildVcWithVc:(UIViewController *)Vc title:(NSString *)title
{
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:Vc];
    
    Vc.navigationItem.title = title;
    
    [self addChildViewController:nav];
    
}


#pragma mark - tabBarDelegate
-(void)tabBar:(TYTabBar *)tabbar clickIndex:(NSInteger)index{
    [self setSelectedIndex:index];
}

-(void)tabBar:(TYTabBar *)tabBar doubleClick:(NSInteger)index{
    NSLog(@"第%zi个Item被双击",index);
    //根据选中的Inex，拿到对应的控制器然后让控制器刷新数据
    
    UINavigationController *naviVC = (UINavigationController *)self.selectedViewController;
    ViewController *dpVc = (ViewController *)naviVC.viewControllers.firstObject;
    [dpVc reloadColor];
}
@end
