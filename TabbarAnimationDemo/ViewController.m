//
//  ViewController.m
//  TabbarAnimationDemo
//
//  Created by Tiny on 2017/8/22.
//  Copyright © 2017年 LOVEGO. All rights reserved.
//

#import "ViewController.h"
#import "TYAnimationButton.h"


@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.view.backgroundColor = [UIColor colorWithRed:arc4random_uniform(256)/255.0 green:arc4random_uniform(256)/255.0 blue:arc4random_uniform(256)/255.0 alpha:1.0];
}


-(void)reloadColor{
    self.view.backgroundColor = [UIColor colorWithRed:arc4random_uniform(256)/255.0 green:arc4random_uniform(256)/255.0 blue:arc4random_uniform(256)/255.0 alpha:1.0];

}
@end
