//
//  TYAnimationButton.h
//  TabbarAnimationDemo
//
//  Created by Tiny on 2017/8/22.
//  Copyright © 2017年 LOVEGO. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef NS_ENUM(NSUInteger, TYBarItemAnimationType) {
    
    TYBarItemAnimationTypeNomal = 0, //系统默认tabar效果
    TYBarItemAnimationTypeFrames,    //帧动画(imageView)
    TYBarItemAnimationTypeScale,     //缩放动画
    TYBarItemAnimationTypeRotate     //旋转动画
};

@interface TYAnimationButton : UIButton

/**
 动画类型
 */
@property (nonatomic,assign) TYBarItemAnimationType animationType;

/**
 动画图片(帧动画)
 */
@property (nonatomic,strong) NSArray *images;

/**
 当前是否正在动画(帧动画)
 */
@property (nonatomic,assign,readonly) BOOL isAnimating;

/**
 动画时长(帧动画)
 */
@property (nonatomic,assign) NSTimeInterval duration;

/**
 角标值 显示数字直接传入数字@"数字" 如果要显示小红点请传入@"."
 */
@property (nonatomic,copy) NSString *badgeText;

/**
 角标x轴方向的偏移 默认15
 */
@property (nonatomic,assign) CGFloat badgeOffsetX;

/**
 角标y轴方向的偏移 默认15
 */
@property (nonatomic,assign) CGFloat badgeOffsetY;

/**
 角标x轴方向的偏移(横屏状态) 默认15 请根据具体需求微调
 */
@property (nonatomic,assign) CGFloat badgeLandscapeOffsetX;

/**
 角标y轴方向的偏移(横屏状态) 默认40 请根据具体需求微调
 */
@property (nonatomic,assign) CGFloat badgeLandscapeOffsetY;

/**
 开启动画
 */
-(void)animationStart;

/**
 结束动画
 */
-(void)animationStop;

@end
