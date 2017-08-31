//
//  TYTabbarController.h
//  TabbarAnimationDemo
//
//  Created by Tiny on 2017/8/22.
//  Copyright © 2017年 LOVEGO. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TYTabbarController : UITabBarController


/**
 手动隐藏tabbar 如果手动隐藏了tabbar，tabbar需要手动设置tabbar显示

 @param hidden 是否隐藏
 @param animated 是否执行动画
 */
-(void)setTabbarHidden:(BOOL)hidden animated:(BOOL)animated;

@end
