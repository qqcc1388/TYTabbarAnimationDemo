//
//  TYBarItemModel.h
//  TabbarAnimationDemo
//
//  Created by Tiny on 2017/8/23.
//  Copyright © 2017年 LOVEGO. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TYAnimationButton.h"

@interface TYBarItemModel : NSObject

@property (nonatomic,copy) NSString *title;               //title

@property (nonatomic,strong) NSArray<NSString *>*images;  //动画图片

@property (nonatomic,copy) NSString *normalImage;        //normalImage

@property (nonatomic,copy) NSString *selectedImage;      //选中状态image

@property (nonatomic,assign) TYBarItemAnimationType animationType;

-(instancetype)initWithTitle:(NSString *)title images:(NSArray <NSString *> *)images normalImage:(NSString *)normalImage selectedImage:(NSString *)selectedImage AnimationType:(TYBarItemAnimationType)animationType;

@end
