//
//  TYBarItemModel.m
//  TabbarAnimationDemo
//
//  Created by Tiny on 2017/8/23.
//  Copyright © 2017年 LOVEGO. All rights reserved.
//

#import "TYBarItemModel.h"

@implementation TYBarItemModel

-(instancetype)initWithTitle:(NSString *)title images:(NSArray<NSString *> *)images normalImage:(NSString *)normalImage selectedImage:(NSString *)selectedImage AnimationType:(TYBarItemAnimationType)animationType{
    
    if (self = [super init]) {
        _title = title;
        _images = images;
        _normalImage = normalImage;
        _selectedImage = selectedImage;
        _animationType = animationType;
    }
    return self;
}

@end
