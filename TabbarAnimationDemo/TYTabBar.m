//
//  TYTabBar.m
//  TabbarAnimationDemo
//
//  Created by Tiny on 2017/8/22.
//  Copyright © 2017年 LOVEGO. All rights reserved.
//

#import "TYTabBar.h"
#import "TYAnimationButton.h"
#import "UIButton+FastKit.h"
#import "UIImage+FastKit.h"
#import "TYBarItemModel.h"

#define barItemCount                5                                //tabbarItem 个数
#define barItemPlusButtonIndex      2                                //➕按钮的位置  -1表示不存在+按钮  从0开始
#define barItemFontSize             12                               //字体大小
#define barItemNomalTextColor       [UIColor whiteColor]             //字体默认颜色
#define barItemSelectedTextColor    [UIColor whiteColor]             //选中字体颜色
#define barItemSubMargin            3                                //文字和图片的间距


@interface TYTabBar ()

@property (nonatomic,strong) NSArray<TYAnimationButton *> *myItems;

@property (nonatomic,strong) TYAnimationButton *lastItem;

@end

@implementation TYTabBar


-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self setupUI];
    }
    return self;
}

//设置UI
-(void)setupUI{
    //设置背景图片为透明 根据情况设置
    [self setBackgroundImage:[UIImage imageWithColor:[UIColor clearColor]]];
    //设置背景颜色为白色
    self.backgroundColor = [UIColor blackColor];
    //设置ShadowImage 根据情况设置
    [self setShadowImage:[UIImage imageWithColor:[UIColor clearColor]]];
}

-(void)loadItemsWithData:(NSArray<TYBarItemModel *> *)itemModels defaultSelect:(NSInteger)index {
    //初始化
    NSMutableArray *mutalArr = [NSMutableArray array];

    TYAnimationButton *tempItem = nil;
    for (int i = 0; i < barItemCount; i++) {
        //取出model
        TYBarItemModel *model = [itemModels objectAtIndex:i];
        TYAnimationButton *button = [[TYAnimationButton alloc] init];
        button.images = model.images;
        [button setImage:[UIImage imageNamed:model.normalImage] forState:UIControlStateNormal];
        [button setImage:[UIImage imageNamed:model.selectedImage] forState:UIControlStateSelected];
        [button setTitle:model.title forState:UIControlStateNormal];
        button.tag = i;
        button.titleLabel.font = [UIFont systemFontOfSize:barItemFontSize];
        [button setTitleColor:barItemSelectedTextColor forState:UIControlStateSelected];
        [button setTitleColor:barItemNomalTextColor forState:UIControlStateNormal];
        [button addTarget:self action:@selector(itemClick:) forControlEvents:UIControlEventTouchDown];
        button.layoutType = LXButtonLayoutTypeImageTop;
        button.subMargin = barItemSubMargin;
        button.animationType = model.animationType;
        [self addSubview:button];

        //第一个按钮默认选中
        if (i == index) {
            tempItem = button;
        }

        //保存按钮
        [mutalArr addObject:button];
    }

    self.myItems = mutalArr;
    //设置默认选中第index个
    if (tempItem) {
        [self itemClick:tempItem];
    }else{
        //如果传入的index无效 则默认选中第0个
        TYAnimationButton *item = self.myItems.firstObject;
        [self itemClick:item];
    }
}


-(void)badgeText:(NSString *)text forIndex:(NSInteger)index{
    //给指定的badgeText设置角标
    if (index < 0 || index >(self.myItems.count - 1)) {
        return;
    }
    TYAnimationButton *item = self.myItems[index];
    
    //设置角标
    [item setBadgeText:text];
    
}

