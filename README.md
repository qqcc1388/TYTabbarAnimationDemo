# TYTabbarAnimationDemo
业务需求导致需要做一个tabbar,里面的按钮点击带有动画效果，tabbar中间的按钮凸出，凸出部分可以点击，支持badge 小红点等，为此封装了一个高度可定制的tabbar -> TYTabBar

TYTabBar可以快速实现以下功能
1. 每个Item都有单击，双击事件回调
2. tem可以支持多种动画（帧动画，缩放动画，旋转动画），每个Item都可以单独设置
3. 支持badgeText,支持小红点功能
4. 只需要配置一下，就可以实现中间按钮凸出效果，并且超出边界仍然有点击效果

效果图

![](https://github.com/qqcc1388/TYTabbarAnimationDemo/blob/master/Resource/gif1.gif)
![](https://github.com/qqcc1388/TYTabbarAnimationDemo/blob/master/Resource/gif2.gif)

### 思路回顾(TYTabBar)
#### 系统的Tabbar功能不算完善，有时候没法完全满足需求，我们这里通过kvc的方式把系统的tabbar替换成我们自己定义的tabbar。
```
    [self setValue:tabbar forKeyPath:@"tabBar"];
```

#### 自定义一个TYTabBar继承UITabBar这样就可以继承很多系统TabBar既有很多属性和功能
```
@interface TYTabBar : UITabBar
```

#### 初始化配置信息(很重要关系到Item个数，PlusItem的位置)
```
#define barItemCount                5                               //tabbarItem 个数
#define barItemPlusButtonIndex      2                              //➕按钮的位置  -1表示不存在+按钮  从0开始
#define barItemFontSize             12                              //字体大小
#define barItemNomalTextColor       [UIColor grayColor]             //字体默认颜色
#define barItemSelectedTextColor    [UIColor redColor]              //选中字体颜色
#define barItemSubMargin            3                               //文字和图片的间距
```

#### 初始化需要TYTabBar中需要展示的按钮并保存起来，并添加点击事件 传入默认第几个tabbarItem默认被选中
```
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

```

#### 在TabBar的layoutSubviews方法中找到对应的系统的TabBarItem并隐藏起来，创建我们自己的Button并占用系统TabBarItem的位置
```
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
            
            if (barItemPlusButtonIndex == btnIndex) {  //plusButton位置  具体偏移根据时间情况进行调节
                item.frame = CGRectMake(width*btnIndex, -20, width, height+20);
                item.subMargin = 10;
            }
            btnIndex++;
        }
    }
}

```
#### 单击 双击事件处理和传递（这里通过代理将信息传递出去realDelegate一定要要实现，涉及到控制器跳转）
```
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
    if (item != _lastItem) {
        
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
```

#### badgeText 小红点设置（参考JSBadgeView并在源码上做了一点修改） 显示数字 @"2" 不显示内容@""或者nil 显示小红点@"."
```
-(void)badgeText:(NSString *)text forIndex:(NSInteger)index{
    //给指定的badgeText设置角标
    if (index < 0 || index >(self.myItems.count - 1)) {
        return;
    }
    TYAnimationButton *item = self.myItems[index];
    
    //设置角标
    [item setBadgeText:text];
    
}
```

### 思路回顾(TYAnimationButton) 
#### TYAnimationButton是整个TYTabBar的核心，每一个Item都是一个TYAnimationButton
##### 提供的动画类型
```
typedef NS_ENUM(NSUInteger, TYBarItemAnimationType) {
    
    TYBarItemAnimationTypeNomal = 0, //系统默认tabar效果
    TYBarItemAnimationTypeFrames,    //帧动画(imageView)
    TYBarItemAnimationTypeScale,     //缩放动画
    TYBarItemAnimationTypeRotate     //旋转动画
};
```

#### 关于动画提供了2个动画方法 一个开始动画，一个结束动画，如果是帧动画，需要传入动画帧
```
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



```
#### 给每个TYAnimationButton添加一个badgeView使其具备角标的功能 
```
-(void)layoutSubviews{
    [super layoutSubviews];
    if (!self.badgeView && self.bounds.size.width !=0) {  //TYAnimationButton初始化OK，并且有了尺寸才创建badgeView
        //给每个按钮添加一个角标
        self.badgeView = [[JSBadgeView alloc] initWithParentView:self alignment:JSBadgeViewAlignmentTopRight];
        //设置角标参数
        _badgeView.badgeTextFont = [UIFont systemFontOfSize:12];
        _badgeView.badgePositionAdjustment = CGPointMake(-_badgeOffsetX, _badgeOffsetY);
        _badgeView.badgeStrokeWidth = 0.2;
        _badgeView.badgeText  = _badgeText;
    }
}
```


### 关于使用 
#### 初始化tabbar
```
-(void)setupTabbar{
    TYTabBar *tabbar = [[TYTabBar alloc] init];
    self.tyTabbar = tabbar;
    self.tyTabbar.realDelegate = self;
    //给tabbar设置内容
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
        //每个按钮都可以单独设置图片 文字 动画效果(暂时只有4种效果)等
        TYBarItemModel *model = [[TYBarItemModel alloc] initWithTitle:arr[i] images:animationImageArr[i] normalImage:barImages[i][0] selectedImage:barImages[i][1] AnimationType:[anmations[i] integerValue]];
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
```
#### 初始化控制器
```
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

```

#### tabbar代理方法使用
```
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
```

更多详细使用参考demo中代码

如果你喜欢我文章，或者本文对你还有一点作用，请给小老弟我点个👍，谢谢！

参考来源：
> JSBadgeView   https://github.com/JaviSoto/JSBadgeView
> CYLTabBarController   https://github.com/ChenYilong/CYLTabBarController





