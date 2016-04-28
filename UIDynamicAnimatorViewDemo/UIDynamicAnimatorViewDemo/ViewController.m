//
//  ViewController.m
//  UIDynamicAnimatorViewDemo
//
//  Created by chars on 16/4/28.
//  Copyright © 2016年 chars. All rights reserved.
//

#import "ViewController.h"
#import "ZKRDynamicAnimateView.h"

@interface ViewController ()<ZKRDynamicAnimateViewDelegate>

@property (nonatomic) UIImageView *imageView;
@property (nonatomic) ZKRDynamicAnimateView *dynamicAnimateView;
@property (nonatomic) UIPanGestureRecognizer *panGestureRecognizer;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    // 设置背景
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background"]];
    [self setupImageView];
    [self setupPanGestureRecognizer];
}

- (void)setupImageView
{
    UIImageView *imageView = [[UIImageView alloc] init];
    CGRect screenBounds = [UIScreen mainScreen].bounds;
    imageView.frame = CGRectMake(0, screenBounds.size.height / 4, screenBounds.size.width, screenBounds.size.height / 3);
    imageView.image = [UIImage imageNamed:@"dynamic"];
    _imageView = imageView;
    [self.view addSubview:imageView];
}

- (void)initDynamicAnimateViewWithTouchPoint:(CGPoint)touchPoint
{
    _dynamicAnimateView = [[ZKRDynamicAnimateView alloc] initWithImageView:_imageView andPoint:touchPoint];
    _dynamicAnimateView.delegate = self;
    [self.view addSubview:_dynamicAnimateView];
}

- (void)setupPanGestureRecognizer
{
    _panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    [self.view addGestureRecognizer:_panGestureRecognizer];
}

- (void) handlePanGesture:(UIPanGestureRecognizer *)gestureRecognizer
{
    if (UIGestureRecognizerStateBegan == gestureRecognizer.state) {
        [self initDynamicAnimateViewWithTouchPoint:[gestureRecognizer locationInView:self.view]];
    } else if (UIGestureRecognizerStateChanged == gestureRecognizer.state) {
        self.dynamicAnimateView.panGestureRecognizer = gestureRecognizer;
    } else if (UIGestureRecognizerStateEnded == gestureRecognizer.state) {
        [_dynamicAnimateView dynamicAnimateViewAfterDragGestureEnded:gestureRecognizer];
    }
}

#pragma mark - ZKRDynamicAnimateViewDelegate
- (void)dynamicAnimateViewExitTransitionForImageView:(UIImageView *)imageView andMagnitude:(CGFloat)magnitude
{
    CGFloat duration = 0.4 - magnitude / 1000.0f;
    duration = duration > 0.15f ? duration : 0.15f;
    
    [UIView animateWithDuration:duration animations:^{
        imageView.alpha = 0;
    }];
}

- (void)dynamicAnimateViewRecoverView
{
    [self.dynamicAnimateView removeFromSuperview];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