-(void)itemClick:(TYAnimationButton *)item{

    //双击效果处理
    //2次双击之间间隔至少1s
    static  NSTimeInterval lastClickTime = 0;
    if ([self checkIsDoubleClick:item]) {
        NSTimeInterval clickTime = [NSDate timeIntervalSinceReferenceDate];
        if (clickTime - lastClickTime > 1) {  //去掉连击的可能性
            if (_realDelegate && [_realDelegate respondsToSelector:@selector(tabBar:doubleClick:)]) {
                [self.realDelegate tabBar:self doubleClick:item.tag];
            }
        }
        lastClickTime = clickTime;
    }

    //按钮重复点击没有效果
    if (item == _lastItem && self.canRepeatClick) { //可以重复点击
        if (!item.isAnimating) { //正在动画什么都不做否则开始动画
            [item animationStart];
        }
    }else if(item != _lastItem){  //不可以重复点击
        //先把上次item动画关闭
        _lastItem.selected = NO;
        [_lastItem animationStop];
        
        //新点击的item动画开启
        item.selected = YES;
        [item animationStart];
        //把按钮的点击状态传到出去 让tabbarController可以切换控制器
        if (_realDelegate && [_realDelegate respondsToSelector:@selector(tabBar:clickIndex:)]) {
            [self.realDelegate tabBar:self clickIndex:item.tag];
        }
        _lastItem = item;
    }
}

-(void)setCanRepeatClick:(BOOL)canRepeatClick{
    _canRepeatClick = canRepeatClick;
}

//用自定义按钮去替换系统的tabbarItem
-(void)layoutSubviews{
    [super layoutSubviews];
    
    Class class = NSClassFromString(@"UITabBarButton");
    
    int btnIndex = 0;

    //假设这里有5个item
    CGFloat width = self.bounds.size.width/barItemCount*1.0;
    CGFloat height = self.bounds.size.height;
    for (UIView *btn in self.subviews) {//遍历tabbar的子控件
        if ([btn isKindOfClass:class]) {
            
            //先隐藏系统的tabbarItem
            btn.hidden = YES;
            
            //取出前面保存的按钮
            UIButton *item = [self.myItems objectAtIndex:btnIndex];
            
            //设置item的位置
            item.frame = CGRectMake(width*btnIndex, 0, width, height);
            
            if (barItemPlusButtonIndex == btnIndex) {
                //plusButton位置  具体偏移根据时间情况进行调节
                item.frame = CGRectMake(width*btnIndex, -20, width, height+20);
                item.subMargin = 0;
            }
            btnIndex++;
        }
    }
}

- (BOOL)checkIsDoubleClick:(UIButton *)currentBtn
{
    static UIButton *lastBtn = nil;
    static NSTimeInterval lastClickTime = 0;
    
    if (lastBtn != currentBtn) {
        lastBtn = currentBtn;
        lastClickTime = [NSDate timeIntervalSinceReferenceDate];
        
        return NO;
    }
    
    NSTimeInterval clickTime = [NSDate timeIntervalSinceReferenceDate];
    if (clickTime - lastClickTime > 0.5 ) {
        lastClickTime = clickTime;
        return NO;
    }
    
    lastClickTime = clickTime;
    return YES;
}


//重写hitTest方法，去监听发布按钮的点击，目的是为了让凸出的部分点击也有反应
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    
    //这一个判断是关键，不判断的话push到其他页面，点击发布按钮的位置也是会有反应的，这样就不好了
    //self.isHidden == NO 说明当前页面是有tabbar的，那么肯定是在导航控制器的根控制器页面
    //在导航控制器根控制器页面，那么我们就需要判断手指点击的位置是否在发布按钮身上
    //是的话让发布按钮自己处理点击事件，不是的话让系统去处理点击事件就可以了
    if (self.isHidden == NO) {
        
        //将当前tabbar的触摸点转换坐标系，转换到发布按钮的身上，生成一个新的点
        //取出plusButton
        if (barItemPlusButtonIndex <= -1 || barItemPlusButtonIndex > self.myItems.count - 1) {
            return [super hitTest:point withEvent:event];
        }
        UIButton *plusBtn = self.myItems[barItemPlusButtonIndex];
        CGPoint newP = [self convertPoint:point toView:plusBtn];
        
        //判断如果这个新的点是在发布按钮身上，那么处理点击事件最合适的view就是发布按钮
        if ( [plusBtn pointInside:newP withEvent:event]) {
            return plusBtn;
        }else{//如果点不在发布按钮身上，直接让系统处理就可以了
            
            return [super hitTest:point withEvent:event];
        }
    }
    
    else {//tabbar隐藏了，那么说明已经push到其他的页面了，这个时候还是让系统去判断最合适的view处理就好了
        return [super hitTest:point withEvent:event];
    }
}
@end
