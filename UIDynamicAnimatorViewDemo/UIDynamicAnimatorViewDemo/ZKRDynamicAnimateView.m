//
//  ZKRDynamicAnimateView.m
//  ZAKER
//
//  Created by chars on 16/4/27.
//  Copyright © 2016年 ZAKER. All rights reserved.
//

#import "ZKRDynamicAnimateView.h"

@interface ZKRDynamicAnimateView ()
{
    CGRect _originalBounds;
    CGPoint _originalCenter;
    UIOffset _panMaxOffset;
    CGPoint _originalTouchPoint;
}

@property (nonatomic) UIImageView *srcImageView; /** 要进行动态动画的源图片视图 */
@property (nonatomic) UIDynamicAnimator *animator; /**  仿真者  */
@property (nonatomic) UIAttachmentBehavior *attachment; /** 吸附仿真 */
@property (nonatomic) UIGravityBehavior *gravity; /** 重力仿真 */
@property (nonatomic) UIImageView *dynamicView; /** 当前操作图片视图 */

@end

@implementation ZKRDynamicAnimateView

- (instancetype)initWithImageView:(UIImageView *)imageView andPoint:(CGPoint)touchPoint
{
    self = [super initWithFrame:[UIScreen mainScreen].bounds];
    if (self) {
        self.srcImageView = imageView;
        _originalTouchPoint = touchPoint;
        [self prepareAnimator];
    }
    return self;
}

- (void) prepareAnimator
{
    _animator = [[UIDynamicAnimator alloc] initWithReferenceView:self];
    // 添加手势操作视图
    _dynamicView = [[UIImageView alloc] init];
    [self addSubview:_dynamicView];
    _gravity = [[UIGravityBehavior alloc] initWithItems:@[_dynamicView]];
    // 设置重力的方向和大小
    _gravity.gravityDirection = CGVectorMake(0, 5);
    
    [self handleDynamicViewForGestureRecognizer:nil];
    [self initAttachmentBehaviourWithGestureRecognizer:nil];
    [_animator addBehavior:_gravity];
    [_animator addBehavior:_attachment];
}

- (void)setPanGestureRecognizer:(UIPanGestureRecognizer *)panGestureRecognizer
{
    [self calculateMaxPanOffsetForPoint:[panGestureRecognizer locationInView:self] andOtherPoint:_originalTouchPoint];
    [_attachment setAnchorPoint:[panGestureRecognizer locationInView:self]];
    _dynamicView.hidden = NO;
    self.srcImageView.hidden = YES;
}

- (void)handleDynamicViewForGestureRecognizer:(UIPanGestureRecognizer *)gestureRecognizer
{
    self.srcImageView.hidden = YES;
    _dynamicView.hidden = NO;
    _dynamicView.frame = self.srcImageView.frame;
    _dynamicView.image = self.srcImageView.image;
    _originalBounds = CGRectMake(0, 0, self.srcImageView.frame.size.width, self.srcImageView.frame.size.height);
    _originalCenter = self.srcImageView.center;
}

- (void)initAttachmentBehaviourWithGestureRecognizer:(UIPanGestureRecognizer *)gestureRecognizer
{
    CGPoint anchorPosition = _originalTouchPoint;
    UIOffset offset = UIOffsetMake(anchorPosition.x - _dynamicView.center.x, anchorPosition.y - _dynamicView.center.y);
    _attachment = [[UIAttachmentBehavior alloc] initWithItem:_dynamicView offsetFromCenter:offset attachedToAnchor:anchorPosition];
}

- (void)dynamicAnimateViewAfterDragGestureEnded:(UIPanGestureRecognizer *)gestureRecognizer
{
    [_animator removeAllBehaviors];
    
    if ([self hasRecoverForPanOffset:_panMaxOffset]) {
        [self recoverDynamicView];
        return ;
    }
    
    UIPushBehavior *pushBehavior = [[UIPushBehavior alloc] initWithItems:@[_dynamicView] mode:UIPushBehaviorModeInstantaneous];
    CGPoint velocity = [gestureRecognizer velocityInView:self];
    CGPoint currentPoint = [gestureRecognizer locationInView:self];
    CGPoint offset = CGPointMake(currentPoint.x - _originalTouchPoint.x, currentPoint.y - _originalTouchPoint.y);
    CGFloat angle = atan2(offset.y, offset.x);
    CGFloat magnitude = sqrtf((velocity.x * velocity.x) + (velocity.y * velocity.y));
    // 设置推动的大小、角度、推力方向
    pushBehavior.magnitude = magnitude / 10.0f;
    pushBehavior.angle = angle;
    pushBehavior.pushDirection = CGVectorMake((velocity.x / 10) , (velocity.y / 10));
    // 使单次推行为有效
    pushBehavior.active = YES;
    [_animator addBehavior:pushBehavior];
    // 退场
    if ([_delegate respondsToSelector:@selector(dynamicAnimateViewExitTransitionForImageView:andMagnitude:)]) {
        [_delegate dynamicAnimateViewExitTransitionForImageView:_dynamicView andMagnitude:magnitude];
    }
}

- (void)calculateMaxPanOffsetForPoint:(CGPoint)point andOtherPoint:(CGPoint)otherPoint
{
    UIOffset offset = UIOffsetMake(fabs(point.x - otherPoint.x), fabs(point.y - otherPoint.y));
    if (_panMaxOffset.horizontal < offset.horizontal || _panMaxOffset.vertical < offset.vertical) {
        _panMaxOffset = offset;
    }
}

/** 根据偏移值判断图片是否返回原来的位置 */
- (BOOL)hasRecoverForPanOffset:(UIOffset)offset
{
    CGSize viewSize = self.frame.size;
    if (offset.horizontal < viewSize.width / 4 && offset.vertical < viewSize.height / 5) {
        return YES;
    }
    return NO;
}

/** 将当前操作图片视图还原到初始位置 */
- (void)recoverDynamicView
{
    [UIView animateWithDuration:0.45f animations:^{
        _dynamicView.bounds = _originalBounds;
        _dynamicView.center = _originalCenter;
        _dynamicView.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        self.srcImageView.hidden = NO;
        _dynamicView.hidden = YES;
        if ([_delegate respondsToSelector:@selector(dynamicAnimateViewRecoverView)]) {
            [_delegate dynamicAnimateViewRecoverView];
        }
    }];
}

@end
