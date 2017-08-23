//
//  TYTabBar.h
//  TabbarAnimationDemo
//
//  Created by Tiny on 2017/8/22.
//  Copyright © 2017年 LOVEGO. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TYTabBar,TYBarItemModel;
@protocol TYTabBarDelegate <NSObject>

@required

/**
 tabbar中按钮被点击返回点击index

 @param tabbar self
 @param index 选中的按钮index
 */
-(void)tabBar:(TYTabBar *)tabbar clickIndex:(NSInteger)index;

@optional

/**
 tabbarItem双击事件回调

 @param tabBar self
 @param index 双击选中Index
 */
-(void)tabBar:(TYTabBar *)tabBar doubleClick:(NSInteger)index;

@end

@interface TYTabBar : UITabBar

@property (nonatomic,weak) id<TYTabBarDelegate> realDelegate;

/**
 初始化自定义按钮

 @param itemModels model
 */
-(void)loadItemsWithData:(NSArray<TYBarItemModel *> *)itemModels;


/**
 设置badgeText

 @param text @"数字"   @"."小圆点
 @param index index
 */
-(void)badgeText:(NSString *)text forIndex:(NSInteger)index;

@end
