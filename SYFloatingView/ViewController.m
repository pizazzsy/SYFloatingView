//
//  ViewController.m
//  SYFloatingView
//
//  Created by Mac on 2022/7/1.
//

#import "ViewController.h"
#import "SYFloatingView/SYFloatingView.h"

@interface ViewController ()<SYFloatingViewDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    SYFloatingView * floatView = [[SYFloatingView alloc]initWithFrame:CGRectMake(0, 50, 70, 70) delegate:self];
    [self.view addSubview:floatView];
    [floatView floatingViewRoundedRect];

    // Do any additional setup after loading the view.
}

-(void)floatingViewDidClickView{
    NSLog(@"点击了浮动按钮");
}

@end
