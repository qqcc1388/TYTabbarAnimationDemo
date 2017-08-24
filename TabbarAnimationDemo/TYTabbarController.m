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

@property (nonatomic,strong) NSMutableArray *quizAnimationImages;
@property (nonatomic,strong) NSMutableArray *matchAnimationImages;
@property (nonatomic,strong) NSMutableArray *discountAnimationImages;
@property (nonatomic,strong) NSMutableArray *mineAnimationImages;

@end

@implementation TYTabbarController

-(void)viewDidLoad{
    [super viewDidLoad];
    
    //注意控制器初始化在前，初始化tabbar在后（要不然控制器未初始化，按钮选中无法跳转到正确的控制器）
    //设置controllers
    [self loadViewControllers];
    //初始化tabbar
    [self setupTabbar];
    
}

- (NSMutableArray *)quizAnimationImages {
    if (!_quizAnimationImages) {
        _quizAnimationImages = [NSMutableArray array];
    }
    return _quizAnimationImages;
}

- (NSMutableArray *)matchAnimationImages {
    if (!_matchAnimationImages) {
        _matchAnimationImages = [NSMutableArray array];
    }
    return _matchAnimationImages;
}

- (NSMutableArray *)discountAnimationImages {
    if (!_discountAnimationImages) {
        _discountAnimationImages = [NSMutableArray array];
    }
    return _discountAnimationImages;
}

- (NSMutableArray *)mineAnimationImages {
    if (!_mineAnimationImages) {
        _mineAnimationImages = [NSMutableArray array];
    }
    return _mineAnimationImages;
}

- (void)addImages {
    NSString *quizImageName, *matchImageName, *discountImageName, *mineImageName;
    for (int i = 1; i < 24; i++) {
        quizImageName = [NSString stringWithFormat:@"竞猜_%d", i];
        matchImageName = [NSString stringWithFormat:@"赛事_%d", i];
        discountImageName = [NSString stringWithFormat:@"优惠_%d", i];
        mineImageName = [NSString stringWithFormat:@"我的_%d", i];
        [self.quizAnimationImages addObject:quizImageName];
        [self.matchAnimationImages addObject:matchImageName];
        [self.discountAnimationImages addObject:discountImageName];
        [self.mineAnimationImages addObject:mineImageName];
    }
}

-(void)setupTabbar{
    TYTabBar *tabbar = [[TYTabBar alloc] init];
    self.tyTabbar = tabbar;
    self.tyTabbar.realDelegate = self;
    //给tabbar设置内容
    [self addImages];

   //准备数据
    NSArray *arr = @[@"竞猜", @"赛事", @"发现", @"优惠", @"我的"];                //title
    NSArray *animationImageArr = @[self.quizAnimationImages, self.matchAnimationImages, @[], self.discountAnimationImages, self.mineAnimationImages];
    NSArray *barImages = @[@[@"quiz_normal", @"quiz_selected"],                //按钮默认图片和选中后图片
                           @[@"match_normal", @"match_selected"],
                           @[@"discovery_normal", @"discovery_selected"],
                           @[@"discount_normal", @"discount_selected"],
                           @[@"mine_normal", @"mine_selected"],
                        ];
    NSArray *anmations = @[@(TYBarItemAnimationTypeFrames),@(TYBarItemAnimationTypeFrames),@(TYBarItemAnimationTypeRotate),@(TYBarItemAnimationTypeFrames),@(TYBarItemAnimationTypeFrames)];

    NSMutableArray *datas = [NSMutableArray array];
    for (int i = 0;  i < 5; i++) {
        //0. 根据需求选择填写对应的内容
        //1. 每个按钮都可以单独设置图片 文字 动画效果(暂时只有4种效果)等
        //2. 如果点击后不需要帧动画 images可以传nil
        //3. 如果所有按钮都是统一动画，AnimationType 默认传一个值就可以了
        //4. title为BarItem显示的文字
        //5. nomalImage selectdImage 为BarItem选中和非选中的图片 选中和非选中按钮颜色在TYTabBar中配置
        TYBarItemModel *model = [[TYBarItemModel alloc] initWithTitle:arr[i] images:nil normalImage:barImages[i][0] selectedImage:barImages[i][1] AnimationType:[anmations[i] integerValue]];
        [datas addObject:model];
    }
    //初始化tabbar数据
    [self.tyTabbar loadItemsWithData:datas defaultSelect:2];

    //替换系统的tabbar
    [self setValue:tabbar forKeyPath:@"tabBar"];

    //设置角标
    [self.tyTabbar badgeText:@"9" forIndex:0];
    [self.tyTabbar badgeText:@"." forIndex:3];

}

- (void) loadViewControllers {
    
    ViewController* homepageVC = [[ViewController alloc] init];
    [self setUpOneChildVcWithVc:homepageVC  title:@"竞猜"];
    
    ViewController * classifyVC = [[ViewController alloc] init];
    [self setUpOneChildVcWithVc:classifyVC  title:@"赛事"];
    
    ViewController* shoppingCartVC = [[ViewController alloc] init];
    [self setUpOneChildVcWithVc:shoppingCartVC  title:@"发现"];
    
    ViewController * searchVC = [[ViewController alloc] init];
    [self setUpOneChildVcWithVc:searchVC  title:@"优惠"];
    
    ViewController* personalCenterVC = [[ViewController alloc] init];
    [self setUpOneChildVcWithVc:personalCenterVC  title:@"我的"];
}


- (void)setUpOneChildVcWithVc:(UIViewController *)Vc title:(NSString *)title {
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
