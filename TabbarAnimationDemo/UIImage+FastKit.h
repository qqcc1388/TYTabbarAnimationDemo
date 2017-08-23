//
//  UIImage+FastKit.h
//  TabbarAnimationDemo
//
//  Created by Tiny on 2017/8/23.
//  Copyright © 2017年 LOVEGO. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (FastKit)

/**
 Create and return a 1x1 point size image with the given color.
 
 @param color  The color.
 */
+ (UIImage *)imageWithColor:(UIColor *)color;

/**
 Create and return a pure color image with the given color and size.
 
 @param color  The color.
 @param size   New image's type.
 */
+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size;

@end
