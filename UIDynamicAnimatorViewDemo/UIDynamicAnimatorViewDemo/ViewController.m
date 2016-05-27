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

@property (nonatomic) BOOL isRecoverViewAnimating;
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

- (void)initDynamicAnimateView
{
    _dynamicAnimateView = [[ZKRDynamicAnimateView alloc] init];
    _dynamicAnimateView.delegate = self;
    [self.view layoutIfNeeded];
    [self.view addSubview:_dynamicAnimateView];
}

- (void)setupPanGestureRecognizer
{
    _panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    [self.view addGestureRecognizer:_panGestureRecognizer];
}

- (void) handlePanGesture:(UIPanGestureRecognizer *)gestureRecognizer
{
    CGPoint touch = [gestureRecognizer locationInView:self.view];
    // 图片宽度大于设备屏幕宽度的图片不再响应旋转拖拽操作
    if (_dynamicAnimateView.frame.size.width > [UIScreen mainScreen].bounds.size.width) {
        return;
    }
    if (UIGestureRecognizerStateBegan == gestureRecognizer.state && !_isRecoverViewAnimating) {
        [self initDynamicAnimateView];
        _isRecoverViewAnimating = YES;
        [_dynamicAnimateView dynamicAnimateViewModifyImageView:_imageView andOriginalPoint:touch];
    } else if (UIGestureRecognizerStateChanged == gestureRecognizer.state) {
        if (_isRecoverViewAnimating) {
            self.dynamicAnimateView.currentAnchorPoint = [gestureRecognizer locationInView:self.view];
        }
    } else if (UIGestureRecognizerStateEnded == gestureRecognizer.state) {
        _dynamicAnimateView.userInteractionEnabled = YES;
        _panGestureRecognizer.enabled = NO;
        [_dynamicAnimateView dynamicAnimateViewAfterDragGestureEnded:gestureRecognizer];
    }
}

#pragma mark - ZKRDynamicAnimateViewDelegate
- (void)dynamicAnimateViewExitTransition:(ZKRDynamicAnimateView *)dynamicAnimateView;
{
    _panGestureRecognizer.enabled = YES;
    _isRecoverViewAnimating = NO;
}

- (void)dynamicAnimateViewRecoverView:(ZKRDynamicAnimateView *)dynamicAnimateView
{
    [self.dynamicAnimateView removeFromSuperview];
    _panGestureRecognizer.enabled = YES;
    _isRecoverViewAnimating = NO;
}

- (BOOL)dynamicAnimateViewCanExecAnimate:(ZKRDynamicAnimateView *)dynamicAnimateView
{
    CGRect frame = _imageView.frame;
    if (!CGRectIsEmpty(frame)) {
        return YES;
    }
    return NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
