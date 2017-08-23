//
//  TYAnimationButton.m
//  TabbarAnimationDemo
//
//  Created by Tiny on 2017/8/22.
//  Copyright © 2017年 LOVEGO. All rights reserved.
//

#import "TYAnimationButton.h"
#import "JSBadgeView.h"

@interface TYAnimationButton ()

@property (nonatomic,strong) JSBadgeView *badgeView;

@end

@implementation TYAnimationButton

-(instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        [self initialize];
    }
    return self;
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        
        [self initialize];
    }
    return self;
}

-(void)initialize
{
    [self setAdjustsImageWhenHighlighted:NO];
    
    //设置默认值
    _badgeOffsetX = 15;
    _badgeOffsetY = 15;
    _duration = 3.0f;
    
    _animationType = TYBarItemAnimationTypeScale;
    
}



-(void)layoutSubviews{
    [super layoutSubviews];
    if (!self.badgeView && self.bounds.size.width !=0) {
        //给每个按钮添加一个角标
        self.badgeView = [[JSBadgeView alloc] initWithParentView:self alignment:JSBadgeViewAlignmentTopRight];
        //设置角标参数
        _badgeView.badgeTextFont = [UIFont systemFontOfSize:12];
        _badgeView.badgePositionAdjustment = CGPointMake(-_badgeOffsetX, _badgeOffsetY);
        _badgeView.badgeStrokeWidth = 0.2;
        _badgeView.badgeText  = _badgeText;

    }

}

#pragma mark - setter getter

-(void)setAnimationType:(TYBarItemAnimationType)animationType{
    _animationType = animationType;
}

-(void)setBadgeText:(NSString *)badgeText{
    _badgeText = badgeText;
    [_badgeView setBadgeText:badgeText];
}

-(void)setBadgeOffsetX:(CGFloat)badgeOffsetX{
    _badgeOffsetX = badgeOffsetX;
    _badgeView.badgePositionAdjustment = CGPointMake(-badgeOffsetX, _badgeOffsetY);

}

-(void)setBadgeOffsetY:(CGFloat)badgeOffsetY{
    _badgeOffsetY = badgeOffsetY;
    _badgeView.badgePositionAdjustment = CGPointMake(-_badgeOffsetX, badgeOffsetY);
}

-(void)setImages:(NSArray *)images{
    _images = images;
}

#pragma mark - 动画
-(void)animationStart{
    
    if (_animationType == TYBarItemAnimationTypeNomal) {  //系统默认不带动画
        
    }else if(_animationType == TYBarItemAnimationTypeFrames){  //帧动画
        if (_images) {  //有提供动画图片的才可以动画
            if (!self.imageView.isAnimating) {  //没有动画 则开启动画 如果当前正在动画 则什么都不做
                [self frameAnimation];
            }
        }
    }else if(_animationType == TYBarItemAnimationTypeScale){  //
        [self scaleAnimationRepeatCount:1];
    }else if(_animationType == TYBarItemAnimationTypeRotate){
        [self rotateAnimation];
    }else{
        
    }
}

-(void)animationStop{
    if (_animationType == TYBarItemAnimationTypeNomal) {
        
    }else if(_animationType == TYBarItemAnimationTypeFrames){
        if (_images) {  //有提供动画图片的才可以动画
            if (self.imageView.isAnimating)
            {  //正在动画 则开始动画
                self.imageView.animationImages = nil;
                [self.imageView stopAnimating];
            }
        }
    }else if(_animationType == TYBarItemAnimationTypeScale){
        
    }else if(_animationType == TYBarItemAnimationTypeRotate){
        
    }else{
        
    }
}

-(void)frameAnimation{
    //设置动画图片 给button imageView 添加帧动画
    UIImageView * imageView = self.imageView;
    //设置动画帧
    NSMutableArray *mutalImages = [NSMutableArray array];
    for (NSString *imageName in self.images) {
        [mutalImages addObject:[UIImage imageNamed:imageName]];
    }
    imageView.animationImages= mutalImages;
    //设置动画总时间
    imageView.animationDuration = _duration;
    //设置重复次数，0表示无限
    imageView.animationRepeatCount = 1;
    
    [imageView startAnimating];
}

//缩放动画
- (void)scaleAnimationRepeatCount:(float)repeatCount {
    //需要实现的帧动画，这里根据需求自定义
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animation];
    animation.keyPath = @"transform.scale";
    animation.values = @[@1.0,@1.3,@0.9,@1.15,@0.95,@1.02,@1.0];
    animation.duration = 1;
    animation.repeatCount = repeatCount;
    animation.calculationMode = kCAAnimationCubic;
    [self.imageView.layer addAnimation:animation forKey:nil];
}

//旋转动画
- (void)rotateAnimation {
    // 针对旋转动画，需要将旋转轴向屏幕外侧平移，最大图片宽度的一半
    // 否则背景与按钮图片处于同一层次，当按钮图片旋转时，转轴就在背景图上，动画时会有一部分在背景图之下。
    // 动画结束后复位
//    CGFloat oldZPosition = self.layer.zPosition;//0
    self.layer.zPosition = 65.f / 2;
    [UIView animateWithDuration:0.32 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.imageView.layer.transform = CATransform3DMakeRotation(M_PI, 0, 1, 0);
    } completion:nil];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.70 delay:0 usingSpringWithDamping:1 initialSpringVelocity:0.2 options:UIViewAnimationOptionCurveEaseOut animations:^{
            self.imageView.layer.transform = CATransform3DMakeRotation(2 * M_PI, 0, 1, 0);
        } completion:nil];
    });
}


//高亮状态去掉
-(void)setHighlighted:(BOOL)highlighted{
    
}
@end
